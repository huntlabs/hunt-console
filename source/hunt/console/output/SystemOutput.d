module hunt.console.output.SystemOutput;

import hunt.console.formatter.OutputFormatter;
import std.stdio;
import hunt.io.FileOutputStream;
import hunt.console.output.StreamOutput;
import hunt.console.output.Verbosity;
import hunt.console.output.Output;
import hunt.console.output.ConsoleOutput;

class SystemOutput : StreamOutput , ConsoleOutput
{
    private Output stderr;

    public this()
    {
        super(new FileOutputStream(stdout));
        initialize();
    }

    public this(Verbosity verbosity)
    {
        super(new FileOutputStream(stdout), verbosity);
        initialize();
    }

    public this(Verbosity verbosity, bool decorated)
    {
        super(new FileOutputStream(stdout), verbosity, decorated);
    }

    public this(Verbosity verbosity, bool decorated, OutputFormatter formatter)
    {
        super(new FileOutputStream(stdout), verbosity, decorated, formatter);
    }

    private void initialize()
    {
        this.stderr = new StreamOutput(System.err);
    }

    override public void setDecorated(bool decorated)
    {
        super.setDecorated(decorated);
        stderr.setDecorated(decorated);
    }

    override public void setFormatter(OutputFormatter formatter)
    {
        super.setFormatter(formatter);
        stderr.setFormatter(formatter);
    }

    override public void setVerbosity(Verbosity verbosity)
    {
        super.setVerbosity(verbosity);
        stderr.setVerbosity(verbosity);
    }

    override public Output getErrorOutput()
    {
        return stderr;
    }

    override public void setErrorOutput(Output error)
    {
        stderr = error;
    }
}
