module test.ProgressBarTest;

import hunt.console.error.LogicException;
import hunt.console.output.Output;
import hunt.console.output.StreamOutput;
import hunt.console.output.Verbosity;
import hunt.console.util.StringUtils;
import hunt.console.helper.ProgressBar;
import test.asserts;
import std.string;
import hunt.io.ByteArrayOutputStream;

import hunt.console.helper.PlaceholderFormatter;
import hunt.console.helper.AbstractHelper;


   
    // unittest
    // {
    //     StreamOutput output = getOutputStream();
    //     ProgressBar bar = new ProgressBar(output);
    //     bar.start();
    //     bar.advance();
    //     bar.start();

    //     assertEqual(
    //             generateOutput("    0 [>---------------------------]") ~
    //             generateOutput("    1 [->--------------------------]") ~
    //             generateOutput("    0 [>---------------------------]"),
    //             getOutputString(output)
    //     );
    // }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.advance();

//         assertEqual(
//                 generateOutput("    0 [>---------------------------]") ~
//                 generateOutput("    1 [->--------------------------]"),
//                 getOutputString(output)
//         );
//     }

   
//    unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.advance(5);

//         assertEqual(
//                 generateOutput("    0 [>---------------------------]") ~
//                 generateOutput("    5 [----->----------------------]"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.advance(3);
//         bar.advance(2);

//         assertEqual(
//                 generateOutput("    0 [>---------------------------]") ~
//                 generateOutput("    3 [--->------------------------]") ~
//                 generateOutput("    5 [----->----------------------]"),
//                 getOutputString(output)
//         );
//     }

   
//    unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 10);
//         bar.setProgress(9);
//         bar.advance();
//         bar.advance();

//         assertEqual(
//                 generateOutput("  9/10 [=========================>--]  90%") ~
//                 generateOutput(" 10/10 [============================] 100%") ~
//                 generateOutput(" 11/11 [============================] 100%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 10);
//         bar.setBarWidth(10);
//         bar.setBarCharacter("_");
//         bar.setEmptyBarCharacter(" ");
//         bar.setProgressCharacter("/");
//         bar.setFormat(" %current%/%max% [%bar%] %percent:3s%%");
//         bar.start();
//         bar.advance();

//         assertEqual(
//                 generateOutput("  0/10 [/         ]   0%") ~
//                 generateOutput("  1/10 [_/        ]  10%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.display();

//         assertEqual(
//                 generateOutput("  0/50 [>---------------------------]   0%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream(true, Verbosity.QUIET);
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.display();

//         assertEqual(
//                 "",
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.finish();

//         assertEqual(
//                 generateOutput(" 50/50 [============================] 100%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.start();
//         bar.display();
//         bar.advance();
//         bar.advance();

//         assertEqual(
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  1/50 [>---------------------------]   2%") ~
//                 generateOutput("  2/50 [=>--------------------------]   4%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.setFormat(" %current%/%max% [%bar%] %percent:3s%%");
//         bar.start();
//         bar.display();
//         bar.advance();

//         // set shorter format
//         bar.setFormat(" %current%/%max% [%bar%]");
//         bar.advance();

//         assertEqual(
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  1/50 [>---------------------------]   2%") ~
//                 generateOutput("  2/50 [=>--------------------------]     "),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.setFormat("%current%/%max% [%bar%]");
//         bar.start(50);
//         bar.advance();

//         assertEqual(
//                 generateOutput(" 0/50 [>---------------------------]") ~
//                 generateOutput(" 1/50 [>---------------------------]"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.start();
//         bar.display();
//         bar.advance();
//         bar.setProgress(15);
//         bar.setProgress(25);

//         assertEqual(
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput("  1/50 [>---------------------------]   2%") ~
//                 generateOutput(" 15/50 [========>-------------------]  30%") ~
//                 generateOutput(" 25/50 [==============>-------------]  50%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.setProgress(15);

//         assert(bar.getStartTime() != long.init);
//     }

// //    unittest
// //     {
// //         StreamOutput output = getOutputStream();
// //         ProgressBar bar = new ProgressBar(output, 50);
// //         bar.start();
// //         bar.setProgress(15);
// //         bar.setProgress(10);
// //     }

   
//     // unittest
//     // {
//     //     StreamOutput output = getOutputStream();
//     //     ProgressBar bar = new ProgressBar(output, 6);
//     //     bar = spy(bar);

//     //     bar.setRedrawFrequency(2);
//     //     bar.start();
//     //     bar.setProgress(1);
//     //     bar.advance(2);
//     //     bar.advance(2);
//     //     bar.advance(1);

//     //     verify(bar, times(4)).display();
//     // }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.setBarCharacter("■");
//         bar.advance(3);

//         assertEqual(
//                 generateOutput("    0 [>---------------------------]") ~
//                 generateOutput("    3 [■■■>------------------------]"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.start();
//         bar.setProgress(25);
//         bar.clear();

