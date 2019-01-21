module hunt.console.formatter.OutputFormatterStyleStack;

import hunt.console.error.InvalidArgumentException;
import hunt.console.formatter.OutputFormatterStyle;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.console.formatter.DefaultOutputFormatterStyle;

class OutputFormatterStyleStack
{
    List!(OutputFormatterStyle) styles;

    OutputFormatterStyle emptyStyle;

    public this()
    {
        this(new DefaultOutputFormatterStyle());
    }

    public this(OutputFormatterStyle emptyStyle)
    {
        this.emptyStyle = emptyStyle;
        reset();
    }

    public void reset()
    {
        styles = new ArrayList!(OutputFormatterStyle)();
    }

    public void push(OutputFormatterStyle style)
    {
        styles.add(style);
    }

    public OutputFormatterStyle pop()
    {
        return pop(null);
    }

    public OutputFormatterStyle pop(OutputFormatterStyle style)
    {
        if (styles.size() == 0) {
            return emptyStyle;
        }

        if (style is null) {
            return styles.removeAt(styles.size() - 1);
        }

        OutputFormatterStyle stackedStyle;
        for (int i = (styles.size() - 1); i >= 0; i--) {
            stackedStyle = styles.get(i);
            if (style.apply("") == (stackedStyle.apply(""))) {
                auto substyles = new ArrayList!(OutputFormatterStyle)();
                for(int j = 0 ;j < i;j++)
                {   
                    substyles.add(styles.get(i));
                }
                styles = substyles;
                return stackedStyle;
            }
        }

        throw new InvalidArgumentException("Incorrectly nested style tag found.");
    }

    public OutputFormatterStyle getCurrent()
    {
        if (styles.size() == 0) {
            return emptyStyle;
        }

        return styles.get(styles.size() - 1);
    }

    public OutputFormatterStyle getEmptyStyle()
    {
        return emptyStyle;
    }

    public void setEmptyStyle(OutputFormatterStyle emptyStyle)
    {
        this.emptyStyle = emptyStyle;
    }
}
