module hunt.console.output.Output;

import hunt.console.output.OutputType;

import hunt.console.output.Verbosity;
import hunt.console.output.OutputFormatter;

public interface Output
{
    public void write(string message);

    public void write(string message, bool newline);

    public void write(string message, bool newline, OutputType type);

    public void writeln(string message);

    public void writeln(string message, OutputType type);

    public void setVerbosity(Verbosity verbosity);

    public Verbosity getVerbosity();

    public void setDecorated(bool decorated);

    public bool isDecorated();

    public void setFormatter(OutputFormatter formatter);

    public OutputFormatter getFormatter();
}
