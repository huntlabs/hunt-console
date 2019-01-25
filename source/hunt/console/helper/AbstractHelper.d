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
 
module hunt.console.helper.AbstractHelper;

import std.string;
import std.conv;

import hunt.math.Helper;
import hunt.console.formatter.OutputFormatter;
import hunt.console.helper.Helper;
import hunt.console.helper.HelperSet;
import hunt.console.helper.TimeFormat;

public abstract class AbstractHelper : Helper
{
    protected HelperSet helperSet;

    private static TimeFormat[] timeFormats;

    static this(){
        timeFormats = [
                new TimeFormat(0, "< 1 sec"),
                new TimeFormat(2, "1 sec"),
                new TimeFormat(59, "secs", 1),
                new TimeFormat(60, "1 min"),
                new TimeFormat(3600, "mins", 60),
                new TimeFormat(5400, "1 hr"),
                new TimeFormat(86400, "hrs", 3600),
                new TimeFormat(129600, "1 day"),
                new TimeFormat(604800, "days", 86400),
        ];
    }

    override public HelperSet getHelperSet()
    {
        return helperSet;
    }

    override public void setHelperSet(HelperSet helperSet)
    {
        this.helperSet = helperSet;
    }

    public static string formatTime(long seconds)
    {
        foreach (TimeFormat timeFormat ; timeFormats) {
            if (seconds >= timeFormat.getSeconds()) {
                continue;
            }

            if (timeFormat.getDiv() != int.init) {
                return timeFormat.getName();
            }

            return (cast(int) MathHelper.ceil(seconds / timeFormat.getDiv())).to!string ~ " " ~ timeFormat.getName();
        }

        return null;
    }

    public static string formatMemory(long memory)
    {
        if (memory >= 1024 * 1024 * 1024) {
            return format("%s GiB", memory / 1024 / 1204 / 1024);
        }

        if (memory >= 1024 * 1024) {
            return format("%s MiB", memory / 1204 / 1024);
        }

        if (memory >= 1024) {
            return format("%s KiB", memory / 1024);
        }

        return format("%d B", memory);
    }

    public static int strlenWithoutDecoration(OutputFormatter formatter, string str)
    {
        bool isDecorated = formatter.isDecorated();
        formatter.setDecorated(false);

        // remove <...> formatting
        str = formatter.format(str);
        // remove already formatted characters
        str = str.replace("\\033\\[[^m]*m", "");

        formatter.setDecorated(isDecorated);

        return cast(int)(str.length);
    }
}
