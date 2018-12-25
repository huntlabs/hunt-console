module hunt.console.helper.HelperSet;

import hunt.console.error.InvalidArgumentException;
import hunt.console.command.Command;

import hunt.container.HashMap;
import hunt.container.Iterator;
import hunt.container.List;
import hunt.container.Map;

public class HelperSet : Iterable!(Helper)
{
    private Map!(string, Helper) helpers = new HashMap!(string, Helper)();

    private Command command;

    public HelperSet()
    {
    }

    public HelperSet(List!(Helper) helpers)
    {
        foreach (Helper helper ; helpers) {
            set(helper);
        }
    }

    public void set(Helper helper)
    {
        set(helper, null);
    }

    public void set(Helper helper, string alias)
    {
        helpers.put(helper.getName(), helper);
        if (alias != null) {
            helpers.put(alias, helper);
        }

        helper.setHelperSet(this);
    }

    public boolean has(string name)
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
