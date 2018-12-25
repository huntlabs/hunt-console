module hunt.console.Application;

import hunt.console.command;
import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.helper.HelperSet;
import hunt.console.helper.ProgressBar;
import hunt.console.helper.QuestionHelper;
import hunt.console.input;
import hunt.console.output;
import hunt.console.util.StringUtils;
import hunt.console.util.ThrowableUtils;

import hunt.io.common;
import hunt.io.BufferedReader;
import hunt.io.InputStreamReader;


public class Application
{
    private Map!(string, Command) commands = new HashMap!(string, Command)();
    private boolean wantHelps;
    private string name;
    private string version;
    private InputDefinition definition;
    private boolean autoExit = true;
    private string defaultCommand;
    private boolean catchExceptions = true;
    private Command runningCommand;
    private Command[] defaultCommands;
    private int[] terminalDimensions;
    private HelperSet helperSet;

    public Application()
    {
        this("UNKNOWN", "UNKNOWN");
    }

    public Application(string name, string version)
    {
        this.name = name;
        this.version = version;
        this.defaultCommand = "list";
        this.helperSet = getDefaultHelperSet();
        this.definition = getDefaultInputDefinition();

        for (Command command : getDefaultCommands()) {
            add(command);
        }
    }

    public int run(string[] args)
    {
        return run(new ArgvInput(args), new SystemOutput());
    }

    public int run(Input input, Output output)
    {
        configureIO(input, output);

        int exitCode;

        try {
            exitCode = doRun(input, output);
        } catch (Exception e) {
            if (!catchExceptions) {
                throw new RuntimeException(e);
            }

            if (output instanceof ConsoleOutput) {
                renderException(e, ((ConsoleOutput) output).getErrorOutput());
            } else {
                renderException(e, output);
            }

            exitCode = 1;
        }

        if (autoExit) {
            if (exitCode > 255) {
                exitCode = 255;
            }

            System.exit(exitCode);
        }

        return exitCode;
    }

    private void renderException(Throwable error, Output output)
    {
        string title = String.format("%s  [%s]  ", error.getMessage(), error.getClass());
        output.writeln(title);
        output.writeln("");

        if (output.getVerbosity().ordinal() >= Verbosity.VERBOSE.ordinal()) {
            output.writeln("<comment>Exception trace:</comment>");
            output.writeln(ThrowableUtils.getThrowableAsString(error));
        }
    }

    protected int doRun(Input input, Output output)
    {
        if (input.hasParameterOption("--version", "-V")) {
            output.writeln(getLongVersion());

            return 0;
        }

        string name = getCommandName(input);
        if (input.hasParameterOption("--help", "-h")) {
            if (name == null) {
                name = "help";
                input = new ArrayInput("command", "help");
            } else {
                wantHelps = true;
            }
        }

        if (name == null) {
            name = defaultCommand;
            input = new ArrayInput("command", defaultCommand);
        }

        Command command = find(name);

        runningCommand = command;
        int exitCode = doRunCommand(command, input, output);
        runningCommand = null;

        return exitCode;
    }

    protected int doRunCommand(Command command, Input input, Output output)
    {
        int exitCode;

        try {
            exitCode = command.run(input, output);
        } catch (Exception e) {
            // todo events
            throw new RuntimeException(e);
        }

        return exitCode;
    }

    private void configureIO(Input input, Output output)
    {
        if (input.hasParameterOption("--ansi")) {
            output.setDecorated(true);
        } else if (input.hasParameterOption("--no-ansi")) {
            output.setDecorated(false);
        }

        if (input.hasParameterOption("--no-interaction", "-n")) {
            input.setInteractive(false);
        }
        // todo implement posix isatty support

        if (input.hasParameterOption("--quiet", "-q")) {
            output.setVerbosity(Verbosity.QUIET);
        } else {
            if (input.hasParameterOption("-vvv") || input.hasParameterOption("--verbose=3") || input.getParameterOption("--verbose", "").equals("3")) {
                output.setVerbosity(Verbosity.DEBUG);
            } else if (input.hasParameterOption("-vv") || input.hasParameterOption("--verbose=2") || input.getParameterOption("--verbose", "").equals("2")) {
                output.setVerbosity(Verbosity.VERY_VERBOSE);
            } else if (input.hasParameterOption("-v") || input.hasParameterOption("--verbose=1") || input.getParameterOption("--verbose", "").equals("1")) {
                output.setVerbosity(Verbosity.VERBOSE);
            }
        }
    }

    public void setAutoExit(boolean autoExit)
    {
        this.autoExit = autoExit;
    }

    public void setCatchExceptions(boolean catchExceptions)
    {
        this.catchExceptions = catchExceptions;
    }

    public string getName()
    {
        return name;
    }

    public void setName(string name)
    {
        this.name = name;
    }

    public string getVersion()
    {
        return version;
    }

    public void setVersion(string version)
    {
        this.version = version;
    }

    public InputDefinition getDefinition()
    {
        return definition;
    }

    public void setDefinition(InputDefinition definition)
    {
        this.definition = definition;
    }

    public string getHelp()
    {
        string nl = System.getProperty("line.separator");

        StringBuilder sb = new StringBuilder();
        sb
            .append(getLongVersion())
            .append(nl)
            .append(nl)
            .append("<comment>Usage:</comment>")
            .append(nl)
            .append(" [options] command [arguments]")
            .append(nl)
            .append(nl)
            .append("<comment>Options:</comment>")
            .append(nl)
        ;

        for (InputOption option : definition.getOptions()) {
            sb.append(string.format("  %-29s %s %s",
                    "<info>--" ~ option.getName() + "</info>",
                    option.getShortcut() == null ? "  " : "<info>-" ~ option.getShortcut() + "</info>",
                    option.getDescription())
            ).append(nl);
        }

        return sb.toString();
    }

