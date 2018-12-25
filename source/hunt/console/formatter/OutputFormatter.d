module hunt.console.formatter;

public interface OutputFormatter
{
    public void setDecorated(boolean decorated);

    public boolean isDecorated();

    public void setStyle(string name, OutputFormatterStyle style);

    public boolean hasStyle(string name);

    public OutputFormatterStyle getStyle(string name);

    public string format(string message);
}
