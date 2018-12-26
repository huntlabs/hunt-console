module hunt.console.descriptor.DescriptorOptions;

import hunt.container.HashMap;
import hunt.container.Map;

class DescriptorOptions : Cloneable
{
    private Map!(string, string) options = new HashMap!(string, string)();

    public DescriptorOptions()
    {
    }

    private DescriptorOptions(DescriptorOptions options)
    {
        this.options.putAll(options.options);
    }

    public DescriptorOptions set(string name, string value)
    {
        return set(name, value, true);
    }

    public DescriptorOptions set(string name, string value, boolean overwrite)
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

    public boolean has(string name)
    {
        return options.containsKey(name);
    }
}
