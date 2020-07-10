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
 
module hunt.console.input.ArgvInput;

import std.algorithm.searching;
import std.string;
import std.conv;
import hunt.collection.ArrayList;
// import hunt.collection.Arrays;
import hunt.collection.List;
import hunt.console.input.AbstractInput;
import hunt.console.input.InputDefinition;
import hunt.text.Common;
import hunt.Exceptions;
import hunt.console.input.InputArgument;
import hunt.console.input.InputOption;

import hunt.logging.ConsoleLogger;

import std.range;


/**
 * 
 */
class ArgvInput : AbstractInput
{
    private List!(string) tokens;
    private List!(string) parsed;

    this(string[] args)
    {
        this(args, null);
    }

    this(string[] args, InputDefinition definition)
    {
        this(new ArrayList!(string)(args), definition);
    }

    this(List!(string) args, InputDefinition definition)
    {
        tokens = args;

        if (definition is null) {
            this.definition = new InputDefinition();
        } else {
            bind(definition);
            validate();
        }
    }

    protected void setTokens(List!(string) tokens)
    {
        this.tokens = tokens;
    }

    override protected void parse()
    {
        bool parseOptions = true;
        parsed = tokens;
        while(parsed.size() > 0) {
            string token = parsed.removeAt(0);
            if (parseOptions && token == ("")) {
                parseArgument(token);
            } else if (parseOptions && token == ("--")) {
                parseOptions = false;
            } else if (parseOptions && token.startsWith("--")) {
                parseLongOption(token);
            } else if (parseOptions && token[0] == '-' && !(token == ("-"))) {
                parseShortOption(token);
            } else {
                parseArgument(token);
            }
        }
    }

    /**
     * Parses a short option.
     */
    private void parseShortOption(string token)
    {
        string option = token[1 .. $];
        version(HUNT_CONSOLE_DEBUG) {
            tracef("option: %s", option);
        }

        if (option.length > 1) {
            string name = format("%c", option[0]);
            if (definition.hasShortcut(name) && definition.getOptionForShortcut(name).acceptValue()) {
                // an option with a value (with no space)
                option = option[1..$];
                if(option[0] == '=') {
                    option = option[1..$]; // skip the '=';
                }
                addShortOption(name, option);
            } else {
                parseShortOptionSet(option);
            }
        } else {
            addShortOption(option, null);
        }
    }

    private void parseShortOptionSet(string options)
    {
        int len = cast(int)(options.length);
        string name;
        for (int i = 0; i < len; i++) {
            name = to!string(options[i]);
            if (!definition.hasShortcut(name)) {
                throw new RuntimeException(format("The '-%s' option does not exist.", name));
            }

            InputOption option = definition.getOptionForShortcut(name);
            if (option.acceptValue()) {
                addLongOption(option.getName(), i == len - 1 ? null : options.substring(i + 1));
                break;
            } else {
                addLongOption(option.getName(), null);
            }
        }
    }

    private void parseLongOption(string token)
    {
        string option = token.substring(2);

        int pos = cast(int)(option.indexOf('='));
        if (pos > -1) {
            addLongOption(option.substring(0, pos), option.substring(pos + 1));
        } else {
            addLongOption(option, null);
        }
    }

    private void parseArgument(string token)
    {
        int c = arguments.size();

        // if input is expecting another argument, add it
        if (definition.hasArgument(c)) {
            InputArgument argument = definition.getArgument(c);
            // todo array arguments
            arguments.put(argument.getName(), token);

        // if last argument isArray(), append token to last argument
        } else if (definition.hasArgument(c - 1) && definition.getArgument(c - 1).isArray()) {
            InputArgument argument = definition.getArgument(c - 1);
            // todo implement

        // unexpected argument
        } else {
            throw new RuntimeException("Too many arguments");
        }
    }

    private void addShortOption(string shortcut, string value)
    {
        if (!definition.hasShortcut(shortcut)) {
            throw new RuntimeException(format("The '-%s' option does not exist.", shortcut));
        }

        addLongOption(definition.getOptionForShortcut(shortcut).getName(), value);
    }

    private void addLongOption(string name, string value)
    {
        version(HUNT_CONSOLE_DEBUG) {
            warningf("%s, %s", name, value);
        }

        if (!definition.hasOption(name)) {
            throw new RuntimeException(format("The '--%s' option does not exist.", name));
        }

        InputOption option = definition.getOption(name);

        if (value !is null && !option.acceptValue()) {
            throw new RuntimeException(format("The '--%s' option does not accept a value.", name));
        }

        if (value is null && option.acceptValue() && parsed.size() > 0) {
            // if option accepts an optional or mandatory argument
            // let's see if there is one provided
            string next = parsed.removeAt(0);
            if (!next.isEmpty && next[0] != '-') {
                value = next;
            } else if (next.isEmpty()) {
                value = "";
            } else {
                parsed.add(0, next);
            }
        }

        if (value is null) {
            if (option.isValueRequired()) {
                throw new RuntimeException(format("The '--%s' option requires a value.", name));
            }

            if (!option.isArray()) {
                value = option.isValueOptional() ? option.getDefaultValue() : "true";
            }
        }

        if (option.isArray()) {
            // todo implement
        } else {
            options.put(name, value);
        }
    }

    /**
     * Returns the first argument from the raw parameters (not parsed).
     */
    override string getFirstArgument()
    {
        foreach (string token ; tokens) {
            if (!token.isEmpty() && token[0] == '-') {
                continue;
            }

            return token;
        }

        return null;
    }
    

    /**
     * Returns true if the raw parameters (not parsed) contain a value.
     *
     * This method is to be used to introspect the input parameters
     * before they have been validated. It must be used carefully.
     */
    override bool hasParameterOption(string[] values, bool onlyParams = false)
    {
        foreach (string token ; tokens) {
            if(onlyParams && token == "--") return false;

            foreach (string value ; values) {
                // Options with values:
                //   For long options, test for '--option=' at beginning
                //   For short options, test for '-o' at beginning
                ptrdiff_t index = value.indexOf("--");
                string leading = index == 0 ? value ~ "=" : value;

                if (token == value || (!leading.empty() && token.indexOf(leading) == 0)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Returns the value of a raw option (not parsed).
     *
     * This method is to be used to introspect the input parameters
     * before they have been validated. It must be used carefully
     */
    override string getParameterOption(string[] values, string defaultValue, bool onlyParams = false)
    {
        List!(string) tokens = new ArrayList!(string)(this.tokens);
        string token;

        while(tokens.size() > 0) {
            token = tokens.removeAt(0);
            if(onlyParams && token == "--") return defaultValue;

            foreach(string value; values) {
                if(token == value) {
                    return tokens.removeAt(0);
                }
                // Options with values:
                //   For long options, test for '--option=' at beginning
                //   For short options, test for '-o' at beginning
                ptrdiff_t index = value.indexOf("--");
                string leading = index == 0 ? value ~ "=" : value;

                if (!leading.empty() && token.indexOf(leading) == 0) {
                    return token[leading.length .. $];
                }
            }
        }

        return defaultValue;
    }

    override string toString()
    {
        return "ArgvInput{" ~
                "tokens=" ~ tokens.toString() ~
                '}';
    }
}
