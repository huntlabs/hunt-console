module hunt.console.input.Input;

import hunt.console.error.InvalidArgumentException;

public interface Input
{
    public string getFirstArgument();

    public boolean hasParameterOption(string... values);

    public string getParameterOption(string value);

    public string getParameterOption(string value, string defaultValue);

    public void bind(InputDefinition definition);

    public void validate() throws RuntimeException;

    public string[] getArguments();

    public string getArgument(string name);

    public void setArgument(string name, string value) throws InvalidArgumentException;

    public boolean hasArgument(string name);

    public string[] getOptions();

    public string getOption(string name);

    public void setOption(string name, string value) throws InvalidArgumentException;

    public boolean hasOption(string name);

    public boolean isInteractive();

    public void setInteractive(boolean interactive);
}
