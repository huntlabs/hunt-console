module hunt.console.formatter;

class OutputFormatterOption
{
    private int set;

    private int unset;

    public OutputFormatterOption(int set, int unset)
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

    override public boolean equals(Object o)
    {
        if (this == o) return true;
        if (!(cast(OutputFormatterOption)o !is null)) return false;

        OutputFormatterOption that = (OutputFormatterOption) o;

        if (set != that.set) return false;
        if (unset != that.unset) return false;

        return true;
    }

    override public size_t toHash() @trusted nothrow()
    {
        int result = set;
        result = 31 * result + unset;
        return result;
    }
}
