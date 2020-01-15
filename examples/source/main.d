import std.stdio;

import core.thread;
import hunt.console;
import hunt.Exceptions;
import hunt.logging;

void main(string[] args)
{
    auto console = new Console("Hunt Console", "1.0.0");

    console.setAutoExit(false);
    console.add(new GreetingCommand());
    console.add((new Command("test")).setExecutor(new class CommandExecutor {
        override public int execute(Input input, Output output)
        {
            ProgressBar bar = new ProgressBar(output, 500);

            for (int i = 0; i < 500; i++)
            {
                bar.advance();
                try
                {
                    Thread.sleep( 5.seconds );
                }
                catch (InterruptedException ex)
                {
                    // Thread.currentThread().interrupt();
                }
            }

            bar.finish();

            return;
        }
    }));

    console.run(args);
}
