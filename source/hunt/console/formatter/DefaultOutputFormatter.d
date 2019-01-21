module hunt.console.formatter.DefaultOutputFormatter;

import hunt.console.error.InvalidArgumentException;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.console.formatter.OutputFormatter;
import hunt.console.formatter.OutputFormatterStyle;
import hunt.console.formatter.OutputFormatterStyleStack;
import hunt.console.formatter.DefaultOutputFormatterStyle;
import hunt.text.StringBuilder;
import hunt.text.Common;
import hunt.logging;
import std.regex;
import std.string;

class DefaultOutputFormatter : OutputFormatter
{
    private bool decorated;

    private Map!(string, OutputFormatterStyle) styles ;

    private OutputFormatterStyleStack styleStack;

    public const string TAG_REGEX = "[a-z][a-z0-9_=;-]*";

    public const string TAG_PATTERN = "<((" ~ TAG_REGEX ~ ")|/(" ~ TAG_REGEX ~ ")?)>";

    public const string STYLE_PATTERN = "([^=]+)=([^;]+)(;|$)";

    public static string escape(string text)
    {
        string pattern = "([^\\\\\\\\]?)<";

        // return pattern.matcher(text).replaceAll("$1\\\\<");
        auto re = regex(pattern, "g");
        return text.replaceAll(re,"$1\\\\<");
    }

    public this()
    {
        this(false);
    }

    public this(bool decorated)
    {
        this(decorated, new HashMap!(string, OutputFormatterStyle)());
    }

    public this(bool decorated, Map!(string, OutputFormatterStyle) styles)
    {
        this.styles = new HashMap!(string, OutputFormatterStyle)();
        this.decorated = decorated;

        setStyle("error", new DefaultOutputFormatterStyle("white", "red"));
        setStyle("info", new DefaultOutputFormatterStyle("green"));
        setStyle("comment", new DefaultOutputFormatterStyle("yellow"));
        setStyle("question", new DefaultOutputFormatterStyle("black", "cyan"));

        this.styles.putAll(styles);

        styleStack = new OutputFormatterStyleStack();
    }

    override public void setDecorated(bool decorated)
    {
        this.decorated = decorated;
    }

    override public bool isDecorated()
    {
        return decorated;
    }

    override public void setStyle(string name, OutputFormatterStyle style)
    {
        styles.put(name.toLower(), style);
    }

    override public bool hasStyle(string name)
    {
        return styles.containsKey(name.toLower());
    }

    override public OutputFormatterStyle getStyle(string name)
    {
        if (!hasStyle(name)) {
            throw new InvalidArgumentException(std.string.format("Undefined style: %s", name));
        }

        return styles.get(name);
    }

    override public string format(string message)
    {
        if (message is null) {
            return "";
        }

        int offset = 0;
        StringBuilder output = new StringBuilder();

        auto  matchers = matchAll(message,TAG_PATTERN);

        bool open;
        string tag;
        OutputFormatterStyle style;
        // logInfo("mesg : ",message);
        foreach(matcher; matchers) {
            string text = matcher.captures[0];
            int pos = cast(int)(message[offset..$].indexOf(text))+offset;

            // add the text up to the next tag
            // logInfo("pos : ",pos, " offset: ",offset," text :",text);
            output.append(applyCurrentStyle(message.substring(offset, pos)));
            offset = pos + cast(int)(text.length);

            // opening tag?
            open = text[1] != '/';
            if (open) {
                tag = matcher.captures[2];
            } else {
                tag = matcher.captures[3];
            }

            if (!open && (tag is null || tag.length == 0)) {
                // </>
                styleStack.pop();
            } else if (pos > 0 && message.charAt(pos - 1) == '\\') {
                // escaped tag
                output.append(applyCurrentStyle(text));
            } else {
                style = createStyleFromString(tag.toLower());
                if (style is null) {
                    output.append(applyCurrentStyle(text));
                } else {
                    if (open) {
                        styleStack.push(style);
                    } else {
                        styleStack.pop(style);
                    }
                }
            }
        }

        output.append(applyCurrentStyle(message.substring(offset)));

        return output.toString().replace("\\\\<", "<");
    }

    private OutputFormatterStyle createStyleFromString(string str)
    {
        if (styles.containsKey(str)) {
            return styles.get(str);
        }

        auto matchers = matchAll(str.toLower(),STYLE_PATTERN);

        OutputFormatterStyle style = new DefaultOutputFormatterStyle();

        string type;
        foreach(matcher; matchers){
            type = matcher.captures[1];
            switch (type) {
                case "fg":
                    style.setForeground(matcher.captures[2]);
                    break;
                case "bg":
                    style.setBackground(matcher.captures[2]);
                    break;
                default:
                    try {
                        style.setOption(matcher.captures[2]);
                    } catch (InvalidArgumentException e) {
                        return null;
                    }
                    break;
            }
        }

        return style;
    }

    private string applyCurrentStyle(string text)
    {
        if (isDecorated() && text.length > 0) {
            return styleStack.getCurrent().apply(text);
        }

        return text;
    }
}
