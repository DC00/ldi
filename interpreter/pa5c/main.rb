# Raymond Zhao (rfz5nt)
# Daniel Coo (djc4ku)
# PA5C

# Read in .cl-type file
# Separate into class_map, imp_map, parent_map, and the annotated AST lists

cl_type_file = ARGV[0]

File.foreach( cl_type_file ) do |line|
	line.chomp!
	puts line
end

