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
		if self.exp_kind == "new":
			return "New(%s)" % (str(self.exp))
		elif self.exp_kind == "isvoid":
			return "IsVoid(%s)" % (str(self.exp))
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

#TODO: do for every other expression that is a bitch
class Assign(Exp):
	def __init__(self, loc=None, var=None, exp=None):
		Exp.__init__(self,loc,"assign",exp)
		self.var = var
	def __repr__(self):
		return "Assign(%s,%s)" % (self.var,self.exp)

class Self_Dispatch(Exp):
	def __init__(self, loc=None, fname=None, exp=None):
		Exp.__init__(self,loc,"self_dispatch",exp) 
		self.fname = fname
	def __repr__(self):
		return "Self_Dispatch(%s,%s)" % (self.fname,self.exp)

class Dynamic_Dispatch(Exp):
	def __init__(self, loc=None, e=None, fname=None, exp=None):
		Exp.__init__(self,loc,"dynamic_dispatch",exp) 
		self.e = e
		self.fname = fname
	def __repr__(self):
		return "Dynamic_Dispatch(%s,%s,%s)" % (self.e,self.fname,self.exp)
		
class CoolValue:
	def __init__(self, value_type=None, value=None):
		self.value_type = value_type
		self.value = value

class CoolInt(CoolValue):
	def __init__(self, value=0):
		CoolValue.__init__(self,"Int", value)
	def __repr__(self):
		return "CoolInt(%s)" % (self.value)

class CoolString(CoolValue):
	def __init__(self, value="", length=0):
		CoolValue.__init__(self,"String",value)
		self.length = length
	def __repr__(self):
		return "CoolString(%s)" % (self.value)

class CoolBool(CoolValue):
	def __init__(self, value="false"):
		CoolValue.__init__(self,"Bool",value)
	def __repr__(self):
		return "CoolBool(%s)" % (self.value)

class CoolObject:
	def __init__(self, cname=None, attr_and_locs={}):
		self.cname = cname
		self.attr_and_locs = attr_and_locs
	def __repr__(self):
		return "CoolObject(%s,%s)" % (self.cname,self.attr_and_locs)
	
#TODO: Cool_Object and Void

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
global indent_count
indent_count = 0
def debug_indent():
	global indent_count
	if do_debug:
		for i in range(indent_count):
			print " ",

def debug(e):
	if do_debug:
		print "%s" % (e)

def print_map(hmap):
	for k in hmap:
		for v in hmap[k]:
			print "%s -> %s" % (k, v)
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
#TODO: Do we find this useful for any case? LUB?
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
	if exp_kind == "assign":
		var = read_id(e)
		t = Assign(loc,var.exp,read_exp(e))
		return t
	elif exp_kind == "new":
		id_ver = read_id(e) 
		t = Exp(id_ver.loc, exp_kind, id_ver.exp)
		return t
	elif exp_kind == "self_dispatch":
		funcid = read_id(e)
		fname = funcid.exp
		num_of_args = int(e.pop(0))
		t = Self_Dispatch(loc, fname, read_exp_list(read_exp(e),num_of_args))
		return t
	elif exp_kind == "dynamic_dispatch":
		e0 = read_exp(e)
		funcid = read_id(e)
		fname = funcid.exp
		num_of_args = int(e.pop(0))
		t = Dynamic_Dispatch(loc, e0, fname, read_exp_list(read_exp(e),num_of_args))
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
			attrs = []
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

print "IMP_MAP"
read_impmap(io_imap[1:])
print_map(imp_map)

new_location_counter = 1000

def newloc():
	global new_location_counter
	new_location_counter += 1	
	return new_location_counter

def default_value(typename):
	if typename == "Int":
		return 0
	elif typename == "String":
		return ""
	elif typename == "Bool":
		return False
	else:
		return "void" #FIXME: might need Void object

# Parameters:
# 	so		: self object
# 	store 	: store maps addresses to values
#	env		: environment maps variables to addresses
#	e		: the expression to evaluate
#
# Return Value:
#	(new_value, updated_store)



