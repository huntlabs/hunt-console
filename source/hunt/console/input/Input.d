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
 
module hunt.console.input.Input;

import hunt.console.error.InvalidArgumentException;
import hunt.console.input.InputDefinition;


public interface Input
{
    public string getFirstArgument();

    public bool hasParameterOption(string[] values...);

    public string getParameterOption(string value);

    public string getParameterOption(string value, string defaultValue);

    public void bind(InputDefinition definition);

    public void validate() /* throws RuntimeException */;

    public string[] getArguments();

    public string getArgument(string name);

    public void setArgument(string name, string value) /* throws InvalidArgumentException */;

    public bool hasArgument(string name);

    public string[] getOptions();

    public string getOption(string name);

    public void setOption(string name, string value) /* throws InvalidArgumentException */;

    public bool hasOption(string name);

    public bool isInteractive();

    public void setInteractive(bool interactive);
}
