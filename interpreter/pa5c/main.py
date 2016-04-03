# Raymond Zhao (rfz5nt)
# Daniel Coo (djc4ku)

# Read in .cl-type file
# Separate into class_map, imp_map, parent_map, and ast
import sys

class Type:
	def __init__(self, loc=None, exp_kind=None, exp=None):
		if exp_kind is not None:
			self.exp_kind = exp_kind
		else:
			self.exp_kind = "###"
		if loc is not None:
			self.loc = loc
		else:
			self.loc = "###"
		if exp is not None:
			self.exp = exp
		else:
			self.exp = "###"
	
	# def __str__(self):
	# 	if self.exp_kind == "integer":
	# 		return "Integer(%s)" % (str(self.exp))
	# 	else:
	# 		return "exp not handled in to string"

	def __repr__(self):
		if self.exp_kind == "plus":
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
		else:
			return "exp not handled in to string"

	def des(self):
		if self.exp_kind == "true" or self.exp_kind == "false":
			print "%s\n%s" % (self.loc, self.exp)
		else:
			print "%s\n%s\n%s" % (self.loc, self.exp_kind, self.exp)

	

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

def print_map(hmap):
	for k in hmap:
		for v in hmap[k]:
			print "%s => %s" % (k, v)
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

# Serialize the class_map
class_map = {}

def read_exp(e):
	# Know that we need to read an exp
	# return a tuple (loc, exp_kind, exp subparts)
	# recurse on the subparts
	loc = e.pop(0)
	exp_kind = e.pop(0)
	
	if exp_kind in ["plus", "minus", "times", "divide", "lt", "le", "eq"]:
		first_exp = read_exp(e)
		second_exp = read_exp(e)
		t = Type(loc, exp_kind, [first_exp, second_exp])
		return t
	elif exp_kind == "not":
		t = Type(loc, exp_kind, read_exp(e))
		return t
	elif exp_kind == "integer":
		int_constant = e.pop(0)
		t = Type(loc, exp_kind, int_constant)
		return t
	elif exp_kind == "string":
		str_constant = e.pop(0)	
		t = Type(loc, exp_kind, str_constant)
		return t
	elif exp_kind == "true":
		t = Type(loc, exp_kind, "true")
		return t
	elif exp_kind == "false":
		t = Type(loc, exp_kind, "false")
		return t
	elif exp_kind == "identifier":
		idloc = e.pop(0)
		idname = e.pop(0)
		t = Type(idloc, exp_kind, idname)
		return t
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


def deserialize_cmap():
 	global class_map
 	keys = class_map.keys()
 	keys.sort()
 	print "class_map"
 	print len(keys)
 	
 	# Print name and number of attrs in each class
 	for k in keys:
 		num_attrs = len(class_map[k])
 		print k
 		print num_attrs
 		if num_attrs > 0:
 			for attr in class_map[k]:
				attr_name = attr[0]
				attr_type = attr[1]
 				init_list = attr[2]
				if len(init_list) > 0:
					print "initializer"
					print attr_name
					print attr_type
					for initialized_element in init_list:
						initialized_element.des()
				else:
					print "no_initializer"
					print attr_name
					print attr_type
			

read_cmap(io_cmap[1:])
print_map(class_map)
# deserialize_cmap()


	







