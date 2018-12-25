module hunt.console.output.NullOutput;

import hunt.console.formatter.DefaultOutputFormatter;
import hunt.console.formatter.OutputFormatter;

public class NullOutput : Output
{
    override public void write(string message)
    {
        // do nothing
    }

    override public void write(string message, boolean newline)
    {
        // do nothing
    }

    override public void write(string message, boolean newline, OutputType type)
    {
        // do nothing
    }

    override public void writeln(string message)
    {
        // do nothing
    }

    override public void writeln(string message, OutputType type)
    {
        // do nothing
    }

    override public void setVerbosity(Verbosity verbosity)
    {
        // do nothing
    }

    override public Verbosity getVerbosity()
    {
        return Verbosity.QUIET;
    }

    override public void setDecorated(boolean decorated)
    {
        // do nothing
    }

    override public boolean isDecorated()
    {
        return false;
    }

    override public void setFormatter(OutputFormatter formatter)
    {
        // do nothing
    }

    override public OutputFormatter getFormatter()
    {
        return new DefaultOutputFormatter();
    }

    public boolean isQuiet()
    {
        return true;
    }

    public boolean isVerbose()
    {
        return false;
    }

    public boolean isVeryVerbose()
    {
        return false;
    }

    public boolean isDebug()
    {
        return false;
    }
}
