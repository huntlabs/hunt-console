module hunt.console.output.ConsoleOutput;

public interface ConsoleOutput : Output
{
    public Output getErrorOutput();

    public void setErrorOutput(Output error);
}
