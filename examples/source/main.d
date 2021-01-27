import std.stdio;

import core.thread;
import hunt.console;
import hunt.Exceptions;
import hunt.logging;

import std.array;
import std.conv;
import std.range;

void main(string[] args)
{
    auto console = new Console("Hunt Console", "1.0.0");

    console.setAutoExit(false);
    console.add(new GreetingCommand());
    console.add((new Command("test")).setExecutor(new class CommandExecutor {
        override public int execute(Input input, Output output)
        {
            ProgressBar bar = new ProgressBar(output, 500);

            for (int i = 0; i < 500; i++)
            {
                bar.advance();
                try
                {
                    Thread.sleep( 5.seconds );
                }
                catch (InterruptedException ex)
                {
                    // Thread.currentThread().interrupt();
                }
            }

            bar.finish();

            return;
        }
    }));

    console.add(new ServeCommand());

    console.run(args);
}



/**
 * 
 */
class ServeCommand : Command {
    enum string HostNameOption = "hostname";
    enum string PortOption = "port";
    enum string BindOption = "bind";
    enum string ConfigPathOption = "config-path";
    // enum string ConfigFileOption = "config-file";
    enum string EnvironmentOption = "env"; // development, production, staging

    this() {
        super("serve");
    }

    override protected void configure() {
        // https://symfony.com/doc/current/components/console/console_arguments.html
        // https://symfony.com/doc/current/console/input.html
        setDescription("Begins serving the app over HTTP.");

        addOption(HostNameOption, "H", InputOption.VALUE_OPTIONAL,
            "Set the hostname the server will run on.",
            "0.0.0.0");

        addOption(PortOption, "p", InputOption.VALUE_OPTIONAL,
            "Set the port the server will run on.",
            "8080");

        addOption(BindOption, "b", InputOption.VALUE_OPTIONAL,
            "Convenience for setting hostname and port together.",
            "0.0.0.0:8080");

        addOption(EnvironmentOption, "e", InputOption.VALUE_OPTIONAL,
            "Set the runtime environment.", "production");

        addOption(ConfigPathOption, "c", InputOption.VALUE_OPTIONAL,
            "Set the location for config files",
            "./config");

        // addOption(ConfigFileOption, "cf", InputOption.VALUE_OPTIONAL,
        //     "Set the name of the main config file",
        //     DEFAULT_CONFIG_FILE);

    }

    override protected int execute(Input input, Output output) {
        string hostname = input.getOption(HostNameOption);
        string port = input.getOption(PortOption);
        string bind = input.getOption(BindOption);
        string configPath = input.getOption(ConfigPathOption);
        // string configFile = input.getOption(ConfigFileOption);
        string envionment = input.getOption(EnvironmentOption);

        if (!bind.empty && bind != "0.0.0.0:8080") {
            // 0.0.0.0:8080, 0.0.0.0, parse hostname and port
            string[] parts = bind.split(":");
            if(parts.length<2) {
                output.writeln("Wrong format for the bind option.");
            }

            hostname = parts[0];
            port = parts[1];
        }

        ServeSignature signature = ServeSignature(hostname, port.to!ushort, 
            configPath, envionment); // configFile, 
        
            warning(signature);

        return 0;
    }

    override protected void interact(Input input, Output output) {
        // if (input.getArgument("name") is null) {
        //     string name = (cast(QuestionHelper)(getHelper("question"))).ask(input,
        //             output, new Question("What is your name?"));
        //     input.setArgument("name", name);
        // }
    }
}

/**
 * 
 */
struct ServeSignature {
    string host = "0.0.0.0";
    ushort port = 8080;
    string configPath = "./config";
    string environment = "production";
}

