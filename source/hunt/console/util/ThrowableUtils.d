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
 
module hunt.console.util.ThrowableUtils;

// import hunt.io.PrintWriter;
// import hunt.io.StringWriter;
// import hunt.io.Writer;

class ThrowableUtils
{
    public static string getThrowableAsString(Throwable throwable)
    {
        // final Writer result = new StringWriter();
        // final PrintWriter printWriter = new PrintWriter(result);
        // throwable.printStackTrace(printWriter);
        return throwable.toString();
    }
}
