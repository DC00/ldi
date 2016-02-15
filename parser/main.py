# Daniel Coo (djc4ku)
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
		if token_type in ['identifier', 'integer', 'type']:
				token_lexeme = get_token_line()
		pa2_tokens = pa2_tokens + \
						[(line_number, token_type.upper(), token_lexeme)]
	
print pa2_tokens


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
	'AT',
	'CASE',
	'CLASS',
	'COLON',
	'COMMA',
	'DIVIDE',
	'DOT',
	'ELSE',
	'EQUALS',
	'ESAC',
	'FALSE',
	'FI',
	'IDENTIFIER',
	'IF',
	'IN',
	'INHERITS',
	'INTEGER',
	'ISVOID',
	'LARROW',
	'LBRACE',
	'LE',
	'LET',
	'LOOP',
	'LPAREN',
	'LT',
	'MINUS',
	'NEW',
	'NOT',
	'OF',
	'PLUS',
	'POOL',
	'RARROW',
	'RBRACE',
	'RPAREN',
	'SEMI',
	'STRING',
	'THEN',
	'TILDE',
	'TIMES',
	'TRUE',
	'TYPE',
	'WHILE',
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


# TODO: fix [[class]]+ the plus
def p_program_classlist(p):
	'program : classlist'
	p[0] = p[1]

def p_classlist_none(p):
	'classlist : '
	p[0] = []

def p_classlist_some(p):
	'classlist : class SEMI classlist'
	p[0] = [p[1]] + p[3]

# class ::= class TYPE [inherits TYPE] { [[feature;]]* }
def p_class_noinherit(p):
	'class : CLASS type LBRACE featurelist RBRACE'
	p[0] = (p.lineno(1), 'class_noinherit', p[2], p[4])

def p_type(p):
	'type : TYPE'
	p[0] = (p.lineno(1), p[1])

def p_featurelist_none(p):
	'featurelist : '
	p[0] = []

def p_featurelist_some(p):
	'featurelist : feature SEMI featurelist'
	p[0] = [p[1]] + p[3]

# feature ::= ID( [formal [[ formal]]* ]) : TYPE { expr }
#			| ID : TYPE[ <- expr ]
# 'attribute_no_init' must match PA3 directions
def p_feature_attribute_no_init(p):
	'feature : identifier COLON type'
	p[0] = (p.lineno(1), 'attribute_no_init', p[1], p[3])

# Build the PA3 parser from the above rules

























