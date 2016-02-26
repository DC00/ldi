We approached this assignment in a less-mercenary way. We watched relevant Udacity videos and spent
more time watching the tutorial video. We reviewed the Cool Reference Manual. We went to office hours
to practice writing the grammars for each syntax rule, and most importantly, we started early!
We implemented the assignment in Python, and we decided to first handle the program, class, feature, 
formal, static dispatch, dynamic dispatch, and self dispatch syntax rules. With these base rules, 
our parser could at least run most of the example cool programs. Next we implemented the easy rules, 
those that correspond to the terminals in an AST. These simple rules were easy to code, and they 
prepared us for some of the trickier methods with lists. The feature list example Professor Weimer 
coded in the tutorial video was invaluable, and it helped us understand how to handle [[a]]+ and [[b]]*.

We handled 'let' by writing a grammar out on paper and then writing several test cases. Here is the
grammar we eventually implemented:

	# let ID: TYPE [<- expr] [[, ID : TYPE [<- expr]]]* in exp
	exp 		: LET binding bindinglist IN exp
	bindinglist	: COMMA binding bindinglist
	binding		: identifier COLON type
				| identifier COLON type LARROW exp

We handled self, static, and dynamic dispatch in similar ways to how Professor Weimer handled
feature lists in the tutorial video.

Testcases

Our good.cl testcase has a let expression that defines a new integer through a case expression.
This tests both the complex let syntax rule and the case statements.

The bad.cl testcase has an empty main method with nested braces. This tests to see if the 
feature list is implemented correctly.

