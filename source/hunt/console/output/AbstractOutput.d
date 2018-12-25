module hunt.console.output.AbstractOutput;

import hunt.console.error.InvalidArgumentException;
import hunt.console.formatter.DefaultOutputFormatter;
import hunt.console.formatter.OutputFormatter;

/**
 * Base class for output classes.
 *
 * There are five levels of verbosity:
 *
 *  * normal: no option passed (normal output)
 *  * verbose: -v (more output)
 *  * very verbose: -vv (highly extended output)
 *  * debug: -vvv (all debug output)
 *  * quiet: -q (no output)
 */
public abstract class AbstractOutput : Output
{
    private Verbosity verbosity;
    private OutputFormatter formatter;

    public AbstractOutput()
    {
        this(Verbosity.NORMAL);
    }

    public AbstractOutput(Verbosity verbosity)
    {
        this(verbosity, true);
    }

    public AbstractOutput(Verbosity verbosity, boolean decorated)
    {
        this(verbosity, decorated, new DefaultOutputFormatter());
    }

    public AbstractOutput(Verbosity verbosity, boolean decorated, OutputFormatter formatter)
    {
        this.verbosity = verbosity;
        this.formatter = formatter;
        this.formatter.setDecorated(decorated);
    }

    override public void setFormatter(OutputFormatter formatter)
    {
        this.formatter = formatter;
    }

    override public OutputFormatter getFormatter()
    {
        return formatter;
    }

    override public void setDecorated(boolean decorated)
    {
        formatter.setDecorated(decorated);
    }

    override public boolean isDecorated()
    {
        return formatter.isDecorated();
    }

    override public void setVerbosity(Verbosity verbosity)
    {
        this.verbosity = verbosity;
    }

    override public Verbosity getVerbosity()
    {
        return verbosity;
    }

    public boolean isQuiet()
    {
        return verbosity == Verbosity.QUIET;
    }

    public boolean isVerbose()
    {
        return verbosity.ordinal() >= Verbosity.VERBOSE.ordinal();
    }

    public boolean isVeryVerbose()
    {
        return verbosity.ordinal() >= Verbosity.VERY_VERBOSE.ordinal();
    }

    public boolean isDebug()
    {
        return verbosity.ordinal() >= Verbosity.DEBUG.ordinal();
    }

    override public void write(string message)
    {
        write(message, false);
    }

    override public void write(string message, boolean newline)
    {
        write(message, newline, OutputType.NORMAL);
    }

    override public void write(string message, boolean newline, OutputType type)
    {
        if (isQuiet()) {
            return;
        }

        switch (type) {
            case NORMAL:
                message = formatter.format(message);
                break;
            case RAW:
                break;
            case PLAIN:
                // todo strip < > tags
                break;
            default:
                throw new InvalidArgumentException(string.format("Unknown output type given (%s)", type));
        }

        doWrite(message, newline);
    }

    override public void writeln(string message)
    {
        write(message, true);
    }

    override public void writeln(string message, OutputType type)
    {
        write(message, true, type);
    }

    /**
     * Writes a message to the output.
     *
     * @param message A message to write to the output
     * @param newline Whether to add a newline or not
     */
    abstract protected void doWrite(string message, boolean newline);
}
