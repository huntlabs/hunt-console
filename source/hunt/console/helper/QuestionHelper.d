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
 
module hunt.console.helper.QuestionHelper;

import hunt.console.input.Input;
import hunt.console.output.Output;
import hunt.console.question.ChoiceQuestion;
import hunt.console.question.Question;
import hunt.console.helper.AbstractHelper;

import hunt.Exceptions;
import hunt.stream.Common;
import hunt.stream.FileInputStream;

import std.stdio;

class QuestionHelper : AbstractHelper
{
    private InputStream inputStream;

    public string ask(Input input, Output output, Question question)
    {
        if (!input.isInteractive()) {
            return question.getDefaultValue();
        }

        return doAsk(output, question);
    }

    protected string doAsk(Output output, Question question)
    {
        InputStream inputStream = this.inputStream is null ? new FileInputStream(stdin) : this.inputStream;

        string message = question.getQuestion();
        if (cast(ChoiceQuestion)question !is null) {

        }

        output.writeln(message);

        string answer;

        if (question.isHidden()) {
            implementationMissing();
        } else {
            implementationMissing();
        }

        if (answer is null || answer.length == 0) {
            answer = question.getDefaultValue();
        }

        return answer;
    }

    public InputStream getInputStream()
    {
        return inputStream;
    }

    public void setInputStream(InputStream inputStream)
    {
        this.inputStream = inputStream;
    }

    /* override */ public string getName()
    {
        return "question";
    }
}
