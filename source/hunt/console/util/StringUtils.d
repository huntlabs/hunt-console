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
 
module hunt.console.util.StringUtils;

import std.string;
import std.conv;
import hunt.text.Common;
import hunt.util.StringBuilder;

alias Character = char;
class StringUtils
{
    public static string repeat(T)(string s, T n) 
        if(is(T == int) || is(T == ulong) || is(T == uint) || is(T == long))
    {
        if (s is null) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            sb.append(s);
        }
        return sb.toString();
    }

    public static string stripTags(string s)
    {
        return s.replace("\\<.*?\\>", "");
    }

    public static int count(string word, Character ch)
    {
        int pos = cast(int)(word.indexOf(ch));

        return pos == -1 ? 0 : 1 + count(word.substring(pos+1),ch);
    }

    public static string join(string[] parts, string glue)
    {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.length; i++) {
            sb.append(parts[i]);
            if (i != parts.length - 1) {
                sb.append(glue);
            }
        }

        return sb.toString();
    }

    public static string ltrim(string s)
    {
        return ltrim(s, ' ');
    }

    public static string ltrim(string s, char c)
    {
        int i = 0;
        while (i < s.length && s[i] == c) {
            i++;
        }
        return s.substring(i);
    }

    public static string rtrim(string s)
    {
        return rtrim(s, ' ');
    }

    public static string rtrim(string s, char c)
    {
        int i = cast(int)(s.length-1);
        while (i >= 0 && s[i] == c) {
            i--;
        }
        return s.substring(0,i+1);
    }

    public static string padRight(string string, int length, char padChar)
    {
        return padRight(string, length, (padChar));
    }

    public static string padRight(string str, int length, string padString)
    {
        if (length < 1) {
            return str;
        }
        return format("%-" ~ length.to!string ~ "s", str).replace(" ", padString);
    }

    public static string padLeft(string string, int length, char padChar)
    {
        return padLeft(string, length, (padChar));
    }

    public static string padLeft(string str, int length, string padString)
    {
        if (length < 1) {
            return str;
        }
        return format("%" ~ length.to!string ~ "s", str).replace(" ", padString);
    }

    /**
     * Differs from String.split() in that it behaves like PHP's explode():
     * If s is the same string as c, the method returns an array with two elements both containing ""
     */
    public static string[] split(string s, char c)
    {
        if (to!string(c) == s) {
            return ["",""];
        }

        return s.split(to!string(c));
    }

    /**
     * This string util method removes single or double quotes
     * from a string if its quoted.
     * for input string = "mystr1" output will be = mystr1
     * for input string = 'mystr2' output will be = mystr2
     *
     * @param s value to be unquoted.
     * @return value unquoted, null if input is null.
     *
     */
    public static string unquote(string s)
    {
        if (s !is null
                && ((s.startsWith("\"") && s.endsWith("\""))
                || (s.startsWith("'") && s.endsWith("'")))) {

            s = s.substring(1, s.length - 1);
        }

        return s;
    }
}
