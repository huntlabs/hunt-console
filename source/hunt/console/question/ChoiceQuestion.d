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
