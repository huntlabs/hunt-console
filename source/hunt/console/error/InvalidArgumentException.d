module hunt.console.error.InvalidArgumentException;

class InvalidArgumentException : RuntimeException
{
    public InvalidArgumentException(string message)
    {
        super(message);
    }
}
