# Daniel Coo (djc4ku)
# Raymond Zhao (rfz5nt)
# Parser for PA3 for Cool

# Read in the CL-LEX file
# Deserialize file into tokens
# feed tokens into PLY Lexer format
# define our AST Representation
# Define our PA3 Parser as Grammar Rules
# Serialize AST

import sys
from lex import LexToken
# PLY parser
import yacc as yacc


# Read in cool lex file
tokens_file = sys.argv[1]
tokens_filehandler = open(tokens_file, 'r')
tokens_lines = tokens_filehandler.readlines()
tokens_filehandler.close()

# Input:
# 1
# class
# 1
# type
# Main
# 1
# lbrace
# 2

# Want:
# (1, class)
# (1, type, Main)
# (1, lbrace)

# strip each line and return first line
# removes first line upon return
def get_token_line():
		global tokens_lines
		result = tokens_lines[0].strip()
		tokens_lines = tokens_lines[1:]
		return result



# list of tuples
# (1, class, Class), (1, type, Main), ...
pa2_tokens = []

# Deserialize file into tokens
while tokens_lines != []:
		line_number = get_token_line()
		token_type = get_token_line()
		token_lexeme = token_type
		# Update this list
		if token_type in ['identifier', 'integer', 'type', 'string']:
				token_lexeme = get_token_line()
		pa2_tokens = pa2_tokens + \
						[(line_number, token_type.upper(), token_lexeme)]
	
# print pa2_tokens


# Use PA2 Tokens as Lexer
class PA2Lexer(object):
		def token(something):
				global pa2_tokens
				if pa2_tokens == []:
						return None
				(line, token_type, lexeme) = pa2_tokens[0]
				# Remove from list
				pa2_tokens = pa2_tokens[1:]
				tok = LexToken()
				tok.type = token_type # from PA2
				tok.value = lexeme # from PA2
				tok.lineno = line # from PA2
				tok.lexpos = 0 # don't need this
				return tok


pa2lexer = PA2Lexer()

# Define PA3 Parser
# All tokens are capitalized
tokens = (
	'AT', 'CASE', 'CLASS', 'COLON', 'COMMA', 
	'DIVIDE', 'DOT', 'ELSE', 'EQUALS', 'ESAC',
	'FALSE', 'FI', 'IDENTIFIER', 'IF', 'IN',
	'INHERITS', 'INTEGER', 'ISVOID', 'LARROW', 'LBRACE', 
	'LE', 'LET', 'LOOP', 'LPAREN', 'LT', 'MINUS', 
	'NEW', 'NOT', 'OF', 'PLUS', 'POOL', 'RARROW',
	'RBRACE', 'RPAREN', 'SEMI', 'STRING', 'THEN',
	'TILDE', 'TIMES', 'TRUE', 'TYPE', 'WHILE',
)

# Decide which binds more tightly
# TODO: add in precedence for lt, gt, eq, etc.
#		there exits 42 shift/reduce conflicts

precedence = (
	('right', 'LARROW'),	
	('left', 'NOT'),
	('nonassoc','LT','LE','EQUALS'),
	('left', 'PLUS', 'MINUS'),
	('left', 'TIMES', 'DIVIDE'),
	('left', 'ISVOID'),
	('left', 'TILDE'),
	('left', 'AT'),
	('left', 'DOT')
)


# Our AST is nested tuples
#
#		(line_number, AST_node_type, AST_node_child1, AST_node_child2...)

# Example:
#
# exp :: exp PLUS exp
#		| exp MINUS exp
#		| INTEGER

# 2+5
#
# (lineno, 'plus',
#		(lineno, 'integer', 2),
#		(lineno, 'integer', 5)
# )

# See cool reference manual. A program is
# a list of classes, each ending with a semi colon
#
# A program is a classlist, and a classlist is either
# empty, or it's a class, semicolon, followed by another class
#
# program :: classlist
# 
# classlist :: /* empty */
#			| class ; classlist


# program ::= [[class;]]+

def p_program_classlist(p):
	'program : classlist'
	p[0] = p[1]

def p_classlist(p):
	'''classlist : class SEMI classlist
				 | class SEMI'''
	if len(p) == 4:
		p[0] = [p[1]] + p[3]
	elif len(p) == 3:
		p[0] = [p[1]] 

# class ::= class TYPE [inherits TYPE] { [[feature;]]* }

def p_class(p):
	'''class : CLASS type LBRACE featurelist RBRACE
			 | CLASS type INHERITS type LBRACE featurelist RBRACE''' 
	if len(p) == 6:
		p[0] = (p.lineno(1), 'class_noinherit', p[2], p[4])
	elif len(p) == 8:
		p[0] = (p.lineno(1), 'class_inherit', p[2], p[4], p[6])

def p_type(p):
	'type : TYPE'
	p[0] = (p.lineno(1), p[1])

def p_identifier(p):
	'identifier : IDENTIFIER'
	p[0] = (p.lineno(1), p[1])

