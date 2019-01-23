import std.stdio;

import hunt.console;
import core.thread;
import hunt.Exceptions;
import hunt.logging;

void main(string[] args)
{
	Application app = new Application("Hunt Console", "1.0.0");
	app.setAutoExit(false);
	app.add(new GreetingCommand());

	app.add((new Command("test")).setExecutor(new class CommandExecutor {
		override public int execute(Input input, Output output)
		{
			ProgressBar bar = new ProgressBar(output, 500);
			
			for (int i = 0; i < 500; i++)
			{
				bar.advance();
				try {
					Thread.sleep(dur!("seconds")( 5 ));
				} catch (InterruptedException ex) {
					// Thread.currentThread().interrupt();
				}
			}
			bar.finish();
			return 0;
		}
	}));
	// logInfo("run args: ",args);
	if(args.length > 1)
		app.run(args[1..$]);
	else
		app.run([]);
}
