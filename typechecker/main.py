# Raymond Zhao rfz5nt
# Daniel Coo djc4ku
# PA4 - Type Checker

import sys

# Get input from parse tree

ast_file = sys.argv[1]
ast_filehandler = open(ast_file, 'r')
ast_lines = ast_filehandler.readlines()
ast_filehandler.close()

# Keep track of classes in a list (alphabetically)
	# *There should always be 6 classes: Main, Object, IO, Int, String, Bool

class_list = ['Main','Object','IO','Int','String','Bool']

	# Find all classes (they are capitalized)

for line in ast_lines:
	if line.isupper() and line not in class_list:
		class_list.append(line)
	

# Keep track of attributes from the classes 


	
	# Are they initialized?

# Output the class_map

