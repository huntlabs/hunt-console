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
 
module hunt.console.helper.TimeFormat;

class TimeFormat
{
    private int seconds;
    private string name;
    private int div;

    public this(int seconds, string name)
    {
        this.seconds = seconds;
        this.name = name;
    }

    public this(int seconds, string name, int div)
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