//         assertEqual(
//                 generateOutput("  0/50 [>---------------------------]   0%") ~
//                 generateOutput(" 25/50 [==============>-------------]  50%") ~
//                 generateOutput("                                          "),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 200);
//         bar.start();
//         bar.display();
//         bar.advance(199);
//         bar.advance();

//         assertEqual(
//                 generateOutput("   0/200 [>---------------------------]   0%") ~
//                 generateOutput("   0/200 [>---------------------------]   0%") ~
//                 generateOutput(" 199/200 [===========================>]  99%") ~
//                 generateOutput(" 200/200 [============================] 100%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream(false, Verbosity.NORMAL);
//         ProgressBar bar = new ProgressBar(output, 200);
//         bar.start();

//         for (int i = 0; i < 200; i++) {
//             bar.advance();
//         }

//         bar.finish();

//         assertEqual(
//                 "   0/200 [>---------------------------]   0%\n" ~
//                 "  20/200 [==>-------------------------]  10%\n" ~
//                 "  40/200 [=====>----------------------]  20%\n" ~
//                 "  60/200 [========>-------------------]  30%\n" ~
//                 "  80/200 [===========>----------------]  40%\n" ~
//                 " 100/200 [==============>-------------]  50%\n" ~
//                 " 120/200 [================>-----------]  60%\n" ~
//                 " 140/200 [===================>--------]  70%\n" ~
//                 " 160/200 [======================>-----]  80%\n" ~
//                 " 180/200 [=========================>--]  90%\n" ~
//                 " 200/200 [============================] 100%",
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream(false, Verbosity.NORMAL);
//         ProgressBar bar = new ProgressBar(output, 50);
//         bar.start();
//         bar.setProgress(25);
//         bar.clear();
//         bar.setProgress(50);
//         bar.finish();

//         assertEqual(
//                 "  0/50 [>---------------------------]   0%\n" ~
//                 " 25/50 [==============>-------------]  50%\n" ~
//                 " 50/50 [============================] 100%",
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream(false, Verbosity.NORMAL);
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.advance();

//         assertEqual(
//                 "    0 [>---------------------------]\n" ~
//                 "    1 [->--------------------------]",
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar1 = new ProgressBar(output, 2);
//         ProgressBar bar2 = new ProgressBar(output, 3);
//         bar2.setProgressCharacter("#");
//         ProgressBar bar3 = new ProgressBar(output);

//         bar1.start();
//         output.write("\n");
//         bar2.start();
//         output.write("\n");
//         bar3.start();

//         for (int i = 1; i <= 3; i++) {
//             // up two lines
//             output.write("\033[2A");
//             if (i <= 2) {
//                 bar1.advance();
//             }
//             output.write("\n");
//             bar2.advance();
//             output.write("\n");
//             bar3.advance();
//         }
//         output.write("\033[2A");
//         output.write("\n");
//         output.write("\n");
//         bar3.finish();

//         assertEqual(
//                 generateOutput(" 0/2 [>---------------------------]   0%") ~ "\n" ~
//                 generateOutput(" 0/3 [#---------------------------]   0%") ~ "\n" ~
//                 StringUtils.rtrim(generateOutput("    0 [>---------------------------]")) ~

//                 "\033[2A" ~
//                 generateOutput(" 1/2 [==============>-------------]  50%") ~ "\n" ~
//                 generateOutput(" 1/3 [=========#------------------]  33%") ~ "\n" ~
//                 StringUtils.rtrim(generateOutput("    1 [->--------------------------]")) ~

//                 "\033[2A" ~
//                 generateOutput(" 2/2 [============================] 100%") ~ "\n" ~
//                 generateOutput(" 2/3 [==================#---------]  66%") ~ "\n" ~
//                 StringUtils.rtrim(generateOutput("    2 [-->-------------------------]")) ~

//                 "\033[2A" ~
//                 "\n" ~
//                 generateOutput(" 3/3 [============================] 100%") ~ "\n" ~
//                 StringUtils.rtrim(generateOutput("    3 [--->------------------------]")) ~

//                 "\033[2A" ~
//                 "\n" ~
//                 "\n" ~
//                 StringUtils.rtrim(generateOutput("    3 [============================]")),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.start();
//         bar.advance();
//         bar.advance();
//         bar.advance();
//         bar.finish();

//         assertEqual(
//                 generateOutput("    0 [>---------------------------]") ~
//                 generateOutput("    1 [->--------------------------]") ~
//                 generateOutput("    2 [-->-------------------------]") ~
//                 generateOutput("    3 [--->------------------------]") ~
//                 generateOutput("    3 [============================]"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         ProgressBar.setPlaceholderFormatter("remaining_steps", new class PlaceholderFormatter
//         {
//             override
//             public string format(ProgressBar bar, Output output)
//             {
//                 import std.conv;
//                 return to!string(bar.getMaxSteps() - bar.getProgress());
//             }
//         });

//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 3);
//         bar.setFormat(" %remaining_steps% [%bar%]");

