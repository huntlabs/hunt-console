Console Component
=================

Console eases the creation of beautiful and testable command line interfaces.

It is a port from [Symfony's Console component](https://github.com/symfony/Console).

The Application object manages the command-line application:

    import hunt.console;

    console = new Application();
    console.run(new ArgsInput(args));

The ``run()`` method parses the arguments and options passed on the command
line and executes the right command.

Registering a new command can easily be done via the ``register()`` method,
which returns a ``Command`` instance:

   ```D
void main(string[] args)
{
    Application app = new Application("Hunt Console", "1.0.0");
    app.setAutoExit(false);
    app.add(new GreetingCommand());

    app.add((new Command("test")).setExecutor(new class CommandExecutor {
        override public int execute(Input input, Output output)
        {
            output.writeln("hello world");
            return 0;
        }
    }));
    
    if(args.length > 1)
        app.run(args[1..$]);
    else
        app.run([]);
}
   ```

You can also register new commands via classes.

The component provides a lot of features like output coloring, input and
output abstractions (so that you can easily unit-test your commands),
validation, automatic help messages, ...
