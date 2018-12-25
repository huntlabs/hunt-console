module hunt.console.helper.PlaceholderFormatter;

import hunt.console.output.Output;

public interface PlaceholderFormatter
{
    public string format(ProgressBar bar, Output output);
}
