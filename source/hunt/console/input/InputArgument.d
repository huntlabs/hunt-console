module hunt.console.input.InputArgument;

import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;

class InputArgument
{
    public static int REQUIRED = 1;
    public static int OPTIONAL = 2;
    public static int IS_ARRAY = 4;

    private string name;
    private int mode;
    private string description;
    private string defaultValue;

    public this(string name)
    {
        this(name, OPTIONAL, null, null);
    }

    public this(string name, int mode)
    {
        this(name, mode, null, null);
    }

    public this(string name, int mode, string description)
    {
        this(name, mode, description, null);
    }

    public this(string name, int mode, string description, string defaultValue)
    {
        if (mode > 7 || mode < 1) {
            throw new InvalidArgumentException("Argument mode " + mode + " is not valid.");
        }

        this.name = name;
        this.mode = mode;
        this.description = description;

        setDefaultValue(defaultValue);
    }

    public string getName()
    {
        return name;
    }

    public bool isRequired()
    {
        return (mode & REQUIRED) == REQUIRED;
    }

    public bool isArray()
    {
        return (mode & IS_ARRAY) == IS_ARRAY;
    }

    public void setDefaultValue(string defaultValue)
    {
        if (mode == REQUIRED && defaultValue != null) {
            throw new LogicException("Cannot set a default value except for InputArgument.OPTIONAL mode.");
        }

        if (isArray()) {
            // todo implement
        }

        this.defaultValue = defaultValue;
    }

    public string getDefaultValue()
    {
        return defaultValue;
    }

    public string getDescription()
    {
        return description;
    }
}
