module hunt.console.command.Command;

import hunt.console.Application;
import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.helper.Helper;
import hunt.console.helper.HelperSet;
import hunt.console.input.Input;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.output.Output;

import hunt.container.Collection;
import hunt.container.List;

class Command
{
    private Application application;
    private string name;
    private string[] aliases;
    private InputDefinition definition;
    private string help;
    private string description;
    private boolean ignoreValidationErrors = false;
    private boolean applicationDefinitionMerged = false;
    private boolean applicationDefinitionMergedWithArgs = false;
    private string synopsis;
    private HelperSet helperSet;
    private CommandExecutor executor;

    public this()
    {
        this(null);
    }

    public this(string name)
    {
        definition = new InputDefinition();

        if (name != null) {
            setName(name);
        }

        configure();

        if (this.name == null || this.name.isEmpty()) {
            throw new LogicException(string.format("The command defined in '%s' cannot have an empty name.", getClass()));
        }
    }

    public void ignoreValidationErrors()
    {
        ignoreValidationErrors = true;
    }

    public void setApplication(Application application)
    {
        this.application = application;
        if (application == null) {
            setHelperSet(null);
        } else {
            setHelperSet(application.getHelperSet());
        }
    }

    public Application getApplication()
    {
        return application;
    }

    public HelperSet getHelperSet()
    {
        return helperSet;
    }

    public void setHelperSet(HelperSet helperSet)
    {
        this.helperSet = helperSet;
    }

    public Helper getHelper(string name)
    {
        return helperSet.get(name);
    }

    /**
     * Checks whether the command is enabled or not in the current environment
     *
     * Override this to check for x or y and return false if the command can not
     * run properly under the current conditions.
     */
    public boolean isEnabled()
    {
        return true;
    }

    /**
     * Configures the current command.
     */
    protected void configure()
    {
    }

    /**
     * Executes the current command.
     *
     * This method is not abstract because you can use this class
     * as a concrete class. In this case, instead of defining the
     * execute() method, you set the code to execute by passing
     * a CommandExecutor to the setExecutor() method.
     */
    protected int execute(Input input, Output output)
    {
        throw new LogicException("You must override the execute() method in the concrete command class.");
    }

    /**
     * Interacts with the user.
     */
    protected void interact(Input input, Output output)
    {
    }

    /**
     * Initializes the command just after the input has been validated.
     *
     * This is mainly useful when a lot of commands extends one main command
     * where some things need to be initialized based on the input arguments and options.
     */
    protected void initialize(Input input, Output output)
    {
    }

    /**
     * Runs the command.
     */
    public int run(Input input, Output output)
    {
        // force the creation of the synopsis before the merge with the app definition
        getSynopsis();

        mergeApplicationDefinition();

        try {
            input.bind(definition);
        } catch (RuntimeException e) {
            if (!ignoreValidationErrors) {
                throw e;
            }
        }

        initialize(input, output);

        if (input.isInteractive()) {
            interact(input, output);
        }

        input.validate();

        int statusCode;
        if (executor != null) {
            statusCode = executor.execute(input, output);
        } else {
            statusCode = execute(input, output);
        }

        return statusCode;
    }

    public Command setExecutor(CommandExecutor executor)
    {
        this.executor = executor;

        return this;
    }

    public void mergeApplicationDefinition()
    {
        mergeApplicationDefinition(true);
    }

    public void mergeApplicationDefinition(boolean mergeArgs)
    {
        if (application == null || (applicationDefinitionMerged && (applicationDefinitionMergedWithArgs || !mergeArgs))) {
            return;
        }

        if (mergeArgs) {
            Collection!(InputArgument) currentArguments = definition.getArguments();
            definition.setArguments(application.getDefinition().getArguments());
            definition.addArguments(currentArguments);
        }

        definition.addOptions(application.getDefinition().getOptions());

        applicationDefinitionMerged = true;
        if (mergeArgs) {
            applicationDefinitionMergedWithArgs = true;
        }
    }

    public Command setDefinition(InputDefinition definition)
    {
        this.definition = definition;

        applicationDefinitionMerged = false;

        return this;
    }

    public InputDefinition getDefinition()
    {
        return definition;
    }

    public InputDefinition getNativeDefinition()
    {
        return getDefinition();
    }

    public Command addArgument(string name)
    {
        definition.addArgument(new InputArgument(name));

        return this;
    }

    public Command addArgument(string name, int mode)
    {
        definition.addArgument(new InputArgument(name, mode));

        return this;
    }

    public Command addArgument(string name, int mode, string description)
    {
        definition.addArgument(new InputArgument(name, mode, description));

        return this;
    }

    public Command addArgument(string name, int mode, string description, string defaultValue)
    {
        definition.addArgument(new InputArgument(name, mode, description, defaultValue));

        return this;
    }

    public Command addOption(string name)
    {
        definition.addOption(new InputOption(name));

        return this;
    }

    public Command addOption(string name, string shortcut)
    {
        definition.addOption(new InputOption(name, shortcut));

        return this;
    }

    public Command addOption(string name, string shortcut, int mode)
    {
        definition.addOption(new InputOption(name, shortcut, mode));

        return this;
    }

    public Command addOption(string name, string shortcut, int mode, string description)
    {
        definition.addOption(new InputOption(name, shortcut, mode, description));

        return this;
    }

    public Command addOption(string name, string shortcut, int mode, string description, string defaultValue)
    {
        definition.addOption(new InputOption(name, shortcut, mode, description, defaultValue));

        return this;
    }

    public Command setName(string name)
    {
        validateName(name);

        this.name = name;

        return this;
    }

    public string getName()
    {
        return name;
    }

    public Command setDescription(string description)
    {
        this.description = description;

        return this;
    }

    public string getDescription()
    {
        return description;
    }

    public Command setHelp(string help)
    {
        this.help = help;

        return this;
    }

    public string getHelp()
    {
        return help;
    }

    public string getProcessedHelp()
    {
        string help = getHelp();
        if (help == null) {
            return "";
        }

        help = help.replaceAll("%command.name%", getName());

        return help;
    }

    public Command setAliases(string... aliases)
    {
        foreach (string alias ; aliases) {
            validateName(alias);
        }

        this.aliases = aliases;

        return this;
    }

    public string[] getAliases()
    {
        return aliases;
    }

    public string getSynopsis()
    {
        if (synopsis == null) {
            synopsis = String.format("%s %s", name, definition.getSynopsis()).trim();
        }

        return synopsis;
    }

    private void validateName(string name)
    {
        if (!name.matches("^[^\\:]++(\\:[^\\:]++)*$")) {
            throw new InvalidArgumentException(string.format("Command name '%s' is invalid.", name));
        }
    }
}
