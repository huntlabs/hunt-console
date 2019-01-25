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
 
module hunt.console.command.ListCommand;

import hunt.console.descriptor.DescriptorOptions;
import hunt.console.helper.DescriptorHelper;
import hunt.console.input.Input;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.output.Output;
import hunt.console.command.Command;

class ListCommand : Command
{
    override protected void configure()
    {
        this
            .setName("list")
            .setDefinition(createDefinition())
            .setDescription("Lists commands")
            .setHelp("The <info>%command.name%</info> command lists all commands:\n" ~
                    "\n" ~
                    "  <info>%command.name%</info>\n" ~
                    "\n" ~
                    "You can also display the commands for a specific namespace:\n" ~
                    "\n" ~
                    "  <info>%command.name% test</info>\n" ~
                    "\n" ~
                    "You can also output the information in other formats by using the <comment>--format</comment> option:\n" ~
                    "\n" ~
                    "  <info>%command.name% --format=xml</info>\n" ~
                    "\n" ~
                    "It's also possible to get raw list of commands (useful for embedding command runner):\n" ~
                    "\n" ~
                    "  <info>%command.name% --raw</info>\n")
        ;
    }

    override public InputDefinition getNativeDefinition()
    {
        return createDefinition();
    }

    override protected int execute(Input input, Output output)
    {
        if (input.getOption("xml") !is null) {
            input.setOption("format", "xml");
        }

        DescriptorHelper helper = new DescriptorHelper();
        helper.describe(output, getApplication(), (new DescriptorOptions())
                .set("format", input.getOption("format"))
                .set("raw_text", input.getOption("raw"))
                .set("namespace", input.getArgument("namespace"))
        );

        return 0;
    }

    private InputDefinition createDefinition()
    {
        InputDefinition definition = new InputDefinition();
        definition.addArgument(new InputArgument("namespace", InputArgument.OPTIONAL, "The namespace name"));
        definition.addOption(new InputOption("xml", null, InputOption.VALUE_NONE, "To output list as XML"));
        definition.addOption(new InputOption("raw", null, InputOption.VALUE_NONE, "To output raw command list"));
        definition.addOption(new InputOption("format", null, InputOption.VALUE_REQUIRED, "To output list in other formats", "txt"));

        return definition;
    }
}
