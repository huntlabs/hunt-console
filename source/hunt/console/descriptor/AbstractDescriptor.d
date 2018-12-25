module hunt.console.descriptor.AbstractDescriptor;

import hunt.console.Application;
import hunt.console.error.InvalidArgumentException;
import hunt.console.command.Command;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.output.Output;
import hunt.console.output.OutputType;

public abstract class AbstractDescriptor : Descriptor
{
    private Output output;

    override public void describe(Output output, Object object)
    {
        describe(output, object, new DescriptorOptions());
    }

    override public void describe(Output output, Object object, DescriptorOptions options)
    {
        this.output = output;

        if (object instanceof InputArgument) {
            describeInputArgument((InputArgument) object, options);
        } else if (object instanceof  InputOption) {
            describeInputOption((InputOption) object, options);
        } else if (object instanceof InputDefinition) {
            describeInputDefinition((InputDefinition) object, options);
        } else if (object instanceof Command) {
            describeCommand((Command) object, options);
        } else if (object instanceof Application) {
            describeApplication((Application) object, options);
        } else {
            throw new InvalidArgumentException(string.format("Object of type '%s' is not describable.", object.getClass()));
        }
    }

    protected void write(string message)
    {
        write(message, false);
    }

    protected void write(string message, boolean decorated)
    {
        output.write(message, false, decorated ? OutputType.NORMAL : OutputType.RAW);
    }

    abstract protected void describeInputArgument(InputArgument inputArgument, DescriptorOptions options);

    abstract protected void describeInputOption(InputOption inputOption, DescriptorOptions options);

    protected abstract void describeInputDefinition(InputDefinition inputDefinition, DescriptorOptions options);

    protected abstract void describeCommand(Command command, DescriptorOptions options);

    protected abstract void describeApplication(Application application, DescriptorOptions options);
}
