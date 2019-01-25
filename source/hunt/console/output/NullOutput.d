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
 
module hunt.console.output.NullOutput;

import hunt.console.formatter.DefaultOutputFormatter;
import hunt.console.formatter.OutputFormatter;
import hunt.console.output.Output;
import hunt.console.output.OutputType;
import hunt.console.output.Verbosity;

class NullOutput : Output
{
    override public void write(string message)
    {
        // do nothing
    }

    override public void write(string message, bool newline)
    {
        // do nothing
    }

    override public void write(string message, bool newline, OutputType type)
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

    override public void setDecorated(bool decorated)
    {
        // do nothing
    }

    override public bool isDecorated()
    {
        return false;
    }

    /* override */ public void setFormatter(OutputFormatter formatter)
    {
        // do nothing
    }

    /* override */ public OutputFormatter getFormatter()
    {
        return new DefaultOutputFormatter();
    }

    public bool isQuiet()
    {
        return true;
    }

    public bool isVerbose()
    {
        return false;
    }

    public bool isVeryVerbose()
    {
        return false;
    }

    public bool isDebug()
    {
        return false;
    }
}
