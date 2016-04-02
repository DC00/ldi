# Raymond Zhao (rfz5nt)
# Daniel Coo (djc4ku)
# PA5C

# Read in .cl-type file
# Separate into class_map, imp_map, parent_map, and the annotated AST lists

cl_type_file = ARGV[0]

# Read in .cl-type file
type_file = []
File.foreach( cl_type_file ) do |line|
	line.chomp!
	type_file << line
end

# Iterates over file once, breaks on each map_label
io_class_map = []
io_imp_map = []
io_parent_and_ast = []
io_p_map = []
io_ast = []

in_class_map = true
in_imp_map = false
in_pmap = false

type_file.each do |line|
	if line == "implementation_map"
		in_imp_map = true
		in_class_map = false
	elsif line == "parent_map"
		in_imp_map = false
		in_pmap = true
	end

	if in_class_map
		io_class_map << line
	elsif in_imp_map
		io_imp_map << line
	elsif in_pmap
		io_parent_and_ast << line
	end
end

# Separate ast from parent map
# 2nd lineno will always be the start of the ast
# Ruby doesn't have a good string to int conversion method
class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

lineno_count = 0
pos_to_split = 0
io_parent_and_ast.each.with_index do |line, inx|
	if line.is_i?
		lineno_count = lineno_count + 1
	end
	if lineno_count > 1
		pos_to_split = inx
		break
	end
end

io_p_map = io_parent_and_ast.slice(0..pos_to_split-1)
io_ast = io_parent_and_ast.slice(pos_to_split, io_parent_and_ast.length)


# Fuck this
def read_exp(list)
	# massive method
	# keep track of how many lines are read
	# scope will change from caller
	# drop the lines that were read in this method in the caller method
end


# Class Map
# Serialize class_map. Parameter: class map w/o "class_name" label
def read_cmap(cmap_list)
	num_classes = cmap_list.shift
	cmap = {}
	num_classes.to_i.times do
		cname = cmap_list.shift
		attrs = []
		num_attrs = cmap_list.shift
		num_attrs.to_i.times do
			initialize = cmap_list.shift
			case initialize
				when "initializer"
					attr_name = cmap_list.shift
					attr_type = cmap_list.shift
					attr_exp = read_exp(cmap_list)					
				when "no_initializer"
					puts "in no init"
				else
					puts "should not be here"
			end


			attr_name = cmap_list.shift
			attr_type = cmap_list.shift
			attrs << [initialize, attr_name, attr_type]
		end
		cmap[cname] = attrs
	end
	cmap
end

class_map = read_cmap(io_class_map.slice(1..io_class_map.length))

class_map.each do |k,v|
	puts "#{k}: #{v}"
end





