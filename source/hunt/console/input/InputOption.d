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
 
module hunt.console.input.InputOption;

import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.util.StringUtils;
import hunt.text.Common;
import std.string;
import hunt.Exceptions;
import std.conv;

class InputOption
{
    enum int VALUE_NONE = 1;
    enum int VALUE_REQUIRED = 2;
    enum int VALUE_OPTIONAL = 4;
    enum int VALUE_IS_ARRAY = 8;

    private string name;
    private string shortcut;
    private int mode;
    private string description;
    private string defaultValue;

    this(string name)
    {
        this(name, null, VALUE_NONE, null, null);
    }

    this(string name, string shortcut)
    {
        this(name, shortcut, VALUE_NONE, null, null);
    }

    this(string name, string shortcut, int mode)
    {
        this(name, shortcut, mode, null, null);
    }

    this(string name, string shortcut, int mode, string description)
    {
        this(name, shortcut, mode, description, null);
    }

    this(string name, string shortcut, int mode, string description, string defaultValue)
    {
        if (name.startsWith("--")) {
            name = name.substring(2);
        }

        if (name.isEmpty()) {
            throw new InvalidArgumentException("An option name cannot be empty.");
        }

        if (shortcut !is null && shortcut.isEmpty()) {
            shortcut = null;
        }

        if (shortcut !is null) {
            shortcut = StringUtils.ltrim(shortcut, '-');
            if (shortcut.isEmpty()) {
                throw new IllegalArgumentException("An option shortcut cannot be empty.");
            }
        }

        if (mode > 15 || mode < 1) {
            throw new InvalidArgumentException("Option mode " ~ mode.to!string ~ " is not valid");
        }

        this.name = name;
        this.shortcut = shortcut;
        this.mode = mode;
        this.description = description;

        setDefaultValue(defaultValue);
    }

    string getShortcut()
    {
        return shortcut;
    }

    string getName()
    {
        return name;
    }

    bool acceptValue()
    {
        return isValueRequired() || isValueOptional();
    }

    bool isValueRequired()
    {
        return (mode & VALUE_REQUIRED) == VALUE_REQUIRED;
    }

    bool isValueOptional()
    {
        return (mode & VALUE_OPTIONAL) == VALUE_OPTIONAL;
    }

    bool isArray()
    {
        return (mode & VALUE_IS_ARRAY) == VALUE_IS_ARRAY;
    }

    void setDefaultValue(string defaultValue)
    {
        if ((mode & VALUE_NONE) == VALUE_NONE && defaultValue !is null) {
            throw new LogicException("Cannot set a default value when using InputOption.VALUE_NONE mode.");
        }

        if (isArray()) {
            // todo implement
        }

        this.defaultValue = acceptValue() ? defaultValue : null;
    }

    string getDefaultValue()
    {
        return defaultValue;
    }

    string getDescription()
    {
        return description;
    }

    override bool opEquals(Object o)
    {
        if (this is o) return true;
        if (!(cast(InputOption)o !is null)) return false;

        InputOption that =cast(InputOption) o;

        if (isArray() != that.isArray()) return false;
        if (isValueRequired() != that.isValueRequired()) return false;
        if (isValueOptional() != that.isValueOptional()) return false;
        if (defaultValue !is null ? !(defaultValue == that.defaultValue) : that.defaultValue !is null) return false;
        if (name !is null ? !(name == that.name) : that.name !is null) return false;
        if (shortcut !is null ? !(shortcut == that.shortcut) : that.shortcut !is null) return false;

        return true;
    }

    override size_t toHash() @trusted nothrow
    {
        int result = name !is null ? cast(int)(name.hashOf()) : 0;
        result = 31 * result + (shortcut !is null ? cast(int)(shortcut.hashOf()) : 0);
        result = 31 * result + mode;
        result = 31 * result + (description !is null ? cast(int)(description.hashOf()) : 0);
        result = 31 * result + (defaultValue !is null ? cast(int)(defaultValue.hashOf()) : 0);
        return result;
    }
}
