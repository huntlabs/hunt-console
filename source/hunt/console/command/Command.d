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
 
module hunt.console.command.Command;

import std.string;
import std.regex;

import hunt.console.Console;
import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.helper.Helper;
import hunt.console.helper.HelperSet;
import hunt.console.input.Input;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.output.Output;

import hunt.collection.Collection;
import hunt.collection.List;
import hunt.Exceptions;
import hunt.console.command.CommandExecutor;
import hunt.logging;

import std.range;

class Command
{
    private Console application;
    private string name;
    private string[] aliases;
    private InputDefinition definition;
    private string help;
    private string description;
    private bool _ignoreValidationErrors = false;
    private bool applicationDefinitionMerged = false;
    private bool applicationDefinitionMergedWithArgs = false;
    private string synopsis;
    private HelperSet helperSet;
    private CommandExecutor executor;

    this()
    {
        this(null);
    }

    this(string name)
    {
        definition = new InputDefinition();

        if (name !is null) {
            setName(name);
        }

        configure();

        if (this.name.empty) {
            throw new LogicException(format("The command defined in '%s' cannot have an empty name.", typeid(this).name));
        }
    }

    void ignoreValidationErrors()
    {
        _ignoreValidationErrors = true;
    }

    void setConsole(Console application)
    {
        this.application = application;
        if (application is null) {
            setHelperSet(null);
        } else {
            setHelperSet(application.getHelperSet());
        }
    }

    Console getConsole()
    {
        return application;
    }

    HelperSet getHelperSet()
    {
        return helperSet;
    }

    void setHelperSet(HelperSet helperSet)
    {
        this.helperSet = helperSet;
    }

    Helper getHelper(string name)
    {
        return helperSet.get(name);
    }

    /**
     * Checks whether the command is enabled or not in the current environment
     *
     * Override this to check for x or y and return false if the command can not
     * run properly under the current conditions.
     */
    bool isEnabled()
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
    int run(Input input, Output output)
    {
        // force the creation of the synopsis before the merge with the app definition
        getSynopsis();

        mergeConsoleDefinition();

        try {
            input.bind(definition);
        } catch (RuntimeException e) {
            if (!_ignoreValidationErrors) {
                throw e;
            }
        }

        initialize(input, output);

        if (input.isInteractive()) {
            interact(input, output);
        }

        input.validate();

        int statusCode;
        if (executor !is null) {
            statusCode = executor.execute(input, output);
        } else {
            statusCode = execute(input, output);
        }

        return statusCode;
    }

    Command setExecutor(CommandExecutor executor)
    {
        this.executor = executor;

        return this;
    }

    void mergeConsoleDefinition()
    {
        mergeConsoleDefinition(true);
    }

    void mergeConsoleDefinition(bool mergeArgs)
    {
        if (application is null || (applicationDefinitionMerged && (applicationDefinitionMergedWithArgs || !mergeArgs))) {
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

    Command setDefinition(InputDefinition definition)
    {
        this.definition = definition;

        applicationDefinitionMerged = false;

        return this;
    }

    InputDefinition getDefinition()
    {
        return definition;
    }

    InputDefinition getNativeDefinition()
    {
        return getDefinition();
    }

    Command addArgument(string name)
    {
        definition.addArgument(new InputArgument(name));

        return this;
    }

    Command addArgument(string name, int mode)
    {
        definition.addArgument(new InputArgument(name, mode));

        return this;
    }

    Command addArgument(string name, int mode, string description)
    {
        definition.addArgument(new InputArgument(name, mode, description));

        return this;
    }

    Command addArgument(string name, int mode, string description, string defaultValue)
    {
        definition.addArgument(new InputArgument(name, mode, description, defaultValue));

        return this;
    }

    Command addOption(string name)
    {
        definition.addOption(new InputOption(name));

        return this;
    }

    Command addOption(string name, string shortcut)
    {
        definition.addOption(new InputOption(name, shortcut));

        return this;
    }

    Command addOption(string name, string shortcut, int mode)
    {
        definition.addOption(new InputOption(name, shortcut, mode));

        return this;
    }

    Command addOption(string name, string shortcut, int mode, string description)
    {
        definition.addOption(new InputOption(name, shortcut, mode, description));

        return this;
    }

    Command addOption(string name, string shortcut, int mode, string description, string defaultValue)
    {
        definition.addOption(new InputOption(name, shortcut, mode, description, defaultValue));

        return this;
    }

    Command setName(string name)
    {
        validateName(name);

        this.name = name;

        return this;
    }

    string getName()
    {
        return name;
    }

    Command setDescription(string description)
    {
        this.description = description;

        return this;
    }

    string getDescription()
    {
        return description;
    }

    Command setHelp(string help)
    {
        this.help = help;

        return this;
    }

    string getHelp()
    {
        return help;
    }

    string getProcessedHelp()
    {
        string help = getHelp();
        if (help is null) {
            return "";
        }

        help = help.replace("%command.name%", getName());

        return help;
    }

    Command setAliases(string[] aliases...)
    {
        foreach (a ; aliases) {
            validateName(a);
        }

        this.aliases = aliases;

        return this;
    }

    string[] getAliases()
    {
        return aliases;
    }

    string getSynopsis()
    {
        if (synopsis is null) {
            synopsis = format("%s %s", name, definition.getSynopsis()).strip();
        }

        return synopsis;
    }

    private void validateName(string name)
    {
        // logInfo("command name : ",name);
        // if (!name.matchAll("^[^\\:]++(\\:[^\\:]++)*$").empty) {
        //     logError("command name : ",name);
        //     throw new InvalidArgumentException(format("Command name '%s' is invalid.", name));
        // }
    }
}
