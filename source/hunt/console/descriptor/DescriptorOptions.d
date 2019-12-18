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

module hunt.console.descriptor.DescriptorOptions;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.util.Common;

class DescriptorOptions : Cloneable
{
    private Map!(string, string) _options;


    public this()
    {
        _options = new HashMap!(string, string)();
    }

    private this(DescriptorOptions options)
    {
        _options = new HashMap!(string, string)();
        this._options.putAll(options._options);
    }

    public DescriptorOptions set(string name, string value)
    {
        return set(name, value, true);
    }

    public DescriptorOptions set(string name, string value, bool overwrite)
    {
        if (overwrite || !_options.containsKey(name)) {
            _options.put(name, value);
        }

        return this;
    }

    public string get(string name)
    {
        return _options.get(name);
    }

    public bool has(string name)
    {
        return _options.containsKey(name);
    }

    public Object clone()
    {
      return cast(Object)_options;
    }
}
