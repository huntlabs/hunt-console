module test.command.CommandTest;

import hunt.console.Console;
import hunt.console.command;
import hunt.console.error.InvalidArgumentException;
import hunt.console.error.LogicException;
import hunt.console.helper.QuestionHelper;
import hunt.console.input;
import hunt.console.output.NullOutput;
import hunt.console.output.Output;

import hunt.collection.HashMap;
import hunt.collection.Map;
import test.asserts;
import test.command.TestCommand;

unittest
{
    Command command = new Command("foo:bar");
    assertEqual("Constructor takes the command name as its first argument",
            "foo:bar", command.getName());
}

unittest
{
    Console application = new Console();
    Command command = new TestCommand();
    command.setConsole(application);
    assertEqual("setConsole() sets the current application", application,
            command.getConsole());
}

unittest
{
    Command command = new TestCommand();
    InputDefinition definition = new InputDefinition();
    command.setDefinition(definition);
    assertEqual("setDefinition() sets the current InputDefinition instance.",
            definition, command.getDefinition());
}

unittest
{
    Command command = new TestCommand();
    command.addArgument("foo");
    assertTrue("addArgument() adds an argument to the command's definition",
            command.getDefinition().hasArgument("foo"));
}

unittest
{
    Command command = new TestCommand();
    command.addOption("foo");
    assertTrue("addOption() adds an option to the command's definition",
            command.getDefinition().hasOption("foo"));
}

unittest
{
    Command command = new TestCommand();
    assertEqual("getName() returns the command name", "namespace:name", command.getName());
    command.setName("foo");
    assertEqual("setName() sets the command name", "foo", command.getName());

    command.setName("foobar:bar");
    assertEqual("setName() sets the command name", "foobar:bar", command.getName());
}

unittest
{
    Command command = new TestCommand();
    assertEqual("getDescription() returns the description", "description",
            command.getDescription());
    command.setDescription("description1");
    assertEqual("setDescription sets the description", "description1", command.getDescription());
}

unittest
{
    Command command = new TestCommand();
    assertEqual("getHelp() returns the help", "help", command.getHelp());
    command.setHelp("help1");
    assertEqual("setHelp sets the help", "help1", command.getHelp());
}

unittest
{
    Command command = new TestCommand();
    command.setHelp("The %command.name% command does...");
    assertEqual("getProcessedHelp() replaces %command.name% correctly",
            "The namespace:name command does...", command.getProcessedHelp());
}

unittest
{
    // Command command = new TestCommand();
    // Assert.assertArrayEquals(["name"], command.getAliases());
    // command.setAliases("name1");
    // Assert.assertArrayEquals(["name1"], command.getAliases());
}

unittest
{
    Command command = new TestCommand();
    command.addOption("foo");
    command.addArgument("foo");
    assertEqual("getSynopsis() returns the synopsis",
            "namespace:name [--foo] [foo]", command.getSynopsis());
}

unittest
{
    Console application = new Console();
    Command command = new TestCommand();
    command.setConsole(application);
    QuestionHelper helper = new QuestionHelper();
    assertEqual("getHelper() returns the correct helper", helper.getName(),
            command.getHelper("question").getName());
}

unittest
{
    Console application = new Console();
    application.getDefinition().addArgument(new InputArgument("foo"));
    application.getDefinition().addOption(new InputOption("bar"));

    InputDefinition definition = new InputDefinition();
    definition.addArgument(new InputArgument("bar"));
    definition.addOption(new InputOption("foo"));

    Command command = new TestCommand();
    command.setConsole(application);
    command.setDefinition(definition);

    command.mergeConsoleDefinition();
    assertTrue("mergeConsoleDefinition() merges the application arguments and the command arguments",
            command.getDefinition().hasArgument("foo"));
    assertTrue("mergeConsoleDefinition() merges the application arguments and the command arguments",
            command.getDefinition().hasArgument("bar"));
    assertTrue("mergeConsoleDefinition() merges the application options and the command options",
            command.getDefinition().hasOption("foo"));
    assertTrue("mergeConsoleDefinition() merges the application options and the command options",
            command.getDefinition().hasOption("bar"));

    command.mergeConsoleDefinition();
    assertEqual("mergeConsoleDefinition() does not try to merge twice the application arguments and options",
            3, command.getDefinition().getArgumentCount());
}

unittest
{
    Console application = new Console();
    application.getDefinition().addArgument(new InputArgument("foo"));
    application.getDefinition().addOption(new InputOption("bar"));

    Command command = new TestCommand();
    command.setConsole(application);
    command.setDefinition(new InputDefinition());

    command.mergeConsoleDefinition(false);
    assertFalse(
            "mergeConsoleDefinition(false) does not merge the application arguments and the command arguments",
            command.getDefinition().hasArgument("foo"));

    command.mergeConsoleDefinition(true);
    assertTrue("mergeConsoleDefinition(true) merges the application arguments and the command arguments",
            command.getDefinition().hasArgument("foo"));
}
