module hunt.console.descriptor.ApplicationDescription;

import std.string;

import hunt.console.Application;
import hunt.console.error.InvalidArgumentException;
import hunt.console.command.Command;
import hunt.console.descriptor.ApplicationDescription;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Integer;

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
        if (namespaces is null) {
            inspectApplication();
        }

        return namespaces;
    }

    public Map!(string, Command) getCommands()
    {
        if (commands is null) {
            inspectApplication();
        }

        return commands;
    }

    public Command getCommand(string name)
    {
        if (!commands.containsKey(name) && !aliases.containsKey(name)) {
            throw new InvalidArgumentException(format("Command %s does not exist.", name));
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
        if (namespace is null) {
            all = application.all();
        } else {
            all = application.all(namespace);
        }

        foreach (string k ,Map!(string, Command) v ; sortCommands(all)) {

            string namespace = k;
            List!(string) names = new ArrayList!(string)();

            foreach (string subK , Command subV ; v) {
                string name = subK;
                Command command = subV;
                if (command.getName() is null || command.getName().length == 0) {
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
        foreach (string k ,Command v ; commands) {
            key = application.extractNamespace(k, new Integer(1));
            if (key is null || key.length == 0) {
                key = GLOBAL_NAMESPACE;
            }

            if (!namespacedCommands.containsKey(key)) {
                namespacedCommands.put(key, new HashMap!(string, Command)());
            }
            namespacedCommands.get(key).put(k, v);
        }

        // todo sort

        return namespacedCommands;
    }
}