def p_featurelist(p):
	'''featurelist : feature SEMI featurelist
				   | '''
	if len(p) == 4:
		p[0] = [p[1]] + p[3]
	elif len(p) == 1:
		p[0] = []

# feature ::= ID( [formal [[,formal]]* ]) : TYPE { expr }

def p_feature_method(p):
	'''feature : identifier LPAREN RPAREN COLON type LBRACE exp RBRACE
			   | identifier LPAREN formal formallist RPAREN COLON type LBRACE exp RBRACE '''
	if len(p) == 9:
		p[0] = (p.lineno(1), p[1], 'method', p[5], p[7])
	elif len(p) == 11:
		p[0] = (p.lineno(1), p[1], 'method', p[3], p[4], p[7], p[9])

def p_formallist(p):
	'''formallist : COMMA formal formallist
				| '''
	if len(p) == 4:
		p[0] = [p[2]] + p[3]
	elif len(p) == 1:
		p[0] = []

#			| ID : TYPE[ <- expr ]

def p_feature(p):
	'''feature : identifier COLON type LARROW exp
			   | identifier COLON type'''
	if len(p) == 6:
		p[0] = (p.lineno(1), 'attribute_init', p[1], p[3], p[5])
	elif len(p) == 4:
		p[0] = (p.lineno(1), 'attribute_no_init', p[1], p[3])
	

#		| ID : TYPE [ <- expr ]

# formal ::= ID : TYPE

def p_formal(p):
	'formal : identifier COLON type'	
	p[0] = (p[1], p[3])

# expr ::= ...

	# ID ( [expr [[,expr]]*] )
def p_exp_self_dispatch(p):
	'exp : identifier LPAREN idexpr RPAREN'
	p[0] = (p[1][0],'self_dispatch', p[1], p[3])

def p_idexpr(p):
	'''idexpr : exp idlist
			  | '''
	if len(p) == 3:
		p[0] = [p[1]] + p[2]	
	elif len(p) == 1:
		p[0] = []

def p_idlist(p):
	'''idlist : COMMA exp idlist
			  | '''
	if len(p) == 4:
		p[0] = [p[2]] + p[3]
	elif len(p) == 1:
		p[0] = []
	   
	
	# if expr then expr else expr fi
def p_expr_if(p):
	'exp : IF exp THEN exp ELSE exp FI'	
	p[0] = (p.lineno(1), 'if', p[2], p[4], p[6])

	# while expr loop expr pool
def p_expr_while(p):
	'exp : WHILE exp LOOP exp POOL'
	p[0] = (p.lineno(1), 'while', p[2], p[4])

	# { [[ expr; ]]+ }
	# TODO: double check print method

def p_exp_block(p):
	'exp : LBRACE explist RBRACE'
	p[0] = (p.lineno(1), 'block', p[2])

def p_explist(p):
	'''explist : exp SEMI explist
			   | exp SEMI'''
	if len(p) == 4:
		p[0] = [p[1]] + p[3]
	elif len(p) == 3:
		p[0] = [p[1]] 

	# new TYPE
def p_exp_new(p):
	'exp : NEW type' 
	p[0] = (p.lineno(1), 'new', p[2])

	# isvoid expr
def p_exp_isvoid(p):
	'exp : ISVOID exp'
	p[0] = (p.lineno(1), 'isvoid', p[2])

	# expr + expr
def p_exp_plus(p):
	'exp : exp PLUS exp'
	# p[0] = (p.lineno(1), 'plus', p[1], p[3])
	p[0] = ((p[1][0]), 'plus', p[1], p[3])

	# expr - expr
def p_exp_minus(p):
	'exp : exp MINUS exp'
	p[0] = ((p[1][0]), 'minus', p[1], p[3])

	# expr * expr
def p_exp_times(p):
	'exp : exp TIMES exp'
	p[0] = ((p[1][0]), 'times', p[1], p[3])

	# expr / expr
def p_exp_divide(p):
	'exp : exp DIVIDE exp'
	p[0] = ((p[1][0]), 'divide', p[1], p[3])
	
	# ~ expr
def p_exp_negate(p):
	'exp : TILDE exp'
	p[0] = (p.lineno(1), 'negate', p[2])

	# expr < expr
def p_exp_lt(p):
	'exp : exp LT exp'
	p[0] = ((p[1][0]), 'lt', p[1], p[3])

	# expr <= expr
def p_exp_le(p):
	'exp : exp LE exp'
	p[0] = ((p[1][0]), 'le', p[1], p[3])

	# expr = expr
def p_exp_eq(p):
	'exp : exp EQUALS exp'
	p[0] = ((p[1][0]), 'eq', p[1], p[3])

	# not expr
def p_exp_not(p):
	'exp : NOT exp'
	p[0] = (p.lineno(1), 'not', p[2])

	# ID
# in p_identifier

	# integer
def p_exp_integer(p):
	'exp : INTEGER'
	p[0] = (p.lineno(1), 'integer', p[1])

	# string
def p_exp_string(p):
	'exp : STRING'
	p[0] = (p.lineno(1), 'string', p[1])

	# true
