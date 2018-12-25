module hunt.console.command.CommandExecutor;

import hunt.console.input.Input;
import hunt.console.output.Output;

public interface CommandExecutor
{
    public int execute(Input input, Output output);
}
