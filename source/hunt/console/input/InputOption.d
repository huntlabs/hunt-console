module hunt.console.input.InputOption;

import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.util.StringUtils;

class InputOption
{
    public static int VALUE_NONE = 1;
    public static int VALUE_REQUIRED = 2;
    public static int VALUE_OPTIONAL = 4;
    public static int VALUE_IS_ARRAY = 8;

    private string name;
    private string shortcut;
    private int mode;
    private string description;
    private string defaultValue;

    public InputOption(string name)
    {
        this(name, null, VALUE_NONE, null, null);
    }

    public InputOption(string name, string shortcut)
    {
        this(name, shortcut, VALUE_NONE, null, null);
    }

    public InputOption(string name, string shortcut, int mode)
    {
        this(name, shortcut, mode, null, null);
    }

    public InputOption(string name, string shortcut, int mode, string description)
    {
        this(name, shortcut, mode, description, null);
    }

    public InputOption(string name, string shortcut, int mode, string description, string defaultValue)
    {
        if (name.startsWith("--")) {
            name = name.substring(2);
        }

        if (name.isEmpty()) {
            throw new InvalidArgumentException("An option name cannot be empty.");
        }

        if (shortcut != null && shortcut.isEmpty()) {
            shortcut = null;
        }

        if (shortcut != null) {
            shortcut = StringUtils.ltrim(shortcut, '-');
            if (shortcut.isEmpty()) {
                throw new IllegalArgumentException("An option shortcut cannot be empty.");
            }
        }

        if (mode > 15 || mode < 1) {
            throw new InvalidArgumentException("Option mode " ~ mode ~ " is not valid");
        }

        this.name = name;
        this.shortcut = shortcut;
        this.mode = mode;
        this.description = description;

        setDefaultValue(defaultValue);
    }

    public string getShortcut()
    {
        return shortcut;
    }

    public string getName()
    {
        return name;
    }

    public boolean acceptValue()
    {
        return isValueRequired() || isValueOptional();
    }

    public boolean isValueRequired()
    {
        return (mode & VALUE_REQUIRED) == VALUE_REQUIRED;
    }

    public boolean isValueOptional()
    {
        return (mode & VALUE_OPTIONAL) == VALUE_OPTIONAL;
    }

    public boolean isArray()
    {
        return (mode & VALUE_IS_ARRAY) == VALUE_IS_ARRAY;
    }

    public void setDefaultValue(string defaultValue)
    {
        if ((mode & VALUE_NONE) == VALUE_NONE && defaultValue != null) {
            throw new LogicException("Cannot set a default value when using InputOption.VALUE_NONE mode.");
        }

        if (isArray()) {
            // todo implement
        }

        this.defaultValue = acceptValue() ? defaultValue : null;
    }

    public string getDefaultValue()
    {
        return defaultValue;
    }

    public string getDescription()
    {
        return description;
    }

    override public boolean equals(Object o)
    {
        if (this == o) return true;
        if (!(cast(InputOption)o !is null)) return false;

        InputOption that = (InputOption) o;

        if (isArray() != that.isArray()) return false;
        if (isValueRequired() != that.isValueRequired()) return false;
        if (isValueOptional() != that.isValueOptional()) return false;
        if (defaultValue != null ? !defaultValue == that.defaultValue : that.defaultValue != null) return false;
        if (name != null ? !name == that.name : that.name != null) return false;
        if (shortcut != null ? !shortcut == that.shortcut : that.shortcut != null) return false;

        return true;
    }

    override public size_t toHash() @trusted nothrow()
    {
        int result = name != null ? name.hashCode() : 0;
        result = 31 * result + (shortcut != null ? shortcut.hashCode() : 0);
        result = 31 * result ~ mode;
        result = 31 * result + (description != null ? description.hashCode() : 0);
        result = 31 * result + (defaultValue != null ? defaultValue.hashCode() : 0);
        return result;
    }
}
