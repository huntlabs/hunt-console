module hunt.console.error.InvalidArgumentException;

public class InvalidArgumentException : RuntimeException
{
    public InvalidArgumentException(string message)
    {
        super(message);
    }
}
