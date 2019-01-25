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
 
module hunt.console.formatter.OutputFormatterStyle;

public interface OutputFormatterStyle
{
    public void setForeground(string color);

    public void setBackground(string color);

    public void setOption(string option);

    public void unsetOption(string option);

    public void setOptions(string[] options...);

    public string apply(string text);
}
