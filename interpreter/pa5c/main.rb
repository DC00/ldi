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

# Break into separate maps
class_map = []
imp_map = []
parent_map = []
ast = []

type_file.each do |line|
	if line == "implementation_map"
		break
	end
	class_map << line
end

type_file = type_file - class_map

type_file.each do |line|
	if line == "parent_map"
		break
	end
	imp_map << line
end

type_file
# 2.times { parent_map << type_file.shift }

class_map.each do |l|
	puts l
end

puts
puts

imp_map.each do |l|
	puts l
end





