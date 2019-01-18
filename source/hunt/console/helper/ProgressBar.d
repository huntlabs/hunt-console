module hunt.console.helper.ProgressBar;

import hunt.console.error.LogicException;
import hunt.console.output.Output;
import hunt.console.output.Verbosity;
import hunt.console.util.StringUtils;

// import hunt.collection.Arrays;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.console.helper.PlaceholderFormatter;

import std.regex;

class ProgressBar
{
    // options
    private int barWidth = 28;
    private string barChar;
    private string emptyBarChar = "-";
    private string progressChar = ">";
    private string format = null;
    private int redrawFreq = 1;

    private Output output;
    private int step = 0;
    private int max;
    private long startTime;
    private int stepWidth;
    private float percent = 0f;
    private int lastMessagesLength = 0;
    private int formatLineCount;
    private Map!(string, string) messages ;
    private bool _overwrite = true;

    private static Map!(string, PlaceholderFormatter) formatters;
    private static Map!(string, string) formats;

    public this(Output output)
    {
        messages = new HashMap!(string, string)();
        this(output, 0);
    }

    public this(Output output, int max)
    {
        this.output = output;
        setMaxSteps(max);

        if (!this.output.isDecorated()) {
            // disable _overwrite when output does not support ANSI codes.
            _overwrite = false;

            if (this.max > 10) {
                // set a reasonable redraw frequency so output isn't flooded
                setRedrawFrequency(max / 10);
            }
        }

        setFormat(determineBestFormat());

        startTime = DateTimeHelper.currentTimeMillis();
    }

    public static void setPlaceholderFormatter(string name, PlaceholderFormatter formatter)
    {
        if (formatters == null) {
            formatters = initPlaceholderFormatters();
        }

        formatters.put(name, formatter);
    }

    public static PlaceholderFormatter getPlaceholderFormatter(string name)
    {
        if (formatters == null) {
            formatters = initPlaceholderFormatters();
        }

        return formatters.get(name);
    }

    public static void setFormatDefinition(string name, string format)
    {
        if (formats == null) {
            formats = initFormats();
        }

        formats.put(name, format);
    }

    public static string getFormatDefinition(string name)
    {
        if (formats == null) {
            formats = initFormats();
        }

        return formats.get(name);
    }

    public void setMessage(string message)
    {
        setMessage(message, "message");
    }

    public void setMessage(string message, string name)
    {
        messages.put(name, message);
    }

    public string getMessage()
    {
        return getMessage("message");
    }

    public string getMessage(string name)
    {
        return messages.get(name);
    }

    public long getStartTime()
    {
        return startTime;
    }

    public int getMaxSteps()
    {
        return max;
    }

    public int getProgress()
    {
        return step;
    }

    public int getStepWidth()
    {
        return stepWidth;
    }

    public float getProgressPercent()
    {
        return percent;
    }

    public void setBarWidth(int barWidth)
    {
        this.barWidth = barWidth;
    }

    public int getBarWidth()
    {
        return barWidth;
    }

    public void setBarCharacter(string c)
    {
        barChar = c;
    }

    public string getBarCharacter()
    {
        if (barChar == null) {
            return (max == null || max == 0) ? emptyBarChar : "=";
        }

        return barChar;
    }

    public void setEmptyBarCharacter(string c)
    {
        this.emptyBarChar = c;
    }

    public string getEmptyBarCharacter()
    {
        return emptyBarChar;
    }

    public void setProgressCharacter(string c)
    {
        this.progressChar = c;
    }

    public string getProgressCharacter()
    {
        return progressChar;
    }

    public void setFormat(string format)
    {
        // try to use the _nomax variant if available
        if (max == null || max == 0 && getFormatDefinition(format ~ "_nomax") != null) {
            this.format = getFormatDefinition(format ~ "_nomax");
        } else if (getFormatDefinition(format) != null) {
            this.format = getFormatDefinition(format);
        } else {
            this.format = format;
        }

        formatLineCount = StringUtils.count(this.format, '\n');
    }

