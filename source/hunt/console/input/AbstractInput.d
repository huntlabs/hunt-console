module hunt.console.input.AbstractInput;

import hunt.console.error.InvalidArgumentException;

import hunt.container.HashMap;
import hunt.container.Map;

public abstract class AbstractInput : Input
{
    protected InputDefinition definition;
    protected Map!(string, string) options;
    protected Map!(string, string) arguments;
    protected boolean interactive = true;

    public AbstractInput()
    {
        this.definition = new InputDefinition();
    }

    public AbstractInput(InputDefinition definition)
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

    override public boolean isInteractive()
    {
        return interactive;
    }

    override public void setInteractive(boolean interactive)
    {
        this.interactive = interactive;
    }

    override public string[] getArguments()
    {
        Map!(string, string) argumentValues = definition.getArgumentDefaults();

        for (Map.Entry!(string, string) argument : arguments.entrySet()) {
            argumentValues.put(argument.getKey(), argument.getValue());
        }

        return (string[]) argumentValues.values().toArray();
    }

    override public string getArgument(string name)
    {
        if (!definition.hasArgument(name)) {
            throw new InvalidArgumentException(string.format("The '%s' argument does not exist.", name));
        }

        if (arguments.containsKey(name)) {
            return arguments.get(name);
        }

        return definition.getArgument(name).getDefaultValue();
    }

    override public void setArgument(string name, string value) throws InvalidArgumentException
    {
        if (!definition.hasArgument(name)) {
            throw new InvalidArgumentException(string.format("The '%s' argument does not exist.", name));
        }

        arguments.put(name, value);
    }

    override public boolean hasArgument(string name)
    {
        return definition.hasArgument(name);
    }

    override public string[] getOptions()
    {
        Map!(string, string) optionValues = definition.getOptionDefaults();

        for (Map.Entry!(string, string) option : options.entrySet()) {
            optionValues.put(option.getKey(), option.getValue());
        }

        return (string[]) optionValues.values().toArray();
    }

    override public string getOption(string name)
    {
        if (!definition.hasOption(name)) {
            throw new InvalidArgumentException(string.format("The '%s' option does not exist.", name));
        }

        if (options.containsKey(name)) {
            return options.get(name);
        }

        return definition.getOption(name).getDefaultValue();
    }

    override public void setOption(string name, string value) throws InvalidArgumentException
    {
        if (!definition.hasOption(name)) {
            throw new InvalidArgumentException(string.format("The '%s' option does not exist.", name));
        }

        options.put(name, value);
    }

    override public boolean hasOption(string name)
    {
        return definition.hasOption(name);
    }
}
