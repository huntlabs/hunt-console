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
 
module hunt.console.output.StreamOutput;

import hunt.console.formatter.OutputFormatter;

import hunt.stream.Common;
import hunt.stream.FileOutputStream;
// import hunt.io.PrintWriter;
import hunt.console.output.AbstractOutput;
import hunt.console.output.Verbosity;
import hunt.console.output.Output;
import std.stdio;

class StreamOutput : AbstractOutput
{
    private OutputStream stream;
    private FileOutputStream writer;

    public this(OutputStream stream)
    {
        super();
        initialize(stream);
    }

    public this(OutputStream stream, Verbosity verbosity)
    {
        super(verbosity);
        initialize(stream);
    }

    public this(OutputStream stream, Verbosity verbosity, bool decorated)
    {
        super(verbosity, decorated);
        initialize(stream);
    }

    public this(OutputStream stream, Verbosity verbosity, bool decorated, OutputFormatter formatter)
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
        writer = new FileOutputStream(stdout);
    }

    override protected void doWrite(string message, bool newline)
    {
        writer.write(cast(byte[])message);

        if (newline) {
            writer.write('\n');
        }

        writer.flush();
    }
}
