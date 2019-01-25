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
 
module hunt.console.error.InvalidArgumentException;

import hunt.Exceptions;

class InvalidArgumentException : RuntimeException
{
    public this(string message)
    {
        super(message);
    }
}
