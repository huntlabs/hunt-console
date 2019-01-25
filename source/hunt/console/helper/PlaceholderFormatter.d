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
 
module hunt.console.helper.PlaceholderFormatter;

import hunt.console.output.Output;
import hunt.console.helper.ProgressBar;

public interface PlaceholderFormatter
{
    public string format(ProgressBar bar, Output output);
}
