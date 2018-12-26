module hunt.console.helper.QuestionHelper;

import hunt.console.input.Input;
import hunt.console.output.Output;
import hunt.console.question.ChoiceQuestion;
import hunt.console.question.Question;

import hunt.io.InputStream;
import hunt.container.Scanner;

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
        InputStream inputStream = this.inputStream == null ? System.in : this.inputStream;

        string message = question.getQuestion();
        if (cast(ChoiceQuestion)question !is null) {

        }

        output.writeln(message);

        string answer;
        if (question.isHidden()) {
            Console console = System.console();
            if (console == null) {
                throw new RuntimeException("Unable to hide input (console not available)");
            }
            answer = String.valueOf(console.readPassword());
        } else {
            Scanner scanner = new Scanner(inputStream);
            answer = scanner.next();
        }

        if (answer == null || answer.isEmpty()) {
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

    override public string getName()
    {
        return "question";
    }
}
