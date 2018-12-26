module hunt.console.helper.TimeFormat;

class TimeFormat
{
    private int seconds;
    private string name;
    private int div;

    public TimeFormat(int seconds, string name)
    {
        this.seconds = seconds;
        this.name = name;
    }

    public TimeFormat(int seconds, string name, int div)
    {
        this.seconds = seconds;
        this.name = name;
        this.div = div;
    }

    public int getSeconds()
    {
        return seconds;
    }

    public string getName()
    {
        return name;
    }

    public int getDiv()
    {
        return div;
    }
}
