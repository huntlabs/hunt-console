module hunt.console.helper.HelperSet;

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
        helpers = new HashMap!(string, Helper)();
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
        if (aliasName != null) {
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
            throw new InvalidArgumentException(string.format("The helper '%s' is not defined.", name));
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

    public Iterator!(Helper) iterator()
    {
        return helpers.values().iterator();
    }
}
