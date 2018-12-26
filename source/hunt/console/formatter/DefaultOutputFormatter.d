module hunt.console.formatter.DefaultOutputFormatter;

import hunt.console.error.InvalidArgumentException;

import hunt.container.HashMap;
import hunt.container.Map;

import std.regex;

class DefaultOutputFormatter : OutputFormatter
{
    private boolean decorated;

    private Map!(string, OutputFormatterStyle) styles = new HashMap!(string, OutputFormatterStyle)();

    private OutputFormatterStyleStack styleStack;

    public static string TAG_REGEX = "[a-z][a-z0-9_=;-]*";

    public static Pattern TAG_PATTERN = Pattern.compile("<((" ~ TAG_REGEX ~ ")|/(" ~ TAG_REGEX ~ ")?)>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    public static Pattern STYLE_PATTERN = Pattern.compile("([^=]+)=([^;]+)(;|$)");

    public static string escape(string text)
    {
        Pattern pattern = Pattern.compile("([^\\\\\\\\]?)<", Pattern.DOTALL);

        return pattern.matcher(text).replaceAll("$1\\\\<");
    }

    public DefaultOutputFormatter()
    {
        this(false);
    }

    public DefaultOutputFormatter(boolean decorated)
    {
        this(decorated, new HashMap!(string, OutputFormatterStyle)());
    }

    public DefaultOutputFormatter(boolean decorated, Map!(string, OutputFormatterStyle) styles)
    {
        this.decorated = decorated;

        setStyle("error", new DefaultOutputFormatterStyle("white", "red"));
        setStyle("info", new DefaultOutputFormatterStyle("green"));
        setStyle("comment", new DefaultOutputFormatterStyle("yellow"));
        setStyle("question", new DefaultOutputFormatterStyle("black", "cyan"));

        this.styles.putAll(styles);

        styleStack = new OutputFormatterStyleStack();
    }

    override public void setDecorated(boolean decorated)
    {
        this.decorated = decorated;
    }

    override public boolean isDecorated()
    {
        return decorated;
    }

    override public void setStyle(string name, OutputFormatterStyle style)
    {
        styles.put(name.toLowerCase(), style);
    }

    override public boolean hasStyle(string name)
    {
        return styles.containsKey(name.toLowerCase());
    }

    override public OutputFormatterStyle getStyle(string name)
    {
        if (!hasStyle(name)) {
            throw new InvalidArgumentException(string.format("Undefined style: %s", name));
        }

        return styles.get(name);
    }

    override public string format(string message)
    {
        if (message == null) {
            return "";
        }

        int offset = 0;
        StringBuilder output = new StringBuilder();

        Matcher matcher = TAG_PATTERN.matcher(message);

        boolean open;
        string tag;
        OutputFormatterStyle style;
        while (matcher.find()) {
            int pos = matcher.start();
            string text = matcher.group();

            // add the text up to the next tag
            output.append(applyCurrentStyle(message.substring(offset, pos)));
            offset = pos + text.length();

            // opening tag?
            open = text[1] != '/';
            if (open) {
                tag = matcher.group(2);
            } else {
                tag = matcher.group(3);
            }

            if (!open && (tag == null || tag.isEmpty())) {
                // </>
                styleStack.pop();
            } else if (pos > 0 && message.charAt(pos - 1) == '\\') {
                // escaped tag
                output.append(applyCurrentStyle(text));
            } else {
                style = createStyleFromString(tag.toLowerCase());
                if (style == null) {
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

        return output.toString().replaceAll("\\\\<", "<");
    }

    private OutputFormatterStyle createStyleFromString(string string)
    {
        if (styles.containsKey(string)) {
            return styles.get(string);
        }

        Matcher matcher = STYLE_PATTERN.matcher(string.toLowerCase());

        OutputFormatterStyle style = new DefaultOutputFormatterStyle();

        string type;
        while (matcher.find()) {
            type = matcher.group(1);
            switch (type) {
                case "fg":
                    style.setForeground(matcher.group(2));
                    break;
                case "bg":
                    style.setBackground(matcher.group(2));
                    break;
                default:
                    try {
                        style.setOption(matcher.group(2));
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
        if (isDecorated() && text.length() > 0) {
            return styleStack.getCurrent().apply(text);
        }

        return text;
    }
}
