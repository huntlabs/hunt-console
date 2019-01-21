module hunt.console.descriptor.TextDescriptor;

import std.string;
import std.conv;
import hunt.console.Application;
import hunt.console.command.Command;
import hunt.console.input.InputArgument;
import hunt.console.input.InputDefinition;
import hunt.console.input.InputOption;
import hunt.console.util.StringUtils;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.math.Helper;
import hunt.Integer;
import hunt.Boolean;
import hunt.console.descriptor.AbstractDescriptor;
import hunt.console.descriptor.DescriptorOptions;
import hunt.console.descriptor.ApplicationDescription;

class TextDescriptor : AbstractDescriptor
{
    override protected void describeInputArgument(InputArgument argument, DescriptorOptions options)
    {
        string defaultValue = "";
        if (argument.getDefaultValue() !is null) {
            defaultValue = format("<comment> (default: %s)</comment>", argument.getDefaultValue());
        }

        int nameWidth = options.has("name_width") ? Integer.valueOf(options.get("name_width")).intValue() : cast(int)(argument.getName().length);

        writeText(format(" <info>%-" ~ nameWidth.to!string ~ "s</info> %s%s",
                argument.getName(),
                argument.getDescription() is null ? "" : argument.getDescription().replace("\\n", "\\n" ~ StringUtils.repeat(" ", nameWidth + 2)),
                defaultValue is null ? "" : defaultValue
        ), options);
    }

    override protected void describeInputOption(InputOption option, DescriptorOptions options)
    {
        string defaultValue = "";
        if (option.getDefaultValue() !is null) {
            defaultValue = format("<comment> (default: %s)</comment>", option.getDefaultValue());
        }

        int nameWidth = options.has("name_width") ? Integer.valueOf(options.get("name_width")).intValue() : cast(int)(option.getName().length);
        int nameWithShortcutWidth = nameWidth - cast(int)(option.getName().length) - 2;

        writeText(format(" <info>%s</info> %-" ~ nameWithShortcutWidth.to!string ~ "s%s%s%s",
                "--" ~ option.getName(),
                option.getShortcut() is null ? "" : format("(-%s) ", option.getShortcut()),
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
            nameLength = cast(int)(option.getName().length) + 2;
            if (option.getShortcut() !is null) {
                nameLength += cast(int)(option.getShortcut().length) + 3;
            }
            nameWidth = MathHelper.max(nameWidth, nameLength);
        }
        foreach (InputArgument argument ; definition.getArguments()) {
            nameWidth = MathHelper.max(nameWidth, cast(int)(argument.getName().length));
        }
        ++nameWidth;

        if (definition.getArgumentCount() > 0) {
            writeText("<comment>Arguments:</comment>", options);
            writeNewline();
            foreach (InputArgument argument ; definition.getArguments()) {
                describeInputArgument(argument, (new DescriptorOptions()).set("name_width", nameWidth.to!string));
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
                describeInputOption(option, (new DescriptorOptions()).set("name_width", nameWidth.to!string));
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
            writeText("<comment>Aliases:</comment> <info>" ~ StringUtils.join(command.getAliases(), ", ") ~ "</info>", options);
        }

        InputDefinition definition = command.getNativeDefinition();
        if (definition !is null) {
            writeNewline();
            describeInputDefinition(definition, options);
        }

        writeNewline();

        string help = command.getProcessedHelp();
        if (help !is null && !(help.length == 0)) {
            writeText("<comment>Help:</comment>", options);
            writeNewline();
            writeText(" " ~ help.replace("\\n", "\\\n "), options);
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
                writeText(format("%-" ~ width.to!string ~ "s %s", command.getName(), command.getDescription()), options);
                writeNewline();
            }
        } else {
            writeText(application.getHelp(), options);
            writeNewline();

            if (describedNamespace !is null) {
                writeText(format("<comment>Available commands for the '%s' namespace:</comment>", describedNamespace), options);
            } else {
                writeText("<comment>Available commands:</comment>", options);
            }

            // add commands by namespace
            foreach (string k,List!(string) v ; description.getNamespaces()) {

                if (describedNamespace is null && !(ApplicationDescription.GLOBAL_NAMESPACE == k)) {
                    writeNewline();
                    writeText("<comment>" ~ k ~ "</comment>", options);
                }

                foreach (string name ; v) {
                    writeNewline();
                    writeText(format("  <info>%-" ~ width.to!string ~ "s</info> %s", name, description.getCommand(name).getDescription() is null ? "" : description.getCommand(name).getDescription()), options);
                }
            }

            writeNewline();
        }
    }

    private void writeNewline()
    {
        writeText("\r\n"/* System.getProperty("line.separator") */, new DescriptorOptions());
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
            width = MathHelper.max(width, cast(int)(command.getName().length));
        }

        return width;
    }
}