def p_exp_true(p):
	'exp : TRUE'
	p[0] = (p.lineno(1), 'true', p[1])

	# false
def p_exp_false(p):
	'exp : FALSE'
	p[0] = (p.lineno(1), 'false', p[1])


def p_error(p):
	if p:
		print "ERROR: ",  p.lineno, ": Parser: parse error near ", p.type
		exit(1)
		# Just discard the token and tell the parser its's okay
	else:
		print "ERROR: Syntax error at EOF" # FIXME Track line number to output end of file stuff


# Build the PA3 parser from the above rules
# All methods defining a rule must come
# above the parser line
parser = yacc.yacc()
ast = yacc.parse(lexer=pa2lexer)

# print ast

# Output a PA3 CL-AST File
# input = foo.cl-lex -> output = foo.cl-ast
ast_filename = (sys.argv[1])[:-4] + "-ast"
fout = open(ast_filename, 'w')

# Define a number of print_foo() methods
# that call each other to serialize the AST

# Serialize AST

# Passing a function to a function
def print_list(ast, print_element_function): # higher-order function
	fout.write(str(len(ast)) + "\n")
	for elem in ast:
		print_element_function(elem)

def print_identifier(ast):
	# ast = (p.lineno(1), p[1])
	# ast[1] = identifier string
	fout.write( str(ast[0]) + "\n")
	fout.write(ast[1] + "\n")


def print_exp(ast):
	# ast = (p.lineno(1), 'plus', p[1], p[3])
	# ast = (p.lineno(1), 'minus', p[1], p[3])
	# ast = (p.lineno(1), 'integer', p[1])
	# ast = (p.lineno(1), 'negate', p[2])
	# ast = (p.lineno(1), 'block', p[2] exp-list)

	fout.write( str(ast[0]) + "\n" )
	if ast[1] in ['plus','minus','times','divide','lt','le','eq']:
		fout.write(ast[1] + "\n")
		print_exp(ast[2])
		print_exp(ast[3])
	elif ast[1] in ['negate','not','isvoid','new']:
		fout.write(ast[1] + "\n")	
		print_exp(ast[2])
	elif ast[1] in ['integer','string']:
		fout.write(ast[1] + "\n")
		fout.write(str(ast[2]) + "\n")
	elif ast[1] in ['true', 'false']:
		fout.write(ast[1] + "\n")
	elif ast[1] == 'block':
		fout.write(ast[1] + "\n")
		print_list(ast[2], print_exp)
	elif ast[1] == 'if':
		fout.write(ast[1] + "\n")
		print_exp(ast[2])
		print_exp(ast[3])
		print_exp(ast[4])
	elif ast[1] == 'while':
		fout.write(ast[1] + "\n")
		print_exp(ast[2])
		print_exp(ast[3])
	elif ast[1] == 'self_dispatch':
	#	ast = (p.lineno(1),'self_dispatch', p[1], p[3])
		fout.write(ast[1] + "\n")
		print_identifier(ast[2])
		print_list(ast[3],print_exp)
	else:
		print "unhandled expression"
		exit(1)


def print_feature(ast):
	# ast = (p.lineno(1), 'attribute_no_init', p[1], p[3])
	if ast[1] == 'attribute_no_init':
		fout.write("attribute_no_init\n")
		print_identifier(ast[2])
		print_identifier(ast[3])
	elif ast[1] == 'attribute_init':
		# ast = (p.lineno(1), 'attribute_init', p[1], p[3], p[5])
		fout.write("attribute_init\n")
		print_identifier(ast[2])
		print_identifier(ast[3])
		print_exp(ast[4])
	elif ast[2] == 'method' and len(ast) == 5:
		# without formal list
		fout.write('method' + '\n')
		print_identifier(ast[1])
		fout.write('0' + '\n')
		print_identifier(ast[3])
		print_exp(ast[4])
	elif ast[2] == 'method' and len(ast) == 7:
		# with formal list
		fout.write('method' + '\n')
		print_identifier(ast[2])
		ast[4] = [ast[3]] + ast[4]
		print_list(ast[4], print_formal)
		print_identifier(ast[5])
		print_exp(ast[6])

def print_formal(ast):
	# ast = (p[1] identifier, p[3] type)
	print_identifier(ast[0])
	print_identifier(ast[1])

def print_class(ast):
	# ast = (p.lineno(1), 'class_noinherit', p[2] name, p[4] feature list)
	# ast = (p.lineno(1), 'class_inherit', p[2] name, p[5] superclass_name, p[8] feature list)
	if ast[1] == 'class_noinherit':
		print_identifier(ast[2])
		fout.write("no_inherits\n")
		print_list(ast[3], print_feature)
	elif ast[1] == 'class_inherit':
		print_identifier(ast[2])
		fout.write("inherits\n")
		print_identifier(ast[3])
		print_list(ast[4], print_feature)

def print_program(ast):
	print_list(ast, print_class)

print_program(ast)
fout.close()