    public void setRedrawFrequency(int freq)
    {
        this.redrawFreq = freq;
    }

    public void start()
    {
        start(null);
    }

    public void start(int max)
    {
        startTime = DateTimeHelper.currentTimeMillis();
        step = 0;
        percent = 0f;

        if (max != null) {
            setMaxSteps(max);
        }

        display();
    }

    public void advance()
    {
        advance(1);
    }

    public void advance(int step)
    {
        setProgress(this.step + step);
    }

    public void setCurrent(int step)
    {
        setProgress(step);
    }

    public void setOverwrite(bool overwrite)
    {
        this._overwrite = overwrite;
    }

    public void setProgress(int step)
    {
        if (step < this.step) {
            throw new LogicException("You can't regress the progress bar.");
        }

        if (max != null && max > 0 && step > max) {
            max = step;
        }

        int prevPeriod = this.step / redrawFreq;
        int currPeriod = step / redrawFreq;
        this.step = step;
        percent = (max != null && max > 0) ? (cast(float) step) / max : 0f;
        if (prevPeriod != currPeriod || (max != null && max == step)) {
            display();
        }
    }

    public void finish()
    {
        if (max == null || max == 0) {
            max = step;
        }

        if (step == max && !_overwrite) {
            // prevent double 100% output
            return;
        }

        setProgress(max);
    }

    public void display()
    {
        if (output.getVerbosity() == Verbosity.QUIET) {
            return;
        }

        Pattern pattern = Pattern.compile("%([a-z\\-_]+)(?:\\:([^%]+))?%", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(format);

        string text = "";
        StringBuffer sb = new StringBuffer();
        while (matcher.find()) {
            string format = matcher.group(1);
            PlaceholderFormatter formatter = getPlaceholderFormatter(format);
            if (formatter != null) {
                text = formatter.format(this, output);
            } else if (format != null) {
                text = messages.get(format);
            }

            if (matcher.group(2) != null) {
                text = String.format("%" ~ matcher.group(2), text);
            }

            matcher.appendReplacement(sb, text);
        }
        matcher.appendTail(sb);

        overwrite(sb.toString());
    }

    public void clear()
    {
        if (!_overwrite) {
            return;
        }

        char[] array = new char[formatLineCount];
        Arrays.fill(array, '\n');

        overwrite(new String(array));
    }

    public void setMaxSteps(int max)
    {
        this.max = Math.max(0, max);
        stepWidth = this.max > 0 ? max.toString().length() : 4;
    }

    public void overwrite(string message)
    {
        String[] lines = StringUtils.split(message, '\n');

        // append whitespace to match the line's length
        if (lastMessagesLength != null) {
            for (int i = 0; i < lines.length; i++) {
                if (lastMessagesLength > AbstractHelper.strlenWithoutDecoration(output.getFormatter(), lines[i])) {
                    lines[i] = StringUtils.padRight(lines[i], lastMessagesLength, " ");
                }
            }
        }

        if (_overwrite) {
            // move back to the beginning of the progress bar before redrawing it
            output.write("\r");
        } else if (step > 0) {
            // move to new line
            output.writeln("");
        }

        if (formatLineCount > 0) {
            output.write(string.format("\033[%dA", formatLineCount));
        }
        output.write(stringUtils.join(lines, "\n"));

        lastMessagesLength = 0;
        foreach (string line ; lines) {
            int len = AbstractHelper.strlenWithoutDecoration(output.getFormatter(), line);
            if (len > lastMessagesLength) {
                lastMessagesLength = len;
            }
        }
    }

    public string determineBestFormat()
    {
        switch (output.getVerbosity()) {
            case VERBOSE:
                return max == null || max == 0 ? "verbose_nomax" : "verbose";
            case VERY_VERBOSE:
                return max == null || max == 0 ? "very_verbose_nomax" : "very_verbose";
            case DEBUG:
                return max == null || max == 0 ? "debug_nomax" : "debug";
            default:
                return max == null || max == 0 ? "normal_nomax" : "normal";
        }
    }

    public static Map!(string, PlaceholderFormatter) initPlaceholderFormatters()
    {
        Map!(string, PlaceholderFormatter) formatters = new HashMap!(string, PlaceholderFormatter)();

        formatters.put("bar", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                int completeBars = bar.getMaxSteps() > 0 ? cast(int) (bar.getProgressPercent() * bar.getBarWidth()) : bar.getProgress() % bar.getBarWidth();
                string display = StringUtils.padRight("", completeBars, bar.getBarCharacter());
                if (completeBars < bar.getBarWidth()) {
                    int emptyBars = bar.getBarWidth() - completeBars - AbstractHelper.strlenWithoutDecoration(output.getFormatter(), string.valueOf(bar.getProgressCharacter()));
                    display += bar.getProgressCharacter() + StringUtils.padRight("", emptyBars, bar.getEmptyBarCharacter());
                }

                return display;
            }
        });