//         bar.start();
//         bar.advance();
//         bar.finish();

//         assertEqual(
//                 generateOutput(" 3 [>---------------------------]") ~
//                 generateOutput(" 2 [=========>------------------]") ~
//                 generateOutput(" 0 [============================]"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 3);
//         bar.setFormat("%bar%\nfoobar");

//         bar.start();
//         bar.advance();
//         bar.clear();
//         bar.finish();

//         assertEqual(
//                 generateOutput(">---------------------------\nfoobar") ~
//                 generateOutput("=========>------------------\nfoobar                      ") ~
//                 generateOutput("                            \n                            ") ~
//                 generateOutput("============================\nfoobar                      "),
//                 getOutputString(output)
//         );
//     }

   
//    unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output, 15);
//         ProgressBar.setPlaceholderFormatter("memory", new class PlaceholderFormatter
//         {
//             private int i = 0;

//             override
//             public string format(ProgressBar bar, Output output)
//             {
//                 long mem = 100000 * i++;
//                 string colors ="44;37";

//                 return "\033[" ~ colors  ~ "m " ~ AbstractHelper.formatMemory(mem) ~ " \033[0m";
//             }
//         });
//         bar.setFormat(r" \033[44;37m %title:-37s% \033[0m\n %current%/%max% %bar% %percent:3s%%\n \uD83C\uDFC1  %remaining:-10s% %memory:37s%");
//         string done = "\033[32m●\033[0m";
//         bar.setBarCharacter(done);
//         string empty = "\033[31m●\033[0m";
//         bar.setEmptyBarCharacter(empty);
//         string progress = "\033[32m➤ \033[0m";
//         bar.setProgressCharacter(progress);

//         bar.setMessage("Starting the demo... fingers crossed", "title");
//         bar.start();
//         bar.setMessage("Looks good to me...", "title");
//         bar.advance(4);
//         bar.setMessage("Thanks, bye", "title");
//         bar.finish();

//         assertEqual(
//                 generateOutput(
//                         " \033[44;37m Starting the demo... fingers crossed  \033[0m\n" ~
//                         "  0/15 " ~ progress ~ StringUtils.padRight("", 26, empty) ~ "   0%\n" ~
//                         r" \uD83C\uDFC1  1 sec                          \033[44;37m 0 B \033[0m"
//                 ) ~
//                 generateOutput(
//                         " \033[44;37m Looks good to me...                   \033[0m\n" ~
//                         "  4/15 " ~ StringUtils.padRight("", 7, done)  ~ progress ~ StringUtils.padRight("", 19, empty) ~ "  26%\n" ~
//                         r" \uD83C\uDFC1  1 sec                       \033[44;37m 97 KiB \033[0m"
//                 ) ~
//                 generateOutput(
//                         " \033[44;37m Thanks, bye                           \033[0m\n" ~
//                         " 15/15 " ~ StringUtils.padRight("", 28, done) ~ " 100%\n" ~
//                         r" \uD83C\uDFC1  1 sec                      \033[44;37m 195 KiB \033[0m"
//                 ),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.setFormat("normal");
//         bar.start();
//         assertEqual(
//                 generateOutput("    0 [>---------------------------]"),
//                 getOutputString(output)
//         );

//         output = getOutputStream();
//         bar = new ProgressBar(output, 10);
//         bar.setFormat("normal");
//         bar.start();
//         assertEqual(
//                 generateOutput("  0/10 [>---------------------------]   0%"),
//                 getOutputString(output)
//         );
//     }

   
//     unittest
//     {
//         StreamOutput output = getOutputStream();
//         ProgressBar bar = new ProgressBar(output);
//         bar.setFormat("normal");
//         bar.start();
//         assertNotEqual("", getOutputString(output));

//         output = getOutputStream();
//         bar = new ProgressBar(output);
//         bar.setFormat("verbose");
//         bar.start();
//         assertNotEqual("", getOutputString(output));

//         output = getOutputStream();
//         bar = new ProgressBar(output);
//         bar.setFormat("very_verbose");
//         bar.start();
//         assertNotEqual("", getOutputString(output));

//         output = getOutputStream();
//         bar = new ProgressBar(output);
//         bar.setFormat("debug");
//         bar.start();
//         assertNotEqual("", getOutputString(output));
//     }

//     private StreamOutput getOutputStream()
//     {
//         return new StreamOutput(new ByteArrayOutputStream());
//     }

//     private StreamOutput getOutputStream(bool decorated, Verbosity verbosity)
//     {
//         return new StreamOutput(new ByteArrayOutputStream(), verbosity, decorated);
//     }
    
//     private string getOutputString(StreamOutput output)
//     {
//         return cast(string)((cast(ByteArrayOutputStream) output.getStream()).toByteArray());
//     }

//     private string generateOutput(string expected)
//     {
//         int count = StringUtils.count(expected, '\n');

//         return "\r" ~ (count > 0 ? format("\033[%dA", count) : "") ~ expected;
//     }

