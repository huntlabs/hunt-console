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
 
module hunt.console.formatter.OutputFormatterOption;

class OutputFormatterOption
{
    private int set;

    private int unset;

    public this(int set, int unset)
    {
        this.set = set;
        this.unset = unset;
    }

    public int getSet()
    {
        return set;
    }

    public int getUnset()
    {
        return unset;
    }

    override public bool opEquals(Object o)
    {
        if (this is o) return true;
        if (!(cast(OutputFormatterOption)o !is null)) return false;

        OutputFormatterOption that = cast(OutputFormatterOption) o;

        if (set != that.set) return false;
        if (unset != that.unset) return false;

        return true;
    }

    override public size_t toHash() @trusted nothrow
    {
        int result = set;
        result = 31 * result + unset;
        return result;
    }
}
