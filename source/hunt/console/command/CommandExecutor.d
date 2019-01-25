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
 
module hunt.console.command.CommandExecutor;

import hunt.console.input.Input;
import hunt.console.output.Output;

public interface CommandExecutor
{
    public int execute(Input input, Output output);
}
