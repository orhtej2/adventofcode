My first real roadblock.

I decided to create a parser that would, upon calling `parse(state)` produce `state` that advances the tokenizer to next token. Given 2 of such parsers run in parallel if one of the parsers parses an `array` while the other finds an `integer` the latter would get rewound to simulate entering one-element-array.

I created a lot of test cases for these, still had to retort to downloading one of solutions from [Reddit](https://www.reddit.com/r/adventofcode/comments/zkmyh4/2022_day_13_solutions/), fed it my input and spat out a list of `true`/`false` statements, threating these as additional input for my parser. Once I found all the edge cases and re-read the text pt 1 was over.

Pt 2 was a cake walk given Zig's built-in [`std.sort.sort(..)`](https://ziglang.org/documentation/0.10.0/std/#root;sort.sort) accepts equivalent of [C++'s `operator<`](https://en.cppreference.com/w/cpp/language/operators), and the parser telling if pairs are ordered or not **is already a valid operation of __less than__ operator**.