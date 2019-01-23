module hunt.console.formatter.OutputFormatterStyle;

public interface OutputFormatterStyle
{
    public void setForeground(string color);

    public void setBackground(string color);

    public void setOption(string option);

    public void unsetOption(string option);

    public void setOptions(string[] options...);

    public string apply(string text);
}
