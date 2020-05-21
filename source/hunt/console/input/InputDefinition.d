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
 
module hunt.console.input.InputDefinition;

import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;

import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.collection.HashMap;
import hunt.console.input.InputArgument;
import hunt.console.input.InputOption;
import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.util.StringBuilder;
import hunt.Integer;
import std.string;

class InputDefinition
{
    private Map!(string, InputArgument) arguments;

    private int requiredCount;

    private bool hasAnArrayArgument = false;

    private bool hasOptional;

    private Map!(string, InputOption) options;

    private Map!(string, string) shortcuts;

    public this()
    {
        arguments = new LinkedHashMap!(string, InputArgument)();
         options = new HashMap!(string, InputOption)();
         shortcuts = new HashMap!(string, string)();
        resetArguments();
    }

    private void resetArguments()
    {
        arguments = new LinkedHashMap!(string, InputArgument)();
        requiredCount = 0;
        hasAnArrayArgument = false;
        hasOptional = false;
    }

    public void setArguments(Collection!(InputArgument) arguments)
    {
        setArguments(new ArrayList!(InputArgument)(arguments));
    }

    public void setArguments(List!(InputArgument) arguments)
    {
        resetArguments();
        addArguments(arguments);
    }

    public void addArguments(Collection!(InputArgument) arguments)
    {
        addArguments(new ArrayList!(InputArgument)(arguments));
    }

    public void addArguments(List!(InputArgument) arguments)
    {
        foreach (InputArgument argument ; arguments) {
            addArgument(argument);
        }
    }

    public void addArgument(InputArgument argument)
    {
        if (arguments.containsKey(argument.getName())) {
            throw new LogicException(format("An argument with name '%s' already exists.", argument.getName()));
        }

        if (hasAnArrayArgument) {
            throw new LogicException("Cannot add an argument after an array argument.");
        }

        if (argument.isRequired() && hasOptional) {
            throw new LogicException("Cannot add a required argument after an optional one.");
        }

        if (argument.isArray()) {
            hasAnArrayArgument = true;
        }

        if (argument.isRequired()) {
            ++requiredCount;
        } else {
            hasOptional = true;
        }

        arguments.put(argument.getName(), argument);
    }

    public InputArgument getArgument(string name)
    {
        if (!hasArgument(name)) {
            throw new InvalidArgumentException(format("The '%s' argument does not exist.", name));
        }

        return arguments.get(name);
    }

    public InputArgument getArgument(int pos)
    {
        return cast(InputArgument) (arguments.values()[pos]);
    }

    public bool hasArgument(string name)
    {
        return arguments.containsKey(name);
    }

    public bool hasArgument(int pos)
    {
        return arguments.size() > pos;
    }

    public Collection!InputArgument getArguments()
    {
        return new ArrayList!InputArgument(arguments.values());
    }

    public int getArgumentCount()
    {
        return hasAnArrayArgument ? Integer.MAX_VALUE : arguments.size();
    }

    public int getArgumentRequiredCount()
    {
        return requiredCount;
    }

    public Map!(string, string) getArgumentDefaults()
    {
        HashMap!(string, string) defaultValues = new LinkedHashMap!(string, string)();
        foreach (InputArgument argument ; arguments.values()) {
            defaultValues.put(argument.getName(), argument.getDefaultValue());
        }

        return defaultValues;
    }

    public void setOptions(Collection!(InputOption) options)
    {
        setOptions(new ArrayList!(InputOption)(options));
    }

    public void setOptions(List!(InputOption) options)
    {
        this.options = new HashMap!(string, InputOption)();
        this.shortcuts = new HashMap!(string, string)();
        addOptions(options);
    }

    public void addOptions(Collection!(InputOption) options)
    {
        addOptions(new ArrayList!(InputOption)(options));
    }

    public void addOptions(List!(InputOption) options)
    {
        foreach (InputOption option ; options) {
            addOption(option);
        }
    }

    public void addOption(InputOption option)
    {
        if (options.containsKey(option.getName()) && !(option == options.get(option.getName()))) {
            throw new LogicException(format("An option named '%s' already exists.", option.getName()));
        }

        if (option.getShortcut() !is null) {
            foreach (string shortcut ; option.getShortcut().split("\\|")) {
                if (shortcuts.containsKey(shortcut) && !(option == options.get(shortcuts.get(shortcut)))) {
                    throw new LogicException(format("An option with shortcut '%s' already exists.", shortcut));
                }
            }
        }

        options.put(option.getName(), option);

        if (option.getShortcut() !is null) {
            foreach (string shortcut ; option.getShortcut().split("|")) {
                shortcuts.put(shortcut, option.getName());
            }
        }
    }

    public InputOption getOption(string name)
    {
        if (!hasOption(name)) {
            throw new InvalidArgumentException(format("The '--%s' option does not exist.", name));
        }

        return options.get(name);
    }

    public bool hasOption(string name)
    {
        return options.containsKey(name);
    }

    public Collection!(InputOption) getOptions()
    {
        return new ArrayList!(InputOption)(options.values());
    }

    public bool hasShortcut(string name)
    {
        return shortcuts.containsKey(name);
    }

    public InputOption getOptionForShortcut(string shortcut)
    {
        return getOption(shortcutToName(shortcut));
    }

    public Map!(string, string) getOptionDefaults()
    {
        HashMap!(string, string) defaultValues = new HashMap!(string, string)();
        foreach (InputOption option ; options.values()) {
            defaultValues.put(option.getName(), option.getDefaultValue());
        }

        return defaultValues;
    }

    private string shortcutToName(string shortcut)
    {
        if (!shortcuts.containsKey(shortcut)) {
            throw new InvalidArgumentException(format("The '-%s' option does not exist.", shortcut));
        }

        return shortcuts.get(shortcut);
    }

    public string getSynopsis()
    {
        StringBuilder synopsis = new StringBuilder();

        string shortcut;
        foreach (InputOption option ; options.values()) {
            shortcut = option.getShortcut() is null ? "" : (format("-%s|", option.getShortcut()));
            synopsis.append(format("[" ~ (option.isValueRequired() ? "%s--%s='...'" : (option.isValueOptional() ? "%s--%s[='...']" : "%s--%s")) ~ "] ", shortcut, option.getName()));
        }

        foreach (InputArgument argument ; arguments.values()) {
            synopsis.append(format(argument.isRequired() ? "%s " : "[%s] ", argument.getName() ~ (argument.isArray() ? "1" : "")));
            if (argument.isArray()) {
                synopsis.append(format("... [%sN]", argument.getName()));
            }
        }

        return synopsis.toString().strip();
    }

    public string asText()
    {
        // todo implement

        return null;
    }

    public string asXml()
    {
        // todo implement

        return null;
    }
}
