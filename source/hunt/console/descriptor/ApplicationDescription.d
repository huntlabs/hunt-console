module hunt.console.descriptor.ApplicationDescription;

import hunt.console.Application;
import hunt.console.error.InvalidArgumentException;
import hunt.console.command.Command;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;

class ApplicationDescription
{
    public static string GLOBAL_NAMESPACE = "_global";

    private  Application application;

    private  string namespace;

    private Map!(string, List!(string)) namespaces;

    private Map!(string, Command) commands;

    private Map!(string, Command) aliases;

    public this(Application application)
    {
        this(application, null);
    }

    public this(Application application, string namespace)
    {
        this.application = application;
        this.namespace = namespace;
    }

    public Map!(string, List!(string)) getNamespaces()
    {
        if (namespaces == null) {
            inspectApplication();
        }

        return namespaces;
    }

    public Map!(string, Command) getCommands()
    {
        if (commands == null) {
            inspectApplication();
        }

        return commands;
    }

    public Command getCommand(string name)
    {
        if (!commands.containsKey(name) && !aliases.containsKey(name)) {
            throw new InvalidArgumentException(string.format("Command %s does not exist.", name));
        }

        if (commands.containsKey(name)) {
            return commands.get(name);
        }

        return aliases.get(name);
    }

    private void inspectApplication()
    {
        commands = new HashMap!(string, Command)();
        aliases = new HashMap!(string, Command)();
        namespaces = new HashMap!(string, List!(string))();

        Map!(string, Command) all;
        if (namespace == null) {
            all = application.all();
        } else {
            all = application.all(namespace);
        }

        foreach (Map.Entry!(string, Map!(string, Command)) entry ; sortCommands(all).entrySet()) {

            string namespace = entry.getKey();
            List!(string) names = new ArrayList!(string)();

            foreach (Map.Entry!(string, Command) commandEntry ; entry.getValue().entrySet()) {
                string name = commandEntry.getKey();
                Command command = commandEntry.getValue();
                if (command.getName() == null || command.getName().isEmpty()) {
                    continue;
                }

                if (command.getName() == name) {
                    commands.put(name, command);
                } else {
                    aliases.put(name, command);
                }

                names.add(name);
            }

            namespaces.put(namespace, names);
        }
    }

    private Map!(string, Map!(string, Command)) sortCommands(Map!(string, Command) commands)
    {
        Map!(string, Map!(string, Command)) namespacedCommands = new HashMap!(string, Map!(string, Command))();

        string key;
        foreach (Map.Entry!(string, Command) entry ; commands.entrySet()) {
            key = application.extractNamespace(entry.getKey(), 1);
            if (key == null || key.isEmpty()) {
                key = GLOBAL_NAMESPACE;
            }

            if (!namespacedCommands.containsKey(key)) {
                namespacedCommands.put(key, new HashMap!(string, Command)());
            }
            namespacedCommands.get(key).put(entry.getKey(), entry.getValue());
        }

        // todo sort

        return namespacedCommands;
    }
}