        formatters.put("elapsed", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return AbstractHelper.formatTime(Math.round(( DateTimeHelper.currentTimeMillis() / 1000) - (bar.getStartTime() / 1000)));
            }
        });

        formatters.put("remaining", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                if (bar.getMaxSteps() == 0) {
                    throw new LogicException("Unable to display the remaining time if the maximum number of steps is not set.");
                }

                long remaining;
                if (bar.getProgress() == 0) {
                    remaining = 0;
                } else {
                    remaining = Math.round(cast(float) ( DateTimeHelper.currentTimeMillis() / 1000 - bar.getStartTime() / 1000) / cast(float) bar.getProgress() * (cast(float) bar.getMaxSteps() - cast(float) bar.getProgress()));
                }

                return AbstractHelper.formatTime(remaining);
            }
        });

        formatters.put("estimated", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                if (bar.getMaxSteps() == 0) {
                    throw new LogicException("Unable to display the estimated time if the maximum number of steps is not set.");
                }

                long estimated;
                if (bar.getProgress() == 0) {
                    estimated = 0;
                } else {
                    estimated = Math.round(cast(float) ( DateTimeHelper.currentTimeMillis() / 1000 - bar.getStartTime() / 1000) / cast(float) bar.getProgress() * cast(float) bar.getMaxSteps());
                }

                return AbstractHelper.formatTime(estimated);
            }
        });

        formatters.put("memory", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return AbstractHelper.formatMemory(Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory());
            }
        });

        formatters.put("current", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return StringUtils.padLeft(string.valueOf(bar.getProgress()), bar.getStepWidth(), " ");
            }
        });

        formatters.put("max", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return String.valueOf(bar.getMaxSteps());
            }
        });

        formatters.put("percent", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return String.valueOf(cast(int) (bar.getProgressPercent() * 100));
            }
        });

        return formatters;
    }

    private static Map!(string, string) initFormats()
    {
        Map!(string, string) formats = new HashMap!(string, string)();

        formats.put("normal", " %current%/%max% [%bar%] %percent:3s%%");
        formats.put("normal_nomax", " %current% [%bar%]");

        formats.put("verbose", " %current%/%max% [%bar%] %percent:3s%% %elapsed:6s%");
        formats.put("verbose_nomax", " %current% [%bar%] %elapsed:6s%");

        formats.put("very_verbose", " %current%/%max% [%bar%] %percent:3s%% %elapsed:6s%/%estimated:-6s%");
        formats.put("very_verbose_nomax", " %current% [%bar%] %elapsed:6s%");

        formats.put("debug", " %current%/%max% [%bar%] %percent:3s%% %elapsed:6s%/%estimated:-6s% %memory:6s%");
        formats.put("debug_nomax", " %current% [%bar%] %elapsed:6s% %memory:6s%");

        return formats;
    }
}
