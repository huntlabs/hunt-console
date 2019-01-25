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
 
module hunt.console.helper.HelperSet;

import std.string;

import hunt.console.error.InvalidArgumentException;
import hunt.console.command.Command;

import hunt.collection.HashMap;
import hunt.collection.Iterator;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.util.Common;
import hunt.console.helper.Helper;

class HelperSet : Iterable!(Helper)
{
    private Map!(string, Helper) helpers;

    private Command command;

    public this()
    {
        helpers = new HashMap!(string, Helper)();
    }

    public this(List!(Helper) helpers)
    {
        this.helpers = new HashMap!(string, Helper)();
        foreach (Helper helper ; helpers) {
            set(helper);
        }
    }

    public void set(Helper helper)
    {
        set(helper, null);
    }

    public void set(Helper helper, string aliasName)
    {
        helpers.put(helper.getName(), helper);
        if (aliasName !is null) {
            helpers.put(aliasName, helper);
        }

        helper.setHelperSet(this);
    }

    public bool has(string name)
    {
        return helpers.containsKey(name);
    }

    public Helper get(string name)
    {
        if (!has(name)) {
            throw new InvalidArgumentException(format("The helper '%s' is not defined.", name));
        }

        return helpers.get(name);
    }

    public Command getCommand()
    {
        return command;
    }

    public void setCommand(Command command)
    {
        this.command = command;
    }

    // public Iterator!(Helper) iterator()
    // {
    //     return helpers.byValue;
    // }
    override int opApply(scope int delegate(ref Helper) dg) {
        int result = 0;
        foreach (Helper v; helpers.byValue) {
            result = dg(v);
            if (result != 0)
                return result;
        }
        return result;
    }
}
