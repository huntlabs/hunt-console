module hunt.console.input.StringInput;

import hunt.console.error.InvalidArgumentException;
import hunt.console.util.StringUtils;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.console.input.ArgvInput;
import hunt.text.Common;
import std.string;
import std.regex;

class StringInput : ArgvInput
{
    private static string REGEX_STRING = "([^\\s]+?)(?:\\s|(?<!\\\\\\\\)\"|(?<!\\\\\\\\)\\'|$)";

    private static string REGEX_QUOTED_STRING = "(?:\"([^\"\\\\\\\\]*(?:\\\\\\\\.[^\"\\\\\\\\]*)*)\"|\\'([^\\'\\\\\\\\]*(?:\\\\\\\\.[^\\'\\\\\\\\]*)*)\\')";

    public this(string input)
    {
        super(null);

        setTokens(tokenize(input));
    }

    private List!(string) tokenize(string input)
    {
        List!(string) tokens = new ArrayList!(string)();
        int length = cast(int)(input.length);
        string inputPart;
        string token;
        int matchLength;
        int cursor = 0;

        string whiteSpace = /* Pattern.compile */("^\\s+");
        // Matcher whiteSpaceMatcher;
        string quotedOption = /* Pattern.compile */("^([^=\"\\'\\s]+?)(=?)(" ~ REGEX_QUOTED_STRING ~ "+)");
        // Matcher quotedOptionMatcher;
        string quotedstring = /* Pattern.compile */("^" ~ REGEX_QUOTED_STRING);
        // Matcher quotedStringMatcher;
        string str = /* Pattern.compile */("^" ~ REGEX_STRING);
        // Matcher stringMatcher;

        while (cursor < length) {

            inputPart = input.substring(cursor);

            auto whiteSpaceMatcher =matchAll(inputPart, whiteSpace);
            auto quotedOptionMatcher = matchAll(inputPart,quotedOption);
            auto quotedStringMatcher = matchAll(inputPart,quotedstring);
            auto stringMatcher = matchAll(inputPart,str);

            if (!whiteSpaceMatcher.empty()) {
                matchLength = cast(int)(whiteSpaceMatcher.front().captures[0].length);
            } else if (!quotedOptionMatcher.empty()) {
                token = quotedOptionMatcher.front().captures[1] ~ quotedOptionMatcher.front().captures[2] ~ StringUtils.unquote(quotedOptionMatcher.front().captures[3].substring(1, quotedOptionMatcher.front().captures[3].length - 1).replace("(\"')|('\")|('')|(\"\")", ""));
                tokens.add(token);
                matchLength = cast(int)(quotedOptionMatcher.front().captures[0].length);
            } else if (!quotedStringMatcher.empty()) {
                token = quotedStringMatcher.front().captures[0];
                tokens.add(StringUtils.unquote(token.substring(1, token.length - 1)));
                matchLength = cast(int)(token.length);
            } else if (!stringMatcher.empty()) {
                token = stringMatcher.front().captures[1];
                tokens.add(StringUtils.unquote(token));
                matchLength = cast(int)(stringMatcher.front().captures[0].length);
            } else {
                // should never happen
                throw new InvalidArgumentException(format("Unable to parse input near '... %s ...", input.substring(cursor, cursor + 10)));
            }

            cursor += matchLength;
        }

        return tokens;
    }
}
