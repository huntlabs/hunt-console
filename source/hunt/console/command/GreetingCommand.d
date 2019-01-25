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
 
module hunt.console.command.GreetingCommand;

import std.string;

import hunt.console.helper.QuestionHelper;
import hunt.console.input.Input;
import hunt.console.input.InputArgument;
import hunt.console.output.Output;
import hunt.console.question.Question;
import hunt.console.command.Command;

class GreetingCommand : Command
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
        if (name is null) {
            name = "stranger";
        }

        output.writeln(format("Greetings, %s!", name));

        return 0;
    }

    override protected void interact(Input input, Output output)
    {
        if (input.getArgument("name") is null) {
            string name = (cast(QuestionHelper) (getHelper("question")))
                    .ask(input, output, new Question("What is your name?"));
            input.setArgument("name", name);
        }
    }
}
