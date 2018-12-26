module hunt.console.helper.DescriptorHelper;

import hunt.console.descriptor.MarkdownDescriptor;
import hunt.console.error.InvalidArgumentException;
import hunt.console.descriptor.Descriptor;
import hunt.console.descriptor.DescriptorOptions;
import hunt.console.descriptor.TextDescriptor;
import hunt.console.output.Output;

import hunt.container.HashMap;
import hunt.container.Map;

class DescriptorHelper : AbstractHelper
{
    private Map!(string, Descriptor) descriptors = new HashMap!(string, Descriptor)();

    public DescriptorHelper()
    {
        register("txt", new TextDescriptor());
        register("md", new MarkdownDescriptor());
    }

    public void describe(Output output, Object object, DescriptorOptions options)
    {
        options.set("raw_text", Boolean.FALSE.toString(), false);
        options.set("format", "txt", false);

        if (!descriptors.containsKey(options.get("format"))) {
            throw new InvalidArgumentException(string.format("Unsupported format '%s'.", options.get("format")));
        }

        Descriptor descriptor = descriptors.get(options.get("format"));
        descriptor.describe(output, object, options);
    }

    private DescriptorHelper register(string format, Descriptor descriptor)
    {
        descriptors.put(format, descriptor);

        return this;
    }

    override public string getName()
    {
        return "descriptor";
    }
}
