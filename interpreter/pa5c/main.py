# Raymond Zhao (rfz5nt)
# Daniel Coo (djc4ku)

# Read in .cl-type file
# Separate into class_map, imp_map, parent_map, and ast
import sys

class Exp:
	def __init__(self, loc=None, exp_kind=None, exp=None):
		self.loc = loc
		self.exp_kind = exp_kind
		self.exp = exp

	def __repr__(self):
		if self.exp_kind == "isvoid":
			return "IsVoid(%s)" % (str(self.exp))
		elif self.exp_kind == "self_dispatch":
			return "Self_Dispatch(%s)" % (str(self.exp))
		elif self.exp_kind == "lt":
			return "Lt(%s)" % (str(self.exp))
		elif self.exp_kind == "le":
			return "Le(%s)" % (str(self.exp))
		elif self.exp_kind == "negate":
			return "Negate(%s)" % (str(self.exp))
		elif self.exp_kind == "eq":
			return "Eq(%s)" % (str(self.exp))
		elif self.exp_kind == "times":
			return "Times(%s)" % (str(self.exp))
		elif self.exp_kind == "divide":
			return "Divide(%s)" % (str(self.exp))
		elif self.exp_kind == "minus":
			return "Minus(%s)" % (str(self.exp))
		elif self.exp_kind == "plus":
			return "Plus(%s)" % (str(self.exp))
		elif self.exp_kind == "not":
				return "Not(%s)" % (str(self.exp))
		elif self.exp_kind == "integer":
			return "Integer(%s)" % (str(self.exp))
		elif self.exp_kind == "string":
			return "String(%s)" % (str(self.exp))
		elif self.exp_kind == "true":
			return "Bool(%s)" % (str(self.exp))
		elif self.exp_kind == "false":
			return "Bool(%s)" % (str(self.exp))
		elif self.exp_kind == "identifier":
			return "ID(%s)" % (str(self.exp))
		elif self.exp_kind == "Object":
			return "Internal_Object(%s)" % (str(self.exp))
		elif self.exp_kind == "Int":
			return "Internal_Int(%s)" % (str(self.exp))
		elif self.exp_kind == "IO":
			return "Internal_IO(%s)" % (str(self.exp))
		elif self.exp_kind == "SELF_TYPE":
			return "Internal_SELF_TYPE(%s)" % (str(self.exp))
		elif self.exp_kind == "String":
			return "Internal_String(%s)" % (str(self.exp))
		else:
			return "exp not handled in to string"

# Helper functions
def print_list(a):
	for elt in a:
		print elt

def is_int(n):
	try:
		int(n)
		return True
	except ValueError:
		return False

# Debugging and Tracing
do_debug = True
global index_count
indent_count = 0
def debug_indent(e):
	global indent_count
	if do_debug:
		for i in range(indent_count):
			# That's a tab
			print "	",
		print e

def print_map(hmap):
	for k in hmap:
		for v in hmap[k]:
			print "%s => %s" % (k, v)
			debug_indent(v)
		print

fname = sys.argv[1]

# Read in .cl-type file
type_file = []
with open(fname, 'r') as fin:
	for line in fin:
		type_file.append(line.rstrip())

io_cmap = []
io_imap = []
io_pmap = []
io_ast  = []

in_cmap = True
in_imap = False
in_pmap = False

for line in type_file:
	if line == "implementation_map":
		in_cmap = False
		in_imap = True
	elif line == "parent_map":
		in_imap = False
		in_pmap = True
	
	if in_cmap:
		io_cmap.append(line)
	elif in_imap:
		io_imap.append(line)
	elif in_pmap:
		io_pmap.append(line)


# Separate ast from pmap
# Start of ast will always be the second integer
int_count = 0
split_pos = 0
for inx, line in enumerate(io_pmap):
	if is_int(line):
		int_count += 1  
	if int_count > 1:
		split_pos = inx
		break

io_ast = io_pmap[split_pos:]
io_pmap = io_pmap[0:split_pos]

# Deerialize the class_map
class_map = {}
imp_map = {}
# li : remaining part of class-map
# helper : function
def read_exp_list(func,num):
	ret_list = []
	for i in range(num):
		ret_list.append(func)
	return ret_list


def read_id(e):
	idloc = e.pop(0)
	idname = e.pop(0)
	t = Exp(idloc, "identifier", idname)
	return t

