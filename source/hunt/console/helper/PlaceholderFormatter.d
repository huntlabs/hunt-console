module hunt.console.helper.PlaceholderFormatter;

import hunt.console.output.Output;
import hunt.console.helper.ProgressBar;

public interface PlaceholderFormatter
{
    public string format(ProgressBar bar, Output output);
}
