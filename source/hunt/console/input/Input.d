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


abstract class Input
{
    string getFirstArgument();

    bool hasParameterOption(string value, bool onlyParams = false) {
        return hasParameterOption([value], onlyParams);
    }

    bool hasParameterOption(string[] values, bool onlyParams = false);

    string getParameterOption(string value, bool onlyParams = false) {
        return getParameterOption([value], null, onlyParams);
    }

    string getParameterOption(string value, string defaultValue, bool onlyParams = false) {
        return getParameterOption([value], defaultValue, onlyParams);
    }

    string getParameterOption(string[] values, string defaultValue, bool onlyParams = false);
    // string getParameterOption(string value);

    // string getParameterOption(string value, string defaultValue);

    void bind(InputDefinition definition);

    void validate() /* throws RuntimeException */;

    string[] getArguments();

    string getArgument(string name);

    void setArgument(string name, string value) /* throws InvalidArgumentException */;

    bool hasArgument(string name);

    string[] getOptions();

    string getOption(string name);

    void setOption(string name, string value) /* throws InvalidArgumentException */;

    bool hasOption(string name);

    bool isInteractive();

    void setInteractive(bool interactive);
}