def read_internal_exp(e):
	loc = e.pop(0)  # loc is always 0
	exp_kind = e.pop(0)
	internal = e.pop(0)
	exp_body = e.pop(0)	# e.g. Object.abort  IO.in_int. See PA4 AST third bullet
	t = Exp(loc, exp_kind, exp_body)
	return t

def read_exp(e):
	# Know that we need to read an exp
	# return a tuple (loc, exp_kind, exp subparts)
	# recurse on the subparts

	# Test if annotated expression. Types are always capitalized
	if e[1][0].isupper():
		loc = e.pop(0)
		exp_type = e.pop(0)
		exp_kind = e.pop(0)
	else:	
		loc = e.pop(0)
		exp_kind = e.pop(0)

	# Read expressions based on exp_kind
	if exp_kind == "new":
		return read_id(e) 
	elif exp_kind == "self_dispatch":
	# WE MIGHT NEED THE METHOD IDENTIFIER
		read_id(e)
		num_of_args = int(e.pop(0))
		t = Exp(loc, exp_kind, read_exp_list(read_exp(e),num_of_args))
		return t
	elif exp_kind == "isvoid":
		t = Exp(loc, exp_kind, read_exp(e)) 
		return t
	elif exp_kind == "negate":
		t = Exp(loc, exp_kind, read_exp(e))
		return t
	elif exp_kind in ["plus", "minus", "times", "divide", "lt", "le", "eq"]:
		first_exp = read_exp(e)
		second_exp = read_exp(e)
		t = Exp(loc, exp_kind, [first_exp, second_exp])
		return t
	elif exp_kind == "not":
		t = Exp(loc, exp_kind, read_exp(e))
		return t
	elif exp_kind == "integer":
		int_constant = e.pop(0)
		t = Exp(loc, exp_kind, int_constant)
		return t
	elif exp_kind == "string":
		str_constant = e.pop(0) 
		t = Exp(loc, exp_kind, str_constant)
		return t
	elif exp_kind == "true":
		t = Exp(loc, exp_kind, "true")
		return t
	elif exp_kind == "false":
		t = Exp(loc, exp_kind, "false")
		return t
	elif exp_kind == "identifier":
		return read_id(e)		
	else:
		print "Expression %s not handled in read_exp(e)" % (exp_kind)
	

def read_cmap(cmap_list):
	num_classes = int(cmap_list.pop(0))
	while num_classes > 0:
		# 0 is just for testing. Remove later
		try:
			attrs = [0]
			cname = cmap_list.pop(0)
			num_attrs = int(cmap_list.pop(0))
			while num_attrs > 0:
				initialize = cmap_list.pop(0)
				attr_name = cmap_list.pop(0)
				attr_type = cmap_list.pop(0)
				attr_exp = []
				if initialize == "initializer":
					attr_exp.append(read_exp(cmap_list))
				attrs.append((attr_name, attr_type, attr_exp))  
				num_attrs -= 1
			num_classes -= 1
			class_map[cname] = attrs
		except ValueError:
			print "ValueError, messed up somewhere in read_cmap"

# key: (class name, method name) value: (formals list, method body)
def read_impmap(imap):
	num_classes = int(imap.pop(0))
	while num_classes > 0:
		try:
			class_name = imap.pop(0)
			num_of_methods = int(imap.pop(0))
			for i in range(num_of_methods):
				method_name = imap.pop(0)
				num_of_formals = int(imap.pop(0))
				formal_list = [imap.pop(0) for i in range(num_of_formals)]	
				parent_class = imap.pop(0)
				
				# Check if internal method
				# Contents of imap if internal
				# 0				imap[0]
				# Object		imap[1]
				# internal		imap[2]
				# Object.abort	imap[3]
				if imap[2] == "internal":
					body_exp = read_internal_exp(imap)
				else:
					body_exp = read_exp(imap)

				imp_map[(class_name,method_name)] = (formal_list,body_exp)
			num_classes -= 1
		except ValueError:
			print "ValueError, messed up while reading the lines from imp map"

read_cmap(io_cmap[1:])
print "CLASS_MAP"
print_map(class_map)

# print "IMP_MAP"
# read_impmap(io_imap[1:])
# print_map(imp_map)


# Environment, Store, and Values
# Environment is a list of tuples
# e.g. x lives at address 33 and y lives address 7
# [ ('x', 33), ('y', 7) ]
env = []

# Store is a dictionary that maps addresses to their values
# e.g. 
store = {}














