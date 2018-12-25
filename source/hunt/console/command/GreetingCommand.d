module hunt.console.command.GreetingCommand;

import hunt.console.helper.QuestionHelper;
import hunt.console.input.Input;
import hunt.console.input.InputArgument;
import hunt.console.output.Output;
import hunt.console.question.Question;

public class GreetingCommand : Command
{
    override protected void configure()
    {
        this
            .setName("greet")
            .setDescription("Outputs a greeting.")
            .addArgument("name", InputArgument.OPTIONAL, "Name of the person to greet")
        ;
    }

    override protected int execute(Input input, Output output)
    {
        string name = input.getArgument("name");
        if (name == null) {
            name = "stranger";
        }

        output.writeln(string.format("Greetings, %s!", name));

        return 0;
    }

    override protected void interact(Input input, Output output)
    {
        if (input.getArgument("name") == null) {
            string name = ((QuestionHelper) getHelper("question"))
                    .ask(input, output, new Question("What is your name?"));
            input.setArgument("name", name);
        }
    }
}
