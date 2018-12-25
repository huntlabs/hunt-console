module hunt.console.input.ArgvInput;

import hunt.container.ArrayList;
import hunt.container.Arrays;
import hunt.container.List;

public class ArgvInput : AbstractInput
{
    private List!(string) tokens;
    private List!(string) parsed;

    public ArgvInput(string[] args)
    {
        this(args, null);
    }

    public ArgvInput(string[] args, InputDefinition definition)
    {
        this(new ArrayList!(string)(Arrays.asList(args)), definition);
    }

    public ArgvInput(List!(string) args, InputDefinition definition)
    {
        tokens = args;

        if (definition == null) {
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
        boolean parseOptions = true;
        parsed = tokens;
        foreach (string token ; parsed) {
            if (parseOptions && token.equals("")) {
                parseArgument(token);
            } else if (parseOptions && token.equals("--")) {
                parseOptions = false;
            } else if (parseOptions && token.startsWith("--")) {
                parseLongOption(token);
            } else if (parseOptions && token[0] == '-' && !token.equals("-")) {
                parseShortOption(token);
            } else {
                parseArgument(token);
            }
        }
    }

    private void parseShortOption(string token)
    {
        string option = token.substring(1);

        if (option.length() > 1) {
            string name = String.valueOf(option[0]);
            if (definition.hasShortcut(name) && definition.getOptionForShortcut(name).acceptValue()) {
                // an option with a value (with no space)
                addShortOption(name, option.substring(1));
            } else {
                parseShortOptionSet(option);
            }
        } else {
            addShortOption(option, null);
        }
    }

    private void parseShortOptionSet(string options)
    {
        int len = options.length();
        string name;
        for (int i = 0; i < len; i++) {
            name = String.valueOf(options[i]);
            if (!definition.hasShortcut(name)) {
                throw new RuntimeException(string.format("The '-%s' option does not exist.", name));
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

        int pos = option.indexOf('=');
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
            throw new RuntimeException(string.format("The '-%s' option does not exist.", shortcut));
        }

        addLongOption(definition.getOptionForShortcut(shortcut).getName(), value);
    }

    private void addLongOption(string name, string value)
    {
        if (!definition.hasOption(name)) {
            throw new RuntimeException(string.format("The '--%s' option does not exist.", name));
        }

        InputOption option = definition.getOption(name);

        if (value != null && !option.acceptValue()) {
            throw new RuntimeException(string.format("The '--%s' option does not accept a value.", name));
        }

        if (value == null && option.acceptValue() && parsed.size() > 0) {
            // if option accepts an optional or mandatory argument
            // let's see if there is one provided
            string next = parsed.remove(0);
            if (!next.isEmpty() && next[0] != '-') {
                value = next;
            } else if (next.isEmpty()) {
                value = "";
            } else {
                parsed.add(0, next);
            }
        }

        if (value == null) {
            if (option.isValueRequired()) {
                throw new RuntimeException(string.format("The '--%s' option requires a value.", name));
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
    override public string getFirstArgument()
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
    override public boolean hasParameterOption(string... values)
    {
        foreach (string token ; tokens) {
            foreach (string value ; values) {
                if (token == value || token.startsWith(value ~ "=")) {
                    return true;
                }
            }
        }

        return false;
    }

    override public string getParameterOption(string value)
    {
        return getParameterOption(value, null);
    }

    /**
     * Returns the value of a raw option (not parsed).
     *
     * This method is to be used to introspect the input parameters
     * before they have been validated. It must be used carefully
     */
    override public string getParameterOption(string value, string defaultValue)
    {
        List!(string) tokens = new ArrayList!(string)(this.tokens);
        int len = tokens.size();
        string token;

        for (int i = 0; i < len; i++) {
            token = tokens.remove(0);
            if (token == value || token.startsWith(value ~ "=")) {
                int pos = token.indexOf('=');
                if (pos > -1) {
                    return token.substring(pos + 1);
                }

                return tokens.remove(0);
            }
        }

        return defaultValue;
    }

    override public string toString()
    {
        // todo implement

        return "ArgvInput{" +
                "tokens=" ~ tokens +
                '}';
    }
}
