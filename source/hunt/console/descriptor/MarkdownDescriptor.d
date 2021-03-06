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
 
module hunt.console.descriptor.MarkdownDescriptor;

import std.string;

import hunt.console.Console;
import hunt.console.command.Command;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.util.StringUtils;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.console.descriptor.AbstractDescriptor;
import hunt.console.descriptor.DescriptorOptions;
import hunt.console.descriptor.ConsoleDescription;

class MarkdownDescriptor : AbstractDescriptor
{
    override protected void describeInputArgument(InputArgument argument, DescriptorOptions options)
    {
        write(
            "**" ~ argument.getName() ~ ":**\n\n" ~
            "* Name: " ~ (argument.getName() is null ? "<none>" : argument.getName()) ~ "\n" ~
            "* Is required: " ~ (argument.isRequired() ? "yes" : "no") ~ "\n" ~
            "* Is array: " ~ (argument.isArray() ? "yes" : "no") ~ "\n" ~
            "* Description: " ~ (argument.getDescription() is null ? "<none>" : argument.getDescription()) ~ "\n" ~
            "* Default: `" ~ (argument.getDefaultValue() is null ? "" : argument.getDefaultValue().replace("\\n", " ")) ~ "`"
        );
    }

    override protected void describeInputOption(InputOption option, DescriptorOptions options)
    {
        write(
            "**" ~ option.getName() ~ ":**\n\n" ~
            "* Name: `--" ~ option.getName() ~ "`\n" ~
            "* Shortcut: " ~ (option.getShortcut() is null ? "<none>" : "`-" ~ StringUtils.join(StringUtils.split(option.getShortcut(), '|'), "|")) ~ "\n" ~
            "* Accept value: " ~ (option.acceptValue() ? "yes" : "no") ~ "\n" ~
            "* Is value required: " ~ (option.isValueRequired() ? "yes" : "no") ~ "\n" ~
            "* Is multiple: " ~ (option.isArray() ? "yes" : "no") ~ "\n" ~
            "* Description: " ~ (option.getDescription() is null ? "<none>" : option.getDescription()) ~ "\n" ~
            "* Default: `" ~ (option.getDefaultValue() is null ? "" : option.getDefaultValue().replace("\\n", " ")) ~ "`"
        );
    }

    override protected void describeInputDefinition(InputDefinition definition, DescriptorOptions options)
    {
        bool showArguments = definition.getArguments().size() > 0;
        if (showArguments) {
            write("### Arguments:");
            foreach (InputArgument argument ; definition.getArguments()) {
                write("\n\n");
                describeInputArgument(argument, options);
            }
        }

        if (definition.getOptions().size() > 0) {
            if (showArguments) {
                write("\n\n");
            }
            write("### Options:");
            foreach (InputOption option ; definition.getOptions()) {
                write("\n\n");
                describeInputOption(option, options);
            }
        }
    }

    override protected void describeCommand(Command command, DescriptorOptions options)
    {
        command.getSynopsis();
        command.mergeConsoleDefinition(false);

        write(
                command.getName() ~ "\n" ~
                StringUtils.repeat("-", command.getName().length) ~ "\n\n" ~
                "* Description: " ~ (command.getDescription() is null ? "<none>" : command.getDescription()) ~ "\n" ~
                "* Usage: `" ~ command.getSynopsis() ~ "`\n" ~
                "* Aliases: " ~ (command.getAliases().length > 0 ? "`" ~ StringUtils.join(command.getAliases(), "`, `") ~ "`" : "<none>")
        );

        string help = command.getProcessedHelp();
        if (help !is null) {
            write("\n\n");
            write(help);
        }

        InputDefinition definition = command.getNativeDefinition();
        if (definition !is null) {
            write("\n\n");
            describeInputDefinition(definition, options);
        }
    }

    override protected void describeConsole(Console application, DescriptorOptions options)
    {
        string describedNamespace = options.has("namespace") ? options.get("namespace") : null;
        ConsoleDescription description = new ConsoleDescription(application, describedNamespace);

        write(application.getName() ~ "\n" ~ StringUtils.repeat("=", application.getName().length));

        foreach (string k ,List!(string) v ; description.getNamespaces()) {
            string namespace = k;
            if (!(namespace == ConsoleDescription.GLOBAL_NAMESPACE)) {
                write("\n\n");
                write("**" ~ namespace ~ ":**");
            }

            write("\n\n");
            foreach (string commandName ; v) {
                write("* " ~ commandName ~ "\n");
            }
        }

        foreach (Command command ; description.getCommands().values()) {
            write("\n\n");
            describeCommand(command, options);
        }
    }
}
