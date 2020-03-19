/*
 * hunt-console eases the creation of beautiful and testable command line interfaces.
 *
 * Copyright (C) 2018-2019, HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.console.helper.ProgressBar;

import hunt.console.error.LogicException;
import hunt.console.output.Output;
import hunt.console.output.Verbosity;
import hunt.console.util.StringUtils;

import hunt.Exceptions;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.console.helper.PlaceholderFormatter;
import hunt.util.DateTime;
import hunt.text.StringBuilder;
import hunt.collection.StringBuffer;
import hunt.math.Helper;
import hunt.console.helper.AbstractHelper;
import hunt.console.output.Verbosity;

import std.regex;
import std.string;
import std.conv;

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

        startTime = DateTime.currentTimeMillis();
    }

    public static void setPlaceholderFormatter(string name, PlaceholderFormatter formatter)
    {
        if (formatters is null) {
            formatters = initPlaceholderFormatters();
        }

        formatters.put(name, formatter);
    }

    public static PlaceholderFormatter getPlaceholderFormatter(string name)
    {
        if (formatters is null) {
            formatters = initPlaceholderFormatters();
        }

        return formatters.get(name);
    }

    public static void setFormatDefinition(string name, string format)
    {
        if (formats is null) {
            formats = initFormats();
        }

        formats.put(name, format);
    }

    public static string getFormatDefinition(string name)
    {
        if (formats is null) {
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
        if (barChar is null) {
            return (max == int.init || max == 0) ? emptyBarChar : "=";
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
        if (max == int.init || max == 0 && getFormatDefinition(format ~ "_nomax") !is null) {
            this.format = getFormatDefinition(format ~ "_nomax");
        } else if (getFormatDefinition(format) !is null) {
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
        start(int.init);
    }

    public void start(int max)
    {
        startTime = DateTime.currentTimeMillis();
        step = 0;
        percent = 0f;

        if (max != int.init) {
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

        if (max != int.init && max > 0 && step > max) {
            max = step;
        }

        int prevPeriod = this.step / redrawFreq;
        int currPeriod = step / redrawFreq;
        this.step = step;
        percent = (max != int.init && max > 0) ? (cast(float) step) / max : 0f;
        if (prevPeriod != currPeriod || (max != int.init && max == step)) {
            display();
        }
    }

    public void finish()
    {
        if (max == int.init || max == 0) {
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

        string pattern = ("%([a-z\\-_]+)(?:\\:([^%]+))?%"/* , Pattern.CASE_INSENSITIVE */);
        auto matchers = matchAll(this.format,regex(pattern,"i"));

        int startPos = 0;
        string text = "";
        StringBuffer sb = new StringBuffer();
        foreach(matcher ; matchers) {
            string format = matcher.captures[1];
            PlaceholderFormatter formatter = getPlaceholderFormatter(format);
            if (formatter !is null) {
                text = formatter.format(this, output);
            } else if (format !is null) {
                text = messages.get(format);
            }

            if (matcher.captures[2] !is null) {
                text = std.string.format("%" ~ matcher.captures[2], text);
            }

            // matcher.appendReplacement(sb, text);
            auto pos = cast(int)(this.format.indexOf(format));
            sb.append(this.format[startPos..pos].replace(format,text));
            startPos = pos + cast(int)(format.length);
        }
        // matcher.appendTail(sb);
        sb.append(this.format[startPos .. $]);

        overwrite(sb.toString());
    }

    public void clear()
    {
        if (!_overwrite) {
            return;
        }

        char[] array = new char[formatLineCount];
        // Arrays.fill(array, '\n');
        for(int i = 0 ; i<formatLineCount; i++ )
            array[i] = '\n';

        overwrite(cast(string)(array));
    }

    public void setMaxSteps(int max)
    {
        this.max = MathHelper.max(0, max);
        stepWidth = this.max > 0 ? cast(int)(max.to!string.length) : 4;
    }

    public void overwrite(string message)
    {
        string[] lines = StringUtils.split(message, '\n');

        // append whitespace to match the line's length
        if (lastMessagesLength != int.init) {
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
            output.write(std.string.format("\033[%dA", formatLineCount));
        }
        output.write(StringUtils.join(lines, "\n"));

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
        switch (output.getVerbosity()) with(Verbosity){
            case VERBOSE:
                return max == int.init || max == 0 ? "verbose_nomax" : "verbose";
            case VERY_VERBOSE:
                return max == int.init || max == 0 ? "very_verbose_nomax" : "very_verbose";
            case DEBUG:
                return max == int.init || max == 0 ? "debug_nomax" : "debug";
            default:
                return max == int.init || max == 0 ? "normal_nomax" : "normal";
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
                    int emptyBars = bar.getBarWidth() - completeBars - AbstractHelper.strlenWithoutDecoration(output.getFormatter(), to!string(bar.getProgressCharacter()));
                    display ~= bar.getProgressCharacter() ~ StringUtils.padRight("", emptyBars, bar.getEmptyBarCharacter());
                }

                return display;
            }
        });

        formatters.put("elapsed", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                import std.math;
                return AbstractHelper.formatTime(cast(long)/* MathHelper. */round(( DateTime.currentTimeMillis() / 1000) - (bar.getStartTime() / 1000)));
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
                    import std.math;
                    remaining = /* MathHelper. */cast(long)round(cast(float) ( DateTime.currentTimeMillis() / 1000 - bar.getStartTime() / 1000) / cast(float) bar.getProgress() * (cast(float) bar.getMaxSteps() - cast(float) bar.getProgress()));
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
                    import std.math;
                    estimated =/*  MathHelper. */cast(long)round(cast(float) ( DateTime.currentTimeMillis() / 1000 - bar.getStartTime() / 1000) / cast(float) bar.getProgress() * cast(float) bar.getMaxSteps());
                }

                return AbstractHelper.formatTime(estimated);
            }
        });

        formatters.put("memory", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                implementationMissing();
                return null;
                // return AbstractHelper.formatMemory(Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory());
            }
        });

        formatters.put("current", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return StringUtils.padLeft(to!string(bar.getProgress()), bar.getStepWidth(), " ");
            }
        });

        formatters.put("max", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return to!string(bar.getMaxSteps());
            }
        });

        formatters.put("percent", new class PlaceholderFormatter
        {
            override public string format(ProgressBar bar, Output output)
            {
                return to!string(cast(int) (bar.getProgressPercent() * 100));
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
