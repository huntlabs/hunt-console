module test.formatter.OutputFormatterStyleStackTest;

import hunt.console.error.InvalidArgumentException;
import test.asserts;
import hunt.console.formatter;

unittest
{
    OutputFormatterStyle s1 = new DefaultOutputFormatterStyle("white", "black");
    OutputFormatterStyle s2 = new DefaultOutputFormatterStyle("yellow", "blue");

    OutputFormatterStyleStack stack = new OutputFormatterStyleStack();
    stack.push(s1);
    stack.push(s2);

    OutputFormatterStyle s3 = new DefaultOutputFormatterStyle("green", "red");
    stack.push(s3);

    assertEqual(s3, stack.getCurrent());
}

unittest
{
    OutputFormatterStyle s1 = new DefaultOutputFormatterStyle("white", "black");
    OutputFormatterStyle s2 = new DefaultOutputFormatterStyle("yellow", "blue");

    OutputFormatterStyleStack stack = new OutputFormatterStyleStack();
    stack.push(s1);
    stack.push(s2);

    assertEqual(s2, stack.pop());
    assertEqual(s1, stack.pop());
}

unittest
{
    OutputFormatterStyleStack stack = new OutputFormatterStyleStack();
    DefaultOutputFormatterStyle style = new DefaultOutputFormatterStyle();

    assertEqual(style, stack.pop());
}

unittest
{
    OutputFormatterStyle s1 = new DefaultOutputFormatterStyle("white", "black");
    OutputFormatterStyle s2 = new DefaultOutputFormatterStyle("yellow", "blue");
    OutputFormatterStyle s3 = new DefaultOutputFormatterStyle("green", "red");

    OutputFormatterStyleStack stack = new OutputFormatterStyleStack();
    stack.push(s1);
    stack.push(s2);
    stack.push(s3);

    assertEqual(s2, stack.pop(s2));
    assertEqual(s1, stack.pop());
}

unittest
{
    try{
        OutputFormatterStyleStack stack = new OutputFormatterStyleStack();
        stack.push(new DefaultOutputFormatterStyle("white", "black"));
        stack.pop(new DefaultOutputFormatterStyle("yellow", "blue"));
    }catch(InvalidArgumentException e)
    {
    }
}
