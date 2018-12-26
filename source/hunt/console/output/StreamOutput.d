module hunt.console.output.StreamOutput;

import hunt.console.formatter.OutputFormatter;

import hunt.io.OutputStream;
import hunt.io.PrintWriter;

class StreamOutput : AbstractOutput
{
    private OutputStream stream;
    private PrintWriter writer;

    public StreamOutput(OutputStream stream)
    {
        super();
        initialize(stream);
    }

    public StreamOutput(OutputStream stream, Verbosity verbosity)
    {
        super(verbosity);
        initialize(stream);
    }

    public StreamOutput(OutputStream stream, Verbosity verbosity, boolean decorated)
    {
        super(verbosity, decorated);
        initialize(stream);
    }

    public StreamOutput(OutputStream stream, Verbosity verbosity, boolean decorated, OutputFormatter formatter)
    {
        super(verbosity, decorated, formatter);
        initialize(stream);
    }

    public OutputStream getStream()
    {
        return stream;
    }

    private void initialize(OutputStream stream)
    {
        this.stream = stream;
        writer = new PrintWriter(stream);
    }

    override protected void doWrite(string message, boolean newline)
    {
        writer.print(message);

        if (newline) {
            writer.println();
        }

        writer.flush();
    }
}