def eval(self_object,store,environment,exp):
	global indent_count
	indent_count += 2
	debug_indent() ; debug("eval: %s" % (exp))
	debug_indent() ; debug("so    = %s" % (self_object))
	debug_indent() ; debug("store = %s" % (store))
	debug_indent() ; debug("env   = %s" % (environment))
	debug_indent() ; debug("exp = %s" % (exp))
	debug_indent() ; debug("exp_kind   = %s" % (exp.exp_kind))
	if exp.exp_kind == "assign":
		# exp.exp returns a list. select first element exp.exp[0]
		(v1,s2) = eval(self_object,store,environment,exp.exp[0])	
		l1 = environment[exp.var]	
		del s2[l1] #FIXME: does this delete every instance?
		s3 = s2
		s3[l1] = v1
		debug_indent() ; debug("ret = %s" % (v1))
		debug_indent() ; debug("rets = %s" % (s3))
		indent_count -= 2
		return (v1,s3)
	elif exp.exp_kind == "new":
		# TODO: need to deal with SELF_TYPE
		cname = exp.exp
		attrs_and_inits = class_map[cname]
		new_attrs_locs = [newloc() for x in attrs_and_inits]
		attr_names = [attr_name for (attr_name,attr_type,attr_exp) in attrs_and_inits]
		attrs_and_locs = dict(zip(attr_names, new_attrs_locs))
		v1 = CoolObject(cname, attrs_and_locs)
		# iterate through key,value pairs (attrname to loc)
		s2 = store
		for (attr_name, attr_loc) in attrs_and_locs.iteritems():
		# find the attr_name in the class map

			for (attr_name2, attr_type, attr_exp) in attrs_and_inits:
		# get the type from it and return the default value, make the pairing
				if attr_name == attr_name2:
					s2[attr_loc] = default_value(attr_type)

		final_store = s2
		for (attr_name,_,attr_init) in attrs_and_inits:
			if attr_init != []:
				(_,current_store) = eval(v1,final_store,attrs_and_locs,Assign(0,attr_name,attr_init))
				final_store = current_store

			# FIXME: 0 in Assign constructor might make troubles

		debug_indent() ; debug("ret = %s" % (v1))
		debug_indent() ; debug("rets = %s" % (final_store))
		indent_count -= 2
		return (v1,final_store)
	elif exp.exp_kind == "self_dispatch":

		# call dynamic_dispatch, but use the self object for the receiver exp

		self_exp = Exp(0,"identifier","self")
		ret_exp = Dynamic_Dispatch(exp.loc,self_exp,exp.fname,exp.exp)
		(ret_value,ret_store) = eval(self_object,store,environment,ret_exp)
		debug_indent() ; debug("ret = %s" % (ret_value))
		debug_indent() ; debug("rets = %s" % (ret_store))
		indent_count -= 2
		return (ret_value,ret_store)

	elif exp.exp_kind == "dynamic_dispatch":
		current_store = store
		arg_values = []
		# evaluate each argument and update store
		for arg in exp.exp:
			(arg_value, new_store) = eval(self_object,current_store,environment,arg)
			current_store = new_store
			arg_values.append(arg_value)

	#ASIDE: dealing with out_string
		if exp.fname == "out_string":
			print arg_values[0].value.replace("\\n","\n"),

		# evaluate receiver object
		# TODO: what if they are not in there?

		(v0,s_nplus2) = eval(self_object,current_store,environment,exp.e)

		# look into imp_map

		(formals,body) = imp_map[(v0.cname,exp.fname)]

		# make new locations for each of the actual arguments

		new_arg_locs = [ newloc() for x in exp.exp]

		# make an updated store and add new locs to arg values
		# TODO: should put formal parameters first so that they are visible 
		# and they shadow the attributes

		s_nplus3 = s_nplus2
		store_update = dict(zip(new_arg_locs, arg_values))
		for (loc,value) in store_update.iteritems():
			s_nplus3[loc] = value
		(ret_value,ret_store) = eval(v0,s_nplus3,v0.attr_and_locs,body)
		debug_indent() ; debug("ret = %s" % (ret_value))
		debug_indent() ; debug("rets = %s" % (ret_store))
		indent_count -= 2
		return (ret_value,ret_store)

	elif exp.exp_kind == "isvoid":
		pass
	elif exp.exp_kind == "negate":
		pass
	elif exp.exp_kind == "plus": #need other operations

		# Get each integer from plus expression

		e1 = exp.exp[0]
		e2 = exp.exp[1]
		v1, s2 = eval(self_object,store,environment,e1)
		v2, s3 = eval(self_object,store,environment,e2)
		new_value = v1.value + v2.value
		debug_indent() ; debug("ret = %s" % (new_value))
		debug_indent() ; debug("rets = %s" % (store))
		indent_count -= 2
		return (CoolInt(new_value), store)
	elif exp.exp_kind == "not":
		pass
	elif exp.exp_kind == "integer":
		value = int(exp.exp)
		debug_indent() ; debug("ret = %s" % (value))
		debug_indent() ; debug("rets = %s" % (store))
		indent_count -= 2
		return (CoolInt(value), store)
	elif exp.exp_kind == "string":
		value = str(exp.exp)
		length = len(value)
		debug_indent() ; debug("ret = %s" % (value))
		debug_indent() ; debug("rets = %s" % (store))
		indent_count -= 2
		return (CoolString(value,length), store)
	elif exp.exp_kind == "true":
		pass
	elif exp.exp_kind == "false":
		pass
	elif exp.exp_kind == "identifier":
		iden = exp.exp
		if iden == "self":
			return (self_object,store)
		loc = environment[iden]
		value = store[loc]
		debug_indent() ; debug("ret = %s" % (value))
		debug_indent() ; debug("rets = %s" % (store))
		indent_count -= 2
		return (value,store)
	elif exp.exp_kind == "SELF_TYPE":
		return (self_object,store)
	else:
		print "Expression %s not handled" % (exp.exp_kind)

# ----------MAIN----------
	
# Environment, Store, and Values
# Environment is a list of tuples
# e.g. x lives at address 33 and y lives address 7
# [ ('x', 33), ('y', 7) ]
env = {}
# Store is a dictionary that maps addresses to their values
# e.g. 
store = {}
# Self Object
self_object = None
# self would be nothing at this point

my_exp = Dynamic_Dispatch(0, Exp(0,"new", "Main"), "main", [])

(new_value, new_store) = eval(self_object, store, env, my_exp)











