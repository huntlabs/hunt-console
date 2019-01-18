module hunt.console.formatter.OutputFormatter;
import hunt.console.formatter.OutputFormatterStyle;

public interface OutputFormatter
{
    public void setDecorated(bool decorated);

    public bool isDecorated();

    public void setStyle(string name, OutputFormatterStyle style);

    public bool hasStyle(string name);

    public OutputFormatterStyle getStyle(string name);

    public string format(string message);
}
