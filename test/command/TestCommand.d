module test.command.TestCommand;

import hunt.console.input.Input;
import hunt.console.command.Command;
import hunt.console.output.Output;

public class TestCommand : Command
{
    override
    protected void configure()
    {
        this
                .setName("namespace:name")
                .setAliases("name")
                .setDescription("description")
                .setHelp("help")
        ;
    }

    override
    protected int execute(Input input, Output output)
    {
        output.writeln("execute called");

        return 0;
    }

    override
    protected void interact(Input input, Output output)
    {
        output.writeln("interact called");
    }
}
