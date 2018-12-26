module hunt.console.input.StringInput;

import hunt.console.error.InvalidArgumentException;
import hunt.console.util.StringUtils;

import hunt.container.ArrayList;
import hunt.container.List;

import std.regex;

class StringInput : ArgvInput
{
    private static string REGEX_STRING = "([^\\s]+?)(?:\\s|(?<!\\\\\\\\)\"|(?<!\\\\\\\\)\\'|$)";

    private static string REGEX_QUOTED_STRING = "(?:\"([^\"\\\\\\\\]*(?:\\\\\\\\.[^\"\\\\\\\\]*)*)\"|\\'([^\\'\\\\\\\\]*(?:\\\\\\\\.[^\\'\\\\\\\\]*)*)\\')";

    public stringInput(string input)
    {
        super(null);

        setTokens(tokenize(input));
    }

    private List!(string) tokenize(string input)
    {
        List!(string) tokens = new ArrayList<>();
        int length = input.length();
        string inputPart;
        string token;
        int matchLength;
        int cursor = 0;

        Pattern whiteSpace = Pattern.compile("^\\s+");
        Matcher whiteSpaceMatcher;
        Pattern quotedOption = Pattern.compile("^([^=\"\\'\\s]+?)(=?)(" ~ REGEX_QUOTED_STRING ~ "+)");
        Matcher quotedOptionMatcher;
        Pattern quotedstring = Pattern.compile("^" ~ REGEX_QUOTED_STRING);
        Matcher quotedStringMatcher;
        Pattern string = Pattern.compile("^" ~ REGEX_STRING);
        Matcher stringMatcher;

        while (cursor < length) {

            inputPart = input.substring(cursor);

            whiteSpaceMatcher = whiteSpace.matcher(inputPart);
            quotedOptionMatcher = quotedOption.matcher(inputPart);
            quotedStringMatcher = quotedString.matcher(inputPart);
            stringMatcher = string.matcher(inputPart);

            if (whiteSpaceMatcher.find()) {
                matchLength = whiteSpaceMatcher.end() - whiteSpaceMatcher.start();
            } else if (quotedOptionMatcher.find()) {
                token = quotedOptionMatcher.group(1) + quotedOptionMatcher.group(2) + StringUtils.unquote(quotedOptionMatcher.group(3).substring(1, quotedOptionMatcher.group(3).length() - 1).replaceAll("(\"')|('\")|('')|(\"\")", ""));
                tokens.add(token);
                matchLength = quotedOptionMatcher.group(0).length();
            } else if (quotedStringMatcher.find()) {
                token = quotedStringMatcher.group();
                tokens.add(stringUtils.unquote(token.substring(1, token.length() - 1)));
                matchLength = token.length();
            } else if (stringMatcher.find()) {
                token = stringMatcher.group(1);
                tokens.add(stringUtils.unquote(token));
                matchLength = stringMatcher.group(0).length();
            } else {
                // should never happen
                throw new InvalidArgumentException(string.format("Unable to parse input near '... %s ...", input.substring(cursor, cursor + 10)));
            }

            cursor += matchLength;
        }

        return tokens;
    }
}
