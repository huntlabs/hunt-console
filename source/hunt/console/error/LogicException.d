module hunt.console.error.LogicException;

import hunt.Exceptions;
class LogicException : RuntimeException
{
    public this(string message)
    {
        super(message);
    }
}
