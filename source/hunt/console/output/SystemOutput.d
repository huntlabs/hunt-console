module hunt.console.output.SystemOutput;

import hunt.console.formatter.OutputFormatter;

public class SystemOutput : StreamOutput : ConsoleOutput
{
    private Output stderr;

    public SystemOutput()
    {
        super(System.out);
        initialize();
    }

    public SystemOutput(Verbosity verbosity)
    {
        super(System.out, verbosity);
        initialize();
    }

    public SystemOutput(Verbosity verbosity, boolean decorated)
    {
        super(System.out, verbosity, decorated);
    }

    public SystemOutput(Verbosity verbosity, boolean decorated, OutputFormatter formatter)
    {
        super(System.out, verbosity, decorated, formatter);
    }

    private void initialize()
    {
        this.stderr = new StreamOutput(System.err);
    }

    override public void setDecorated(boolean decorated)
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
