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
 
module hunt.console.input.AbstractInput;

import hunt.console.error.InvalidArgumentException;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.console.input.Input;
import hunt.console.input.InputDefinition;
import hunt.Exceptions;

import std.string;

public abstract class AbstractInput : Input
{
    protected InputDefinition definition;
    protected Map!(string, string) options;
    protected Map!(string, string) arguments;
    protected bool interactive = true;

    public this()
    {
        this.definition = new InputDefinition();
    }

    public this(InputDefinition definition)
    {
        bind(definition);
        validate();
    }

    override public void bind(InputDefinition definition)
    {
        this.arguments = new HashMap!(string, string)();
        this.options = new HashMap!(string, string)();
        this.definition = definition;

        parse();
    }

    protected abstract void parse();

    override public void validate()
    {
        if (arguments.size() < definition.getArgumentRequiredCount()) {
            throw new RuntimeException("Not enough arguments");
        }
    }

    override public bool isInteractive()
    {
        return interactive;
    }

    override public void setInteractive(bool interactive)
    {
        this.interactive = interactive;
    }

    override public string[] getArguments()
    {
        Map!(string, string) argumentValues = definition.getArgumentDefaults();

        foreach (string k,string v ; arguments) {
            argumentValues.put(k, v);
        }

        return argumentValues.values();
    }

    override public string getArgument(string name)
    {
        if (!definition.hasArgument(name)) {
            throw new InvalidArgumentException(format("The '%s' argument does not exist.", name));
        }

        if (arguments.containsKey(name)) {
            return arguments.get(name);
        }

        return definition.getArgument(name).getDefaultValue();
    }

    override public void setArgument(string name, string value) /* throws InvalidArgumentException */
    {
        if (!definition.hasArgument(name)) {
            throw new InvalidArgumentException(format("The '%s' argument does not exist.", name));
        }

        arguments.put(name, value);
    }

    override public bool hasArgument(string name)
    {
        return definition.hasArgument(name);
    }

    override public string[] getOptions()
    {
        Map!(string, string) optionValues = definition.getOptionDefaults();

        foreach (string k ,string v ; options) {
            optionValues.put(k, v);
        }

        return optionValues.values();
    }

    override public string getOption(string name)
    {
        if (!definition.hasOption(name)) {
            throw new InvalidArgumentException(format("The '%s' option does not exist.", name));
        }

        if (options.containsKey(name)) {
            return options.get(name);
        }

        return definition.getOption(name).getDefaultValue();
    }

    override public void setOption(string name, string value) /* throws InvalidArgumentException */
    {
        if (!definition.hasOption(name)) {
            throw new InvalidArgumentException(format("The '%s' option does not exist.", name));
        }

        options.put(name, value);
    }

    override public bool hasOption(string name)
    {
        return definition.hasOption(name);
    }
}
