module hunt.console.question.Question;

import hunt.console.error.InvalidArgumentException;

class Question
{
    private string question;
    private int attempts;
    private bool hidden = false;
    private bool hiddenFallback = true;
    private string defaultValue;

    public this(string question)
    {
        this(question, null);
    }

    public this(string question, string defaultValue)
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

    public bool isHidden()
    {
        return hidden;
    }

    public Question setHidden(bool hidden)
    {
        this.hidden = hidden;

        return this;
    }

    public bool isHiddenFallback()
    {
        return hiddenFallback;
    }

    public Question setHiddenFallback(bool hiddenFallback)
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
