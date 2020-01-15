Console Component
=================

Console eases the creation of beautiful and testable command line interfaces.

It is a port from [Symfony's Console component](https://github.com/symfony/Console).

The Console object manages the command-line application:

import hunt.console;

console = new Console();
console.run(new ArgsInput(args));

The ``run()`` method parses the arguments and options passed on the command
line and executes the right command.

Registering a new command can easily be done via the ``register()`` method,
which returns a ``Command`` instance:

```D
void main(string[] args)
{
    Console app = new Console("Hunt Console", "1.0.0");
    app.setAutoExit(false);
    app.add(new GreetingCommand());

    app.add((new Command("test")).setExecutor(new class CommandExecutor {
        override public int execute(Input input, Output output)
        {
            output.writeln("hello world");
            return 0;
        }
    }));
    
    app.run(args);
}
```

You can also register new commands via classes.

The component provides a lot of features like output coloring, input and
output abstractions (so that you can easily unit-test your commands),
validation, automatic help messages, ...
