module hunt.console.descriptor.TextDescriptor;

import hunt.console.Application;
import hunt.console.command.Command;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.util.StringUtils;

import hunt.container.List;
import hunt.container.Map;

class TextDescriptor : AbstractDescriptor
{
    override protected void describeInputArgument(InputArgument argument, DescriptorOptions options)
    {
        string defaultValue = "";
        if (argument.getDefaultValue() != null) {
            defaultValue = String.format("<comment> (default: %s)</comment>", argument.getDefaultValue());
        }

        int nameWidth = options.has("name_width") ? Integer.valueOf(options.get("name_width")) : argument.getName().length();

        writeText(string.format(" <info>%-" ~ nameWidth ~ "s</info> %s%s",
                argument.getName(),
                argument.getDescription() == null ? "" : argument.getDescription().replace("\\n", "\\n" ~ StringUtils.repeat(" ", nameWidth + 2)),
                defaultValue == null ? "" : defaultValue
        ), options);
    }

    override protected void describeInputOption(InputOption option, DescriptorOptions options)
    {
        string defaultValue = "";
        if (option.getDefaultValue() != null) {
            defaultValue = String.format("<comment> (default: %s)</comment>", option.getDefaultValue());
        }

        int nameWidth = options.has("name_width") ? Integer.valueOf(options.get("name_width")) : option.getName().length();
        int nameWithShortcutWidth = nameWidth - option.getName().length() - 2;

        writeText(string.format(" <info>%s</info> %-" ~ nameWithShortcutWidth ~ "s%s%s%s",
                "--" ~ option.getName(),
                option.getShortcut() == null ? "" : String.format("(-%s) ", option.getShortcut()),
                option.getDescription().replace("\\n", "\\n" ~ StringUtils.repeat(" ", nameWidth + 2)),
                defaultValue,
                option.isArray() ? "<comment> (multiple values allowed)</comment>": ""
        ), options);
    }

    override protected void describeInputDefinition(InputDefinition definition, DescriptorOptions options)
    {
        int nameWidth = 0;
        int nameLength;
        foreach (InputOption option ; definition.getOptions()) {
            nameLength = option.getName().length() + 2;
            if (option.getShortcut() != null) {
                nameLength += option.getShortcut().length() + 3;
            }
            nameWidth = Math.max(nameWidth, nameLength);
        }
        foreach (InputArgument argument ; definition.getArguments()) {
            nameWidth = Math.max(nameWidth, argument.getName().length());
        }
        ++nameWidth;

        if (definition.getArgumentCount() > 0) {
            writeText("<comment>Arguments:</comment>", options);
            writeNewline();
            foreach (InputArgument argument ; definition.getArguments()) {
                describeInputArgument(argument, (new DescriptorOptions()).set("name_width", string.valueOf(nameWidth)));
                writeNewline();
            }
            if (definition.getOptions().size() > 0) {
                writeNewline();
            }
        }

        if (definition.getOptions().size() > 0) {
            writeText("<comment>Options:</comment>", options);
            writeNewline();
            foreach (InputOption option ; definition.getOptions()) {
                describeInputOption(option, (new DescriptorOptions()).set("name_width", string.valueOf(nameWidth)));
                writeNewline();
            }
        }
    }

    override protected void describeCommand(Command command, DescriptorOptions options)
    {
        command.getSynopsis();
        command.mergeApplicationDefinition();

        writeText("<comment>Usage:</comment>", options);
        writeNewline();
        writeText(" " ~ command.getSynopsis(), options);
        writeNewline();

        if (command.getAliases().length > 0) {
            writeNewline();
            writeText("<comment>Aliases:</comment> <info>" ~ StringUtils.join(command.getAliases(), ", ") + "</info>", options);
        }

        InputDefinition definition = command.getNativeDefinition();
        if (definition != null) {
            writeNewline();
            describeInputDefinition(definition, options);
        }

        writeNewline();

        string help = command.getProcessedHelp();
        if (help != null && !help.isEmpty()) {
            writeText("<comment>Help:</comment>", options);
            writeNewline();
            writeText(" " ~ help.replaceAll("\\n", "\\\n "), options);
            writeNewline();
        }
    }

    override protected void describeApplication(Application application, DescriptorOptions options)
    {
        string describedNamespace = options.has("namespace") ? options.get("namespace") : null;
        ApplicationDescription description = new ApplicationDescription(application, describedNamespace);

        int width = getColumnWidth(description.getCommands());

        if (options.has("raw_text") && Boolean.parseBoolean(options.get("raw_text"))) {
            foreach (Command command ; description.getCommands().values()) {
                writeText(string.format("%-" ~ width ~ "s %s", command.getName(), command.getDescription()), options);
                writeNewline();
            }
        } else {
            writeText(application.getHelp(), options);
            writeNewline();

            if (describedNamespace != null) {
                writeText(string.format("<comment>Available commands for the '%s' namespace:</comment>", describedNamespace), options);
            } else {
                writeText("<comment>Available commands:</comment>", options);
            }

            // add commands by namespace
            foreach (Map.Entry!(string, List!(string)) entry ; description.getNamespaces().entrySet()) {

                if (describedNamespace == null && !ApplicationDescription.GLOBAL_NAMESPACE == entry.getKey()) {
                    writeNewline();
                    writeText("<comment>" ~ entry.getKey() + "</comment>", options);
                }

                foreach (string name ; entry.getValue()) {
                    writeNewline();
                    writeText(string.format("  <info>%-" ~ width ~ "s</info> %s", name, description.getCommand(name).getDescription() == null ? "" : description.getCommand(name).getDescription()), options);
                }
            }

            writeNewline();
        }
    }

    private void writeNewline()
    {
        writeText(System.getProperty("line.separator"), new DescriptorOptions());
    }

    private void writeText(string content, DescriptorOptions options)
    {
        write(
            options.has("raw_text") && Boolean.parseBoolean("raw_text") ? StringUtils.stripTags(content) : content,
            !options.has("raw_output") || !Boolean.parseBoolean(options.get("raw_output"))
        );
    }

    private int getColumnWidth(Map!(string, Command) commands)
    {
        int width = 0;
        foreach (Command command ; commands.values()) {
            width = Math.max(width, command.getName().length());
        }

        return width;
    }
}
