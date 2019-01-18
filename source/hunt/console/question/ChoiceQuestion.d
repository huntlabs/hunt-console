module hunt.console.question.ChoiceQuestion;

import hunt.collection.HashMap;
import hunt.console.question.Question;

class ChoiceQuestion : Question
{
    private HashMap!(string, string) choices;
    private bool multiselect = false;
    private string prompt = " > ";
    private string errorMessage = "Value '%s' is invalid";

    public this(string question, HashMap!(string, string) choices, string defaultValue)
    {
        super(question, defaultValue);
        this.choices = choices;
    }

}
