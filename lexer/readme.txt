4 — thorough discussion of design decisions (including handling of strings and comments) and choice of test cases; a few paragraphs of coherent English sentences should be fine
2 — vague or hard to understand; omits important details
0 — little to no effort


We decided to use Python because it was the language we were the most familiar with. After reading 
through the PLY documentation we knew we did not want to write rules for every possible token, so 
we made a dictionary of reserved words. This made matching identifiers easier. Next we worked on lexing
every program in the cool-examples.zip folder. This was relatively simple and gave us a false sense of
hope that we would finish the entire assignment!

At this point we were passing more positive cases than negative ones. A good number of them dealt with
comments, so we decided to attempt to implement one of the harder parts of the lexer. This is were my
partner and I are still pretty frustrated.

As we learned in class today, nested comments cannot be represented by a regular expression. A DFA has 
no way of knowing what state it used to be in. Since comments require multiple states, we tried
implementing the "stack of states" and "code block" examples from the PLY documentation. We successfully
lexed nested comments in a test file we made. Upon submission to the grading server, however, testcases
we had previously passed now failed, despite passing a few new ones. This was infuriating because we
were confident that the problem was very small, but a couple trips to office hours could not solve it.

We handled strings with a single regular expression. Our plan was to capture everything between two
quotes and then parse the captured string for illegal characters and other gotchas in the testcases.
Looking back we should have stopped trying to implement comments and worked more on strings. We were
planning on using states for strings as well.

After failing at comments we re-read the "Lexical Structure" section of the Cool Reference Manual.
From this we tried implementing checks for integers that were out of range, null characters in strings,
and strings that were too long. All three of these did not work and we did not know what we were doing
wrong.

Testcases: good.cl contains a testcase about whitespace with new lines. 'bad.cl' contains a testcase
with a string that is greater than 1024 characters.

In conclusion, the submission you are getting is the version that gets us the most points. Probably what
we're most disappointed with is that there are testcases which we passed that we will not get credit for.
In terms of code cleanliness, I have left our latest attempts at implementing comments commented out - 
uncommenting them will break everything, but it shows that we tried several methods.
