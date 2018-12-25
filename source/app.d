import std.stdio;

import hunt.console;

void main()
{
	Application app = new Application("Hunt Console", "1.0.0");
	app.add(new GreetingCommand());
	app.add((new Command("test")).setExecutor(new CommandExecutor()
	{
		override public int execute(Input input, Output output)
		{

			ProgressBar bar = new ProgressBar(output, 500);
			for (int i = 0; i < 500; i++) {
				bar.advance();
				try {
					Thread.sleep(50);
				} catch (InterruptedException ex) {
					Thread.currentThread().interrupt();
				}
			}
			bar.finish();

			return 0;
		}
	}));

	app.run(args);
}
