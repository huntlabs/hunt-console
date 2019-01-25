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
 
module hunt.console.descriptor.Descriptor;

import hunt.console.output.Output;
import hunt.console.descriptor.DescriptorOptions;

public interface Descriptor
{
    public void describe(Output output, Object object);

    public void describe(Output output, Object object, DescriptorOptions options);
}
