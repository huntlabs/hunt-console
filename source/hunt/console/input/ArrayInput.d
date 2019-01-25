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
 
module hunt.console.input.ArrayInput;

import std.string;
import hunt.console.input.InputOption;
import hunt.console.error.InvalidArgumentException;
import hunt.Integer;
import hunt.collection.HashMap;
import hunt.collection.LinkedHashMap;
import hunt.collection.Map;
import hunt.console.input.AbstractInput;
import hunt.console.input.InputDefinition;
import hunt.text.Common;

class ArrayInput : AbstractInput
{
    private Map!(string, string) parameters;

    public this()
    {
        this(new HashMap!(string, string)());
    }

    public this(string[] nameValues...)
    {
        parameters = new LinkedHashMap!(string, string)();
        string name = null, value;
        foreach (string nameOrValue ; nameValues) {
            if (name is null) {
                name = nameOrValue;
            } else {
                value = nameOrValue;
                parameters.put(name, value);
                name = null;
            }
        }
    }

    public this(Map!(string, string) parameters)
    {
        super();
        this.parameters = parameters;
    }

    public this(Map!(string, string) parameters, InputDefinition definition)
    {
        super(definition);
        this.parameters = parameters;
    }

    override protected void parse()
    {
        string key, value;
        foreach (string k,string v ; parameters) {
            key = k;
            value =v;
            if (key.startsWith("--")) {
                addLongOption(key.substring(2), value);
            } else if (k.startsWith("-")) {
                addShortOption(key.substring(1), value);
            } else {
                addArgument(key, value);
            }
        }
    }

    private void addShortOption(string shortcut, string value)
    {
        if (!definition.hasShortcut(shortcut)) {
            throw new InvalidArgumentException(format("The '-%s' option does not exist.", shortcut));
        }

        addLongOption(definition.getOptionForShortcut(shortcut).getName(), value);
    }

    private void addLongOption(string name, string value)
    {
        if (!definition.hasOption(name)) {
            throw new InvalidArgumentException(format("The '--%s' option does not exist.", name));
        }

        InputOption option = definition.getOption(name);

        if (value is null) {
            if (option.isValueRequired()) {
                throw new InvalidArgumentException(format("The '--%s' option requires a value.", name));
            }

            value = option.isValueOptional() ? option.getDefaultValue() : "true";
        }

        options.put(name, value);
    }

    private void addArgument(string name, string value)
    {
        if (!definition.hasArgument(name)) {
            throw new InvalidArgumentException(format("The '%s' argument does not exist.", name));
        }

        arguments.put(name, value);
    }

    /* override */ public string getFirstArgument()
    {
        foreach (string k ,string v ; parameters) {
            if (k.startsWith("-")) {
                continue;
            }
            return v;
        }

        return null;
    }

    /* override */ public bool hasParameterOption(string[] values...)
    {
        foreach (string k ,string v ; parameters) {
            foreach (string value ; values) {
                if (k == value) {
                    return true;
                }
            }
        }

        return false;
    }

    /* override */ public string getParameterOption(string value)
    {
        return getParameterOption(value, null);
    }

    /* override */ public string getParameterOption(string value, string defaultValue)
    {
        foreach (string k , string v ; parameters) {
            if (k == value) {
                return v;
            }
        }

        return defaultValue;
    }
}
