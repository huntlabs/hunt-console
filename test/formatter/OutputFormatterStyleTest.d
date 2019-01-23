module test.formatter.OutputFormatterStyleTest;

import hunt.console.formatter;
import hunt.console.error.InvalidArgumentException;
import test.asserts;
import hunt.text.Common;

unittest
{
    OutputFormatterStyle style = new DefaultOutputFormatterStyle("green",
            "black", "bold", "underscore");
    assertEqual("\033[32;40;1;4mfoo\033[39;49;22;24m", style.apply("foo"));

    style = new DefaultOutputFormatterStyle("red", null, "blink");
    assertEqual("\033[31;5mfoo\033[39;25m", style.apply("foo"));

    style = new DefaultOutputFormatterStyle(null, "white");
    assertEqual("\033[47mfoo\033[49m", style.apply("foo"));
}

unittest
{
    OutputFormatterStyle style = new DefaultOutputFormatterStyle();

    style.setForeground("black");
    assertEqual("\033[30mfoo\033[39m", style.apply("foo"));

    style.setForeground("blue");
    assertEqual("\033[34mfoo\033[39m", style.apply("foo"));
}

unittest
{
    try{
        OutputFormatterStyle style = new DefaultOutputFormatterStyle();
        style.setForeground("undefined-color");
    }catch(InvalidArgumentException){}
}

unittest
{
    OutputFormatterStyle style = new DefaultOutputFormatterStyle();

    style.setBackground("black");
    assertEqual("\033[40mfoo\033[49m", style.apply("foo"));

    style.setBackground("yellow");
    assertEqual("\033[43mfoo\033[49m", style.apply("foo"));
}

unittest
{
    try{
        OutputFormatterStyle style = new DefaultOutputFormatterStyle();
        style.setBackground("undefined-color");
    }catch(InvalidArgumentException){}
}

unittest
{
    OutputFormatterStyle style = new DefaultOutputFormatterStyle();

    style.setOptions("reverse", "conceal");
    assertEqual("\033[7;8mfoo\033[27;28m", style.apply("foo"));

    style.setOption("bold");
    assertEqual("\033[7;8;1mfoo\033[27;28;22m", style.apply("foo"));

    style.unsetOption("reverse");
    assertEqual("\033[8;1mfoo\033[28;22m", style.apply("foo"));

    style.setOption("bold");
    assertEqual("\033[8;1mfoo\033[28;22m", style.apply("foo"));

    style.setOptions("bold");
    assertEqual("\033[1mfoo\033[22m", style.apply("foo"));

    try
    {
        style.setOption("foo");
        assertFail(
                ".setOption() throws an InvalidArgumentException when the option does not exist in the available options");
    }
    catch (InvalidArgumentException e)
    {
        assertTrue(e.msg.contains("Invalid option specified: 'foo'"));
    }

    try
    {
        style.unsetOption("foo");
        assertFail(
                ".unsetOption() throws an InvalidArgumentException when the option does not exist in the available options");
    }
    catch (InvalidArgumentException e)
    {
        assertTrue(e.msg.contains("Invalid option specified: 'foo'"));
    }
}
