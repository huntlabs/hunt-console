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
 
module hunt.console.formatter.OutputFormatter;
import hunt.console.formatter.OutputFormatterStyle;

public interface OutputFormatter
{
    public void setDecorated(bool decorated);

    public bool isDecorated();

    public void setStyle(string name, OutputFormatterStyle style);

    public bool hasStyle(string name);

    public OutputFormatterStyle getStyle(string name);

    public string format(string message);
}
