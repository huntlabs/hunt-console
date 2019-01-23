module hunt.console.formatter.DefaultOutputFormatterStyle;

import std.string;
import std.conv;

import hunt.console.error.InvalidArgumentException;
import hunt.console.util.StringUtils;

import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.console.formatter.OutputFormatterStyle;
import hunt.console.formatter.OutputFormatterOption;
import hunt.logging;

class DefaultOutputFormatterStyle : OutputFormatterStyle
{
    private static Map!(string, OutputFormatterOption) availableForegroundColors;
    private static Map!(string, OutputFormatterOption) availableBackgroundColors;
    private static Map!(string, OutputFormatterOption) availableOptions;

    static this() {
        availableForegroundColors = new HashMap!(string, OutputFormatterOption)();
        availableBackgroundColors = new HashMap!(string, OutputFormatterOption)();
        availableOptions = new HashMap!(string, OutputFormatterOption)();
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
    private List!(OutputFormatterOption) options ;

    public this()
    {
        this(null, null, null);
    }

    public this(string foreground)
    {
        this(foreground, null, null);
    }

    public this(string foreground, string background)
    {
        this(foreground, background, null);
    }

    public this(string foreground, string background, string[] opts...)
    {
        this.options = new ArrayList!OutputFormatterOption();
        if (foreground !is null) {
            setForeground(foreground);
        }
        if (background !is null) {
            setBackground(background);
        }
        // logInfo("---infos : ",opts);
        if (opts !is null && opts.length > 0) {
            setOptions(opts);
        }
    }

    override public void setForeground(string color)
    {
        if (color is null) {
            foreground = null;
            return;
        }

        if (!availableForegroundColors.containsKey(color)) {
            string[] keys;
            foreach(string k,_; availableForegroundColors) {
                keys ~= k;
            }   
            throw new InvalidArgumentException(format(
                    "Invalid foreground color specified: '%s'. Expected one of (%s)",
                    color,
                    StringUtils.join(keys, ", ")
            ));
        }

        foreground = availableForegroundColors.get(color);
    }

    override public void setBackground(string color)
    {
        if (color is null) {
            background = null;
            return;
        }

        if (!availableBackgroundColors.containsKey(color)) {
            string[] keys;
            foreach(string k,_; availableBackgroundColors) {
                keys ~= k;
            } 
            throw new InvalidArgumentException(format(
                    "Invalid background color specified: '%s'. Expected one of (%s)",
                    color,
                    StringUtils.join(keys, ", ")
            ));
        }

        background = availableBackgroundColors.get(color);
    }

    override public void setOption(string option)
    {
        if (!availableOptions.containsKey(option)) {
            string[] keys;
            foreach(string k,_; availableOptions) {
                keys ~= k;
            }
            throw new InvalidArgumentException(format("Invalid option specified: '%s'. Expected one of (%s)",
                option, StringUtils.join(keys, ",")));
        }

        if (!options.contains(availableOptions.get(option))) {
            options.add(availableOptions.get(option));
        }
    }

    override public void unsetOption(string option)
    {
        if (!availableOptions.containsKey(option)) {
            string[] keys;
            foreach(string k,_; availableOptions) {
                keys ~= k;
            }
            throw new InvalidArgumentException(format("Invalid option specified: '%s'. Expected one of (%s)",
                option, StringUtils.join(keys, ",")));
        }

        if (options.contains(availableOptions.get(option))) {
            options.remove(availableOptions.get(option));
        }
    }

    override public void setOptions(string[] options...)
    {
        this.options = new ArrayList!OutputFormatterOption();

        foreach (string option ; options) {
            if(option.length == 0)
                continue;
            setOption(option);
        }
    }

    override public string apply(string text)
    {
        List!(string) setCodes = new ArrayList!string();
        List!(string) unsetCodes = new ArrayList!string();

        if (foreground !is null) {
            setCodes.add(to!string(foreground.getSet()));
            unsetCodes.add(to!string(foreground.getUnset()));
        }
        if (background !is null) {
            setCodes.add(to!string(background.getSet()));
            unsetCodes.add(to!string(background.getUnset()));
        }

        foreach (OutputFormatterOption option ; options) {
            setCodes.add(to!string(option.getSet()));
            unsetCodes.add(to!string(option.getUnset()));
        }

        if (setCodes.size() == 0) {
            return text;
        }
        string[] codes;
        foreach(value; setCodes) {
            codes ~= value;
        }
        string[] uncodes;
        foreach(value; unsetCodes) {
            uncodes ~= value;
        }
        return format(
                "\033[%sm%s\033[%sm",
                StringUtils.join(codes, ";"),
                text,
                StringUtils.join(uncodes, ";")
        );
    }

    override public bool opEquals(Object o)
    {
        if (this is o) return true;
        if (!(cast(DefaultOutputFormatterStyle)o !is null)) return false;

        DefaultOutputFormatterStyle that = cast(DefaultOutputFormatterStyle) o;

        if (background !is null ? !(background == that.background) : that.background !is null) return false;
        if (foreground !is null ? !(foreground == that.foreground) : that.foreground !is null) return false;
        if (options !is null ? !(options == that.options) : that.options !is null) return false;

        return true;
    }

    override public size_t toHash() @trusted nothrow
    {
        int result = foreground !is null ? cast(int)(foreground.toHash()) : 0;
        result = 31 * result + (background !is null ? cast(int)(background.toHash()) : 0);
        result = 31 * result + (options !is null ? cast(int)(options.toHash()) : 0);
        return result;
    }
}
