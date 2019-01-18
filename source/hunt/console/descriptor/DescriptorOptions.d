module hunt.console.descriptor.DescriptorOptions;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.util.Common;

class DescriptorOptions : Cloneable
{
    private Map!(string, string) options;


    public this()
    {
        options = new HashMap!(string, string)();
    }

    private this(DescriptorOptions options)
    {
        options = new HashMap!(string, string)();
        this.options.putAll(options.options);
    }

    public DescriptorOptions set(string name, string value)
    {
        return set(name, value, true);
    }

    public DescriptorOptions set(string name, string value, bool overwrite)
    {
        if (overwrite || !options.containsKey(name)) {
            options.put(name, value);
        }

        return this;
    }

    public string get(string name)
    {
        return options.get(name);
    }

    public bool has(string name)
    {
        return options.containsKey(name);
    }
}
