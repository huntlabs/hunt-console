module hunt.console.output.AbstractOutput;

import hunt.console.error.InvalidArgumentException;
import hunt.console.formatter.DefaultOutputFormatter;
import hunt.console.formatter.OutputFormatter;
import hunt.console.output.Output;
import hunt.console.output.Verbosity;
import hunt.console.output.OutputType;

import std.string;
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

    public this()
    {
        this(Verbosity.NORMAL);
    }

    public this(Verbosity verbosity)
    {
        this(verbosity, true);
    }

    public this(Verbosity verbosity, bool decorated)
    {
        this(verbosity, decorated, new DefaultOutputFormatter());
    }

    public this(Verbosity verbosity, bool decorated, OutputFormatter formatter)
    {
        this.verbosity = verbosity;
        this.formatter = formatter;
        this.formatter.setDecorated(decorated);
    }

    /* override */ public void setFormatter(OutputFormatter formatter)
    {
        this.formatter = formatter;
    }

    /* override */ public OutputFormatter getFormatter()
    {
        return formatter;
    }

    override public void setDecorated(bool decorated)
    {
        formatter.setDecorated(decorated);
    }

    override public bool isDecorated()
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

    public bool isQuiet()
    {
        return verbosity == Verbosity.QUIET;
    }

    public bool isVerbose()
    {
        return cast(int)verbosity >= cast(int)(Verbosity.VERBOSE);
    }

    public bool isVeryVerbose()
    {
        return cast(int)(verbosity) >= cast(int)(Verbosity.VERY_VERBOSE);
    }

    public bool isDebug()
    {
        return cast(int)(verbosity) >= cast(int)(Verbosity.DEBUG);
    }

    override public void write(string message)
    {
        write(message, false);
    }

    override public void write(string message, bool newline)
    {
        write(message, newline, OutputType.NORMAL);
    }

    override public void write(string message, bool newline, OutputType type)
    {
        if (isQuiet()) {
            return;
        }

        switch (type) with(OutputType){
            case NORMAL:
                message = formatter.format(message);
                break;
            case RAW:
                break;
            case PLAIN:
                // todo strip < > tags
                break;
            default:
                throw new InvalidArgumentException(format("Unknown output type given (%s)", type));
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
    abstract protected void doWrite(string message, bool newline);
}
