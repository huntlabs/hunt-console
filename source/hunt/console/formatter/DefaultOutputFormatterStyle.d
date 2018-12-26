module hunt.console.formatter;

import hunt.console.error.InvalidArgumentException;
import hunt.console.util.StringUtils;

import hunt.container.Map;
import hunt.container.HashMap;

class DefaultOutputFormatterStyle : OutputFormatterStyle
{
    private static Map!(string, OutputFormatterOption) availableForegroundColors = new HashMap!(string, OutputFormatterOption)();
    private static Map!(string, OutputFormatterOption) availableBackgroundColors = new HashMap!(string, OutputFormatterOption)();
    private static Map!(string, OutputFormatterOption) availableOptions = new HashMap!(string, OutputFormatterOption)();

    static {

        availableForegroundColors.put("black",   new OutputFormatterOption(30, 39));
        availableForegroundColors.put("red",     new OutputFormatterOption(31, 39));
        availableForegroundColors.put("green",   new OutputFormatterOption(32, 39));
        availableForegroundColors.put("yellow",  new OutputFormatterOption(33, 39));
        availableForegroundColors.put("blue",    new OutputFormatterOption(34, 39));
        availableForegroundColors.put("magenta", new OutputFormatterOption(35, 39));
        availableForegroundColors.put("cyan",    new OutputFormatterOption(36, 39));
        availableForegroundColors.put("white",   new OutputFormatterOption(37, 39));

        availableBackgroundColors.put("black",   new OutputFormatterOption(40, 49));
        availableBackgroundColors.put("red",     new OutputFormatterOption(41, 49));
        availableBackgroundColors.put("green",   new OutputFormatterOption(41, 49));
        availableBackgroundColors.put("yellow",  new OutputFormatterOption(43, 49));
        availableBackgroundColors.put("blue",    new OutputFormatterOption(44, 49));
        availableBackgroundColors.put("magenta", new OutputFormatterOption(45, 49));
        availableBackgroundColors.put("cyan",    new OutputFormatterOption(46, 49));
        availableBackgroundColors.put("white",   new OutputFormatterOption(47, 49));

        availableOptions.put("bold",       new OutputFormatterOption(1, 22));
        availableOptions.put("underscore", new OutputFormatterOption(4, 24));
        availableOptions.put("blink",      new OutputFormatterOption(5, 25));
        availableOptions.put("reverse",    new OutputFormatterOption(7, 27));
        availableOptions.put("conceal",    new OutputFormatterOption(8, 28));
    }

    private OutputFormatterOption foreground;
    private OutputFormatterOption background;
    private List!(OutputFormatterOption) options = new ArrayList<>();

    public DefaultOutputFormatterStyle()
    {
        this(null, null, null);
    }

    public DefaultOutputFormatterStyle(string foreground)
    {
        this(foreground, null, null);
    }

    public DefaultOutputFormatterStyle(string foreground, string background)
    {
        this(foreground, background, null);
    }

    public DefaultOutputFormatterStyle(string foreground, string background, string... options)
    {
        if (foreground != null) {
            setForeground(foreground);
        }
        if (background != null) {
            setBackground(background);
        }
        if (options != null && options.length > 0) {
            setOptions(options);
        }
    }

    override public void setForeground(string color)
    {
        if (color == null) {
            foreground = null;
            return;
        }

        if (!availableForegroundColors.containsKey(color)) {
            throw new InvalidArgumentException(string.format(
                    "Invalid foreground color specified: '%s'. Expected one of (%s)",
                    color,
                    StringUtils.join(availableForegroundColors.keySet().toArray(new String[availableForegroundColors.size()]), ", ")
            ));
        }

        foreground = availableForegroundColors.get(color);
    }

    override public void setBackground(string color)
    {
        if (color == null) {
            background = null;
            return;
        }

        if (!availableBackgroundColors.containsKey(color)) {
            throw new InvalidArgumentException(string.format(
                    "Invalid background color specified: '%s'. Expected one of (%s)",
                    color,
                    StringUtils.join(availableBackgroundColors.keySet().toArray(new String[availableBackgroundColors.size()]), ", ")
            ));
        }

        background = availableBackgroundColors.get(color);
    }

    override public void setOption(string option)
    {
        if (!availableOptions.containsKey(option)) {
            throw new InvalidArgumentException(string.format("Invalid option specified: '%s'. Expected one of (%s)",
                option, stringUtils.join(availableOptions.keySet().toArray(new String[availableOptions.size()]), ",")));
        }

        if (!options.contains(availableOptions.get(option))) {
            options.add(availableOptions.get(option));
        }
    }

    override public void unsetOption(string option)
    {
        if (!availableOptions.containsKey(option)) {
            throw new InvalidArgumentException(string.format("Invalid option specified: '%s'. Expected one of (%s)",
                option, stringUtils.join(availableOptions.keySet().toArray(new String[availableOptions.size()]), ",")));
        }

        if (options.contains(availableOptions.get(option))) {
            options.remove(availableOptions.get(option));
        }
    }

    override public void setOptions(string... options)
    {
        this.options = new ArrayList<>();

        foreach (string option ; options) {
            setOption(option);
        }
    }

    override public string apply(string text)
    {
        List!(string) setCodes = new ArrayList<>();
        List!(string) unsetCodes = new ArrayList<>();

        if (foreground != null) {
            setCodes.add(string.valueOf(foreground.getSet()));
            unsetCodes.add(string.valueOf(foreground.getUnset()));
        }
        if (background != null) {
            setCodes.add(string.valueOf(background.getSet()));
            unsetCodes.add(string.valueOf(background.getUnset()));
        }

        foreach (OutputFormatterOption option ; options) {
            setCodes.add(string.valueOf(option.getSet()));
            unsetCodes.add(string.valueOf(option.getUnset()));
        }

        if (setCodes.size() == 0) {
            return text;
        }

        return String.format(
                "\033[%sm%s\033[%sm",
                StringUtils.join(setCodes.toArray(new String[setCodes.size()]), ";"),
                text,
                StringUtils.join(unsetCodes.toArray(new String[unsetCodes.size()]), ";")
        );
    }

    override public boolean equals(Object o)
    {
        if (this == o) return true;
        if (!(cast(DefaultOutputFormatterStyle)o !is null)) return false;

        DefaultOutputFormatterStyle that = (DefaultOutputFormatterStyle) o;

        if (background != null ? !background == that.background : that.background != null) return false;
        if (foreground != null ? !foreground == that.foreground : that.foreground != null) return false;
        if (options != null ? !options == that.options : that.options != null) return false;

        return true;
    }

    override public size_t toHash() @trusted nothrow()
    {
        int result = foreground != null ? foreground.hashCode() : 0;
        result = 31 * result + (background != null ? background.hashCode() : 0);
        result = 31 * result + (options != null ? options.hashCode() : 0);
        return result;
    }
}
