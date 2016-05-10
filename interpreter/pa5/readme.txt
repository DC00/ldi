|*---------DESIGN DECISIONS---------*|

Handling new, dispatch, let

I'm going to go over the tough edge cases that gave us a lot of trouble.
Most of the code is a python interpretation of each statement in the
Operational Rules in the Cool Reference Manual.

New:

The special edge cases that we needed to deal with were something like 
new String, Int, or Bool. This would create an error since in new, you
would create a CoolObject with the type tag given to you in the new
expression body. This would create a CoolObject with a type tag of Int,
Bool, or String which is wrong since we had CoolInts, CoolStrings, and Cool
Bools with value fields to handle all the inits. So we made an if guard to 
check for these cases so we can return the correct default values using our
default value function. 

Dispatch:

Something that gave us trouble in dispatch was shadowing. We needed to 
figure out which took precedent in the environment: the attributes or
the formals. The formals should shadow the attributes. To deal with this,
when we created the new environment (the environment we use to evaluate
the dispatch body), we put the attributes in first. Therefore, in python
when two identifiers had the same value, the formal identifier would
overwrite the binding in this environment. Another case was deep copies vs
shallow copies for environments. The environment should never get passed
through any of the code. There were some issues with aliasing where the 
new environment was somehow interfering with the overarching environment.
This was because we were making shallow copies. In Python, if the
references are pointing to the same areas, bindings get messed up 
regardless on what you call the environment. To fix this, we imported
copy and used the deepcopy function to fix most of our problems.

Let:
	
Let was straightforward. The only thing that was particularly challenging
was handling multiple let bindings. For input purposes, we serialized let
in a special way. A let statement was a tuple containing the location, 
binding list, and let body expression. To handle this, we did it using two
cases. If it was a single let binding, then it would use the let body for
evaluation to return the right value and store. If the binding list had 
more than 1 binding, then we would create a new let expression without that
binding for the evaulation. This is a recursive solution to go through
the binding list and once it hits the last case, use the let body for eval
for returning the final value and store.


|*---------TEST CASES---------*|

default_values.cl -

When initializing values in new, D_t in the CRM means a default value based
on T, the type tag. Cool lists specific values for each type such as Int,
Bool, String, and a Cool Object. default_values.cl prints all of these 
values to make sure they were intialized correctly (in an initializer in 
an attr or in a let body) for any type.

stackoverflowedge.cl - 

For a stack overflow to happen, there has to be >1000 activation records.
In Cool, there is specific documentation to figure out when to add to a
counter for activation records (in new and dispatch). This testcase is
supposed to work (generate zero errors). This goes to the very edge of 
activation records. This tests if incrementing/decrementing activation 
records is accurate (if off by one, our interpreter would fail), if we
are adding activation records in the right places, and if we get the right 
number of activation records that still count as valid.

hairycase.cl -

hairy_case.cl is based on initializing a case within a class. This pretty 
much tests if the case algorithm in finding the lowest common ancestor for 
the type is implemented correctly. If the algorithm was not working, then 
this would be similiar to infinite recursion or it would not match any 
branch. Case was a tough expression to implement since it involved the 
lowest common ancestor algorithm so we felt it was appropriate to test 
this specifically.

harder_hello_world.cl -

harder_hello_world.cl tests if we are making sure an internal was returning
the right type (it's like something you could do but would never do in 
practice). Also this tests if the evaluation order was correct. Sometimes
if internals were implemented incorrectly, the strings would be printed
backwards.
