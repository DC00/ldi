We received an extension at 7:36pm on 3/22/2016

Handling of Class Hiearchy-------

For Class Hiearchy we used an inheritance hashtable. The Hashtable mapped child to parent. Ocaml's hashtable is a perfect implementation since it can actually change using Hashtable methods (add actually adds to the Hashtable without creating a separate instance)

We also had a recursive function that went through each parent to find the complete inheritance chain. For example, function(Main) in helloworld.cl would return a list with Object -> IO -> Main. For any class feature, we used primarily these two methods to find all the inherited attributes/methods to perform typechecking.

Case and Let and Oh My!--------

Case was challenging. Fold_left was our friend in this case. Since at the end of the type checking rules, we had to take the lub of every value (acting like a summation). Fold was great since it operated of the list of terms being sent in and returning a single type for the whole expression. Fold performed the function lub on the first term and used the accumulator to traverse the list returning the final accumulator aka the final type.

Let was basically the harder version of case. Let with multiple bindings had to be done recursively instead of using fold. We treated the binding list of a let expression collapsing on one another. We evaluated all the bindings from the end and then type-checked the let body expression.

Choice of Test Cases -------

Our good.cl testcase has uses a semi-complicated let expression. We
define four variables in one let expression, some of which are
initialized.

We choose test cases that specifically dealt with how you can't override
the base class methods. Our testcase bad1.cl has a class BadObject that overrides each one of the built in methods in IO. However, it would be a valid Cool program if BadObject did not inherit from IO.

'bad_override_built_in_types_Object.cl' redefines the built in Object classes and changes the number of formal parameters. This also tests whether or not the inheritance map is implemented correctly because every Cool class inherits from Object.

Our third testcase was created during pa4t. It fails with a Type-Check error when an inherited method doesn't conform in static dispatch in a child class.




