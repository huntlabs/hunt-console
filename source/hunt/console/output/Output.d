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
 
module hunt.console.output.Output;

import hunt.console.output.OutputType;

import hunt.console.output.Verbosity;
import hunt.console.formatter.OutputFormatter;

interface Output
{
    void write(string message);

    void write(string message, bool newline);

    void write(string message, bool newline, OutputType type);

    void writeln(string message);

    void writeln(string message, OutputType type);

    void setVerbosity(Verbosity verbosity);

    Verbosity getVerbosity();

    void setDecorated(bool decorated);

    bool isDecorated();

    void setFormatter(OutputFormatter formatter);

    OutputFormatter getFormatter();
}
