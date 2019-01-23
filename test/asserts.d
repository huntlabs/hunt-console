module test.asserts;

private
{
    import hunt.console;
    import core.exception;
}

void assertEqual(T)(string msg, T result, T expected)
{
    static if (is(T == string))
        assert(expected == result, "Expected `" ~ expected ~ "`, got `" ~ result ~ "`");
    else
        assert(expected == result);
}

void assertEqual(T)(T result, T expected)
{
    static if (is(T == string))
        assert(expected == result, "Expected `" ~ expected ~ "`, got `" ~ result ~ "`");
    else
        assert(expected == result);
}

void assertNotEqual(T)(T result, T expected)
{
    static if (is(T == string))
        assert(expected != result, "Expected `" ~ expected ~ "`, got `" ~ result ~ "`");
    else
        assert(expected != result);
}

void assertTrue(string msg, bool result)
{
    assert(result);
}

void assertTrue(bool result)
{
    assert(result);
}

void assertFalse(string msg, bool result)
{
    assert(!result);
}

void assertFalse(bool result)
{
    assert(!result);
}

void assertFail(string message)
{
    if (message == null)
    {
        throw new AssertError("");
    }
    throw new AssertError(message);
}