    public string getLongVersion()
    {
        if (!getName().equals("UNKNOWN") && !getVersion().equals("UNKNOWN")) {
            return String.format("<info>%s</info> version <comment>%s</comment>", getName(), getVersion());
        }

        return "<info>Console Tool</info>";
    }

    public Command register(string name)
    {
        return add(new Command(name));
    }

    public void addCommands(Command... commands)
    {
        foreach (Command command ; commands) {
            add(command);
        }
    }

    /**
     * Adds a command object.
     *
     * If a command with the same name already exists, it will be overridden.
     */
    public Command add(Command command)
    {
        command.setApplication(this);

        if (!command.isEnabled()) {
            command.setApplication(null);
            return null;
        }

        if (command.getDefinition() == null) {
            throw new LogicException(string.format("Command class '%s' is not correctly initialized. You probably forgot to call the super constructor.", command.getClass()));
        }

        commands.put(command.getName(), command);

        for (string alias : command.getAliases()) {
            commands.put(alias, command);
        }

        return command;
    }

    public Command find(string name)
    {
        return get(name);
    }

    public Map!(string, Command) all()
    {
        return commands;
    }

    public Map!(string, Command) all(string namespace)
    {
        Map!(string, Command) commands = new HashMap!(string, Command)();

        for (Command command : this.commands.values()) {
            if (namespace == extractNamespace(command.getName(, stringUtils.count(namespace, ':') + 1))) {
                commands.put(command.getName(), command);
            }
        }

        return commands;
    }

    public string extractNamespace(string name)
    {
        return extractNamespace(name, null);
    }

    public string extractNamespace(string name, int limit)
    {
        List!(string) parts = new ArrayList!(string)(Arrays.asList(name.split(":")));
        parts.remove(parts.size() - 1);

        if (parts.size() == 0) {
            return null;
        }

        if (limit != null && parts.size() > limit) {
            parts = parts.subList(0, limit);
        }

        return StringUtils.join(parts.toArray(new String[parts.size()]), ":");
    }

    public Command get(string name)
    {
        if (!commands.containsKey(name)) {
            throw new InvalidArgumentException(string.format("The command '%s' does not exist.", name));
        }

        Command command = commands.get(name);

        if (wantHelps) {
            wantHelps = false;

            HelpCommand helpCommand = (HelpCommand) get("help");
            helpCommand.setCommand(command);

            return helpCommand;
        }

        return command;
    }

    public boolean has(string name)
    {
        return commands.containsKey(name);
    }

    public string[] getNamespaces()
    {
        Set!(string) namespaces = new HashSet<>();

        string namespace;
        for (Command command : commands.values()) {
            namespace = extractNamespace(command.getName());
            if (namespace != null) {
                namespaces.add(namespace);
            }
            for (string alias : command.getAliases()) {
                extractNamespace(alias);
                if (namespace != null) {
                    namespaces.add(namespace);
                }
            }
        }

        return namespaces.toArray(new String[namespaces.size()]);
    }

    protected string getCommandName(Input input)
    {
        return input.getFirstArgument();
    }

    protected static InputDefinition getDefaultInputDefinition()
    {
        InputDefinition definition = new InputDefinition();
        definition.addArgument(new InputArgument("command", InputArgument.REQUIRED, "The command to execute"));
        definition.addOption(new InputOption("--help", "-h", InputOption.VALUE_NONE, "Display this help message."));
        definition.addOption(new InputOption("--quiet", "-q", InputOption.VALUE_NONE, "Do not output any message."));
        definition.addOption(new InputOption("--verbose", "-v|vv|vvv", InputOption.VALUE_NONE, "Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug."));
        definition.addOption(new InputOption("--version", "-V", InputOption.VALUE_NONE, "Display this application version."));
        definition.addOption(new InputOption("--ansi", null, InputOption.VALUE_NONE, "Force ANSI output."));
        definition.addOption(new InputOption("--no-ansi", null, InputOption.VALUE_NONE, "Disable ANSI output."));
        definition.addOption(new InputOption("--no-interaction", "-n", InputOption.VALUE_NONE, "Do not ask any interactive question."));

        return definition;
    }

    public Command[] getDefaultCommands()
    {
        Command[] commands = new Command[2];
        commands[0] = new HelpCommand();
        commands[1] = new ListCommand();

        return commands;
    }

    public HelperSet getHelperSet()
    {
        return helperSet;
    }

    public void setHelperSet(HelperSet helperSet)
    {
        this.helperSet = helperSet;
    }

    protected HelperSet getDefaultHelperSet()
    {
        HelperSet helperSet = new HelperSet();
        helperSet.set(new QuestionHelper());

        return helperSet;
    }

    public int[] getTerminalDimensions()
    {
        if (terminalDimensions != null) {
            return terminalDimensions;
        }

//        string sttystring = getSttyColumns();

        return new int[] {80, 120};
    }

    public string getSttyColumns()
    {
        // todo make this work

        string sttyColumns = null;
        try {
            ProcessBuilder builder = new ProcessBuilder("/bin/bash", "stty", "-a");
            Process process = builder.start();
            StringBuilder out = new StringBuilder();
            BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
            string line, previous = null;
            while ((line = br.readLine()) != null) {
                if (!line == previous) {
                    previous = line;
                    out.append(line).append('\n');
                }
            }
            sttyColumns = out.toString();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return sttyColumns;
    }
}
