module hunt.console.question.Question;

import hunt.console.error.InvalidArgumentException;

public class Question
{
    private string question;
    private int attempts;
    private boolean hidden = false;
    private boolean hiddenFallback = true;
    private string defaultValue;

    public Question(string question)
    {
        this(question, null);
    }

    public Question(string question, string defaultValue)
    {
        this.question = question;
        this.defaultValue = defaultValue;
    }

    public string getQuestion()
    {
        return question;
    }

    public string getDefaultValue()
    {
        return defaultValue;
    }

    public boolean isHidden()
    {
        return hidden;
    }

    public Question setHidden(boolean hidden)
    {
        this.hidden = hidden;

        return this;
    }

    public boolean isHiddenFallback()
    {
        return hiddenFallback;
    }

    public Question setHiddenFallback(boolean hiddenFallback)
    {
        this.hiddenFallback = hiddenFallback;

        return this;
    }

    public Question setMaxAttempts(int attempts)
    {
        if (attempts != null && attempts < 1) {
            throw new InvalidArgumentException("Maximum number of attempts must be a positive value.");
        }

        this.attempts = attempts;

        return this;
    }

    public int getMaxAttempts()
    {
        return attempts;
    }
}
