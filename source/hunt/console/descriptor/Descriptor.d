module hunt.console.descriptor.Descriptor;

import hunt.console.output.Output;

public interface Descriptor
{
    public void describe(Output output, Object object);

    public void describe(Output output, Object object, DescriptorOptions options);
}
