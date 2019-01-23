module test.formatter.OutputFormatterTest;

import hunt.console.formatter;
import hunt.console.util.StringUtils;
import test.asserts;

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);
    assertEqual("foo<>bar", formatter.format("foo<>bar"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("foo<bar", formatter.format(`foo\\<bar`));
    assertEqual("<info>some info</info>", formatter.format(`\\<info>some info\\</info>`));
    assertEqual(r"\\<info>some info\\</info>",
            DefaultOutputFormatter.escape("<info>some info</info>"));
    assertEqual("\033[33mAstina Console does work very well!\033[39m",
            formatter.format("<comment>Astina Console does work very well!</comment>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertTrue(formatter.hasStyle("error"));
    assertTrue(formatter.hasStyle("info"));
    assertTrue(formatter.hasStyle("comment"));
    assertTrue(formatter.hasStyle("question"));

    assertEqual("\033[37;41msome error\033[39;49m", formatter.format("<error>some error</error>"));
    assertEqual("\033[32msome info\033[39m", formatter.format("<info>some info</info>"));
    assertEqual("\033[33msome comment\033[39m", formatter.format("<comment>some comment</comment>"));
    assertEqual("\033[30;46msome question\033[39;49m",
            formatter.format("<question>some question</question>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("\033[37;41msome \033[39;49m\033[32msome info\033[39m\033[37;41m error\033[39;49m",
            formatter.format("<error>some <info>some info</info> error</error>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("\033[37;41msome error\033[39;49m\033[32msome info\033[39m",
            formatter.format("<error>some error</error><info>some info</info>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("(\033[32m>=2.0,<2.3\033[39m)", formatter.format("(<info>>=2.0,<2.3</info>)"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("(\033[32mz>=2.0,<a2.3\033[39m)",
            formatter.format("(<info>" ~ DefaultOutputFormatter.escape("z>=2.0,<a2.3") ~ "</info>)"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("\033[37;41merror\033[39;49m\033[32minfo\033[39m\033[33mcomment\033[39m\033[37;41merror\033[39;49m",
            formatter.format("<error>error<info>info<comment>comment</info>error</error>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    OutputFormatterStyle style = new DefaultOutputFormatterStyle("blue", "white");
    formatter.setStyle("test", style);

    assertEqual(style, formatter.getStyle("test"));
    assertNotEqual(style, formatter.getStyle("info"));

    style = new DefaultOutputFormatterStyle("blue", "white");
    formatter.setStyle("b", style);

    assertEqual("\033[34;47msome \033[39;49m\033[34;47mcustom\033[39;49m\033[34;47m msg\033[39;49m",
            formatter.format("<test>some <b>custom</b> msg</test>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    OutputFormatterStyle style = new DefaultOutputFormatterStyle("blue", "white");
    formatter.setStyle("info", style);

    assertEqual("\033[34;47msome custom msg\033[39;49m",
            formatter.format("<info>some custom msg</info>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    assertEqual("\033[34;41msome text\033[39;49m", formatter.format("<fg=blue;bg=red>some text</>"));
    assertEqual("\033[34;41msome text\033[39;49m",
            formatter.format("<fg=blue;bg=red>some text</fg=blue;bg=red>"));
    assertEqual("\033[34;41;1msome text\033[39;49;22m",
            formatter.format("<fg=blue;bg=red;bold=bold>some text</>"));
}

// unittest
// {
//     OutputFormatter formatter = new DefaultOutputFormatter(true);

//     assertEqual(
//             "\033[32msome \033[39m\033[32m<tag>\033[39m\033[32m \033[39m\033[32m<setting=value>\033[39m\033[32m styled \033[39m\033[32m<p>\033[39m\033[32msingle-char tag\033[39m\033[32m</p>\033[39m",
//             formatter.format("<info>some <tag> <setting=value> styled <p>single-char tag</p></info>")
//         );
// }

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    string longStr = StringUtils.repeat("\\", 14000);
    assertEqual("\033[37;41msome error\033[39;49m" ~ longStr,
            formatter.format("<error>some error</error>" ~ longStr));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(false);

    assertTrue(formatter.hasStyle("error"));
    assertTrue(formatter.hasStyle("info"));
    assertTrue(formatter.hasStyle("comment"));
    assertTrue(formatter.hasStyle("question"));

    assertEqual("some error", formatter.format("<error>some error</error>"));
    assertEqual("some info", formatter.format("<info>some info</info>"));
    assertEqual("some comment", formatter.format("<comment>some comment</comment>"));
    assertEqual("some question", formatter.format("<question>some question</question>"));

    formatter.setDecorated(true);

    assertEqual("\033[37;41msome error\033[39;49m", formatter.format("<error>some error</error>"));
    assertEqual("\033[32msome info\033[39m", formatter.format("<info>some info</info>"));
    assertEqual("\033[33msome comment\033[39m", formatter.format("<comment>some comment</comment>"));
    assertEqual("\033[30;46msome question\033[39;49m",
            formatter.format("<question>some question</question>"));
}

unittest
{
    OutputFormatter formatter = new DefaultOutputFormatter(true);

    string nl = "\r\n"/* System.getProperty("line.separator") */;

    assertEqual(nl ~ "\033[32m" ~ nl ~ "some text\033[39m" ~ nl,
            formatter.format(nl ~ "<info>" ~ nl ~ "some text</info>" ~ nl));

    assertEqual(nl ~ "\033[32msome text" ~ nl ~ "\033[39m" ~ nl,
            formatter.format(nl ~ "<info>some text" ~ nl ~ "</info>" ~ nl));

    assertEqual(nl ~ "\033[32m" ~ nl ~ "some text" ~ nl ~ "\033[39m" ~ nl,
            formatter.format(nl ~ "<info>" ~ nl ~ "some text" ~ nl ~ "</info>" ~ nl));

    assertEqual(nl ~ "\033[32m" ~ nl ~ "some text" ~ nl ~ "more text" ~ nl ~ "\033[39m" ~ nl,
            formatter.format(nl ~ "<info>" ~ nl ~ "some text" ~ nl ~ "more text" ~ nl
                ~ "</info>" ~ nl));
}
