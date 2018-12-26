module hunt.console.question.ChoiceQuestion;

import hunt.container.HashMap;

class ChoiceQuestion : Question
{
    private HashMap!(string, string) choices;
    private boolean multiselect = false;
    private string prompt = " > ";
    private string errorMessage = "Value '%s' is invalid";

    public ChoiceQuestion(string question, HashMap!(string, string) choices, string defaultValue)
    {
        super(question, defaultValue);
        this.choices = choices;
    }

}
