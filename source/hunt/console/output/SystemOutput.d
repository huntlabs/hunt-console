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
 
module hunt.console.output.SystemOutput;

import hunt.console.formatter.OutputFormatter;
import std.stdio;
import hunt.stream.FileOutputStream;
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
        this.stderr = new StreamOutput(new FileOutputStream(std.stdio.stderr));
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
