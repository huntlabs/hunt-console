module hunt.console.error.InvalidArgumentException;

import hunt.Exceptions;

class InvalidArgumentException : RuntimeException
{
    public this(string message)
    {
        super(message);
    }
}
