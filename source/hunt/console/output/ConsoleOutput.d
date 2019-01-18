module hunt.console.output.ConsoleOutput;
import hunt.console.output.Output;

public interface ConsoleOutput : Output
{
    public Output getErrorOutput();

    public void setErrorOutput(Output error);
}
