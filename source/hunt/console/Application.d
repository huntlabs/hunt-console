/*
 * hunt-console eases the creation of beautiful and testable command line interfaces.
 *
 * Copyright (C) 2018-2019, HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
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

import hunt.io.Common;
import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.collection.Set;
import hunt.collection.HashSet;
import hunt.Exceptions;
import core.stdc.stdlib;
import std.string;
import hunt.text.StringBuilder;
import hunt.Integer;

// import hunt.io.BufferedReader;
// import hunt.io.InputStreamReader;


class Application
{
    private Map!(string, Command) _commands;
    private bool _wantHelps;
    private string _name;
    private string _version;
    private InputDefinition _definition;
    private bool _autoExit = true;
    private string _defaultCommand;
    private bool _catchExceptions = true;
    private Command _runningCommand;
    private Command[] _defaultCommands;
    private int[] _terminalDimensions;
    private HelperSet _helperSet;

    this()
    {
        this("UNKNOWN", "UNKNOWN");
    }

    this(string name, string ver)
    {
        _commands = new HashMap!(string, Command)();
        _name = name;
        _version = ver;
        _defaultCommand = "list";
        _helperSet = getDefaultHelperSet();
        _definition = getDefaultInputDefinition();

        foreach (Command command ; getDefaultCommands()) {
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
            if (!_catchExceptions) {
                throw new RuntimeException(e);
            }

            if (cast(ConsoleOutput)output !is null) {
                renderException(e, (cast(ConsoleOutput) output).getErrorOutput());
            } else {
                renderException(e, output);
            }

            exitCode = 1;
        }

        if (_autoExit) {
            if (exitCode > 255) {
                exitCode = 255;
            }

            /* System. */exit(exitCode);
        }

        return exitCode;
    }

    private void renderException(Throwable error, Output output)
    {
        string title = format("%s  [%s]  ", error.message(), typeid(error).name);
        output.writeln(title);
        output.writeln("");

        if (cast(int)(output.getVerbosity()) >= cast(int)(Verbosity.VERBOSE)) {
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
            if (name is null) {
                name = "help";
                input = new ArrayInput("command", "help");
            } else {
                _wantHelps = true;
            }
        }

        if (true == input.hasParameterOption("--ansi")) {
            output.setDecorated(true);
        } else if (true == input.hasParameterOption("--no-ansi")) {
            output.setDecorated(false);
        }

        if (true == input.hasParameterOption("--no-interaction", "-n")) {
            input.setInteractive(false);
        }

         if (true == input.hasParameterOption("--quiet", "-q")) {
            output.setVerbosity(Verbosity.QUIET);
        } else if (true == input.hasParameterOption("--verbose", "-v")) {
            output.setVerbosity(Verbosity.VERBOSE);
        }

        if (name is null) {
            name = _defaultCommand;
            input = new ArrayInput("command", _defaultCommand);
        }

        Command command = find(name);

        _runningCommand = command;
        int exitCode = doRunCommand(command, input, output);
        _runningCommand = null;

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
            if (input.hasParameterOption("-vvv") || input.hasParameterOption("--verbose=3") || input.getParameterOption("--verbose", "")==("3")) {
                output.setVerbosity(Verbosity.DEBUG);
            } else if (input.hasParameterOption("-vv") || input.hasParameterOption("--verbose=2") || input.getParameterOption("--verbose", "")==("2")) {
                output.setVerbosity(Verbosity.VERY_VERBOSE);
            } else if (input.hasParameterOption("-v") || input.hasParameterOption("--verbose=1") || input.getParameterOption("--verbose", "")==("1")) {
                output.setVerbosity(Verbosity.VERBOSE);
            }
        }
    }

    public void setAutoExit(bool autoExit)
    {
        _autoExit = autoExit;
    }

    public void setCatchExceptions(bool catchExceptions)
    {
        _catchExceptions = catchExceptions;
    }

    public string getName()
    {
        return _name;
    }

    public void setName(string name)
    {
        _name = name;
    }

    public string getVersion()
    {
        return _version;
    }

    public void setVersion(string ver)
    {
        _version = ver;
    }

    public InputDefinition getDefinition()
    {
        return _definition;
    }

    public void setDefinition(InputDefinition definition)
    {
        _definition = definition;
    }

    public string getHelp()
    {
        string nl = "\r\n"/* System.getProperty("line.separator") */;

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

        foreach (InputOption option ; _definition.getOptions()) {
            sb.append(format("  %-29s %s %s",
                    "<info>--" ~ option.getName() ~ "</info>",
                    option.getShortcut() is null ? "  " : "<info>-" ~ option.getShortcut() ~ "</info>",
                    option.getDescription())
            ).append(nl);
        }

        return sb.toString();
    }

    public string getLongVersion()
    {
        if (!(getName() == ("UNKNOWN")) && !(getVersion() == ("UNKNOWN"))) {
            return format("<info>%s</info> version <comment>%s</comment>", getName(), getVersion());
        }

        return "<info>Console Tool</info>";
    }

    public Command register(string name)
    {
        return add(new Command(name));
    }

    public void addCommands(Command[] commands)
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

        if (command.getDefinition() is null) {
            throw new LogicException(format("Command class '%s' is not correctly initialized. You probably forgot to call the super constructor.", typeid(command).name));
        }

        _commands.put(command.getName(), command);

        foreach (string a ; command.getAliases()) {
            _commands.put(a, command);
        }

        return command;
    }

    public Command find(string name)
    {
        return get(name);
    }

    public Map!(string, Command) all()
    {
        return _commands;
    }

    public Map!(string, Command) all(string namespace)
    {
        Map!(string, Command) commands = new HashMap!(string, Command)();

        foreach (Command command ; _commands.values()) {
            if (namespace == extractNamespace(command.getName(), new Integer(StringUtils.count(namespace, ':') + 1))) {
                commands.put(command.getName(), command);
            }
        }

        return commands;
    }

    public string extractNamespace(string name)
    {
        return extractNamespace(name, null);
    }

    public string extractNamespace(string name, Integer limit)
    {
        List!(string) parts = new ArrayList!(string)();
       foreach(value; name.split(":")) {
           parts.add(value);
       }
        parts.removeAt(parts.size() - 1);

        if (parts.size() == 0) {
            return null;
        }

        if (limit !is null && parts.size() > limit.intValue()) {
            // parts = parts.subList(0, limit);
            List!(string) temp = new ArrayList!(string)();
            for(int i = 0 ; i< limit.intValue();i++)
            {
                temp.add(parts.get(i));
            }
            parts = temp;
            
        }
        string[] res;
        foreach(value; parts) {
            res ~= value;
        }
        return StringUtils.join(res, ":");
    }

    public Command get(string name)
    {
        if (!_commands.containsKey(name)) {
            throw new InvalidArgumentException(format("The command '%s' does not exist.", name));
        }

        Command command = _commands.get(name);

        if (_wantHelps) {
            _wantHelps = false;

            HelpCommand helpCommand = cast(HelpCommand) get("help");
            helpCommand.setCommand(command);

            return helpCommand;
        }

        return command;
    }

    public bool has(string name)
    {
        return _commands.containsKey(name);
    }

    public string[] getNamespaces()
    {
        Set!(string) namespaces = new HashSet!(string)();

        string namespace;
        foreach (Command command ; _commands.values()) {
            namespace = extractNamespace(command.getName());
            if (namespace !is null) {
                namespaces.add(namespace);
            }
            foreach (string a ; command.getAliases()) {
                extractNamespace(a);
                if (namespace !is null) {
                    namespaces.add(namespace);
                }
            }
        }

        string[] res;
        foreach(value; namespaces) {
            res ~= value;
        }

        return res;
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
        return _helperSet;
    }

    public void setHelperSet(HelperSet helperSet)
    {
        _helperSet = helperSet;
    }

    protected HelperSet getDefaultHelperSet()
    {
        HelperSet helperSet = new HelperSet();
        helperSet.set(new QuestionHelper());

        return helperSet;
    }

    public int[] getTerminalDimensions()
    {
        if (_terminalDimensions !is null) {
            return _terminalDimensions;
        }

//        string sttystring = getSttyColumns();

        return [80, 120];
    }

    public string getSttyColumns()
    {
        // todo make this work
        implementationMissing();
        // string sttyColumns = null;
        // try {
        //     ProcessBuilder builder = new ProcessBuilder("/bin/bash", "stty", "-a");
        //     Process process = builder.start();
        //     StringBuilder o = new StringBuilder();
        //     BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
        //     string line, previous = null;
        //     while ((line = br.readLine()) !is null) {
        //         if (!line == previous) {
        //             previous = line;
        //             o.append(line).append('\n');
        //         }
        //     }
        //     sttyColumns = o.toString();
        // } catch (IOException e) {
        //     e.printStackTrace();
        // }

        // return sttyColumns;
        return null;
    }
}
