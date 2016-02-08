# Daniel Coo (djc4ku)
# Raymond Zhao (
# Lexer for Cool
# Parts adapted from PLY documentation

import sys
import lex as lex

# Dictionary of reserved words
reserved = {
	'case' 		: 'case',
	'class' 	: 'class',
	'else' 		: 'else',
	'equals' 	: 'equals',
	'esac' 		: 'esac',
	'false'		: 'false',
	'fi'		: 'fi',
	'if'		: 'if',
	'in'		: 'in',
	'inherits'	: 'inherits',
	'isvoid'	: 'isvoid',
	'let'		: 'let',
	'loop'		: 'loop',
	'new'		: 'new',
	'not'		: 'not',
	'of'		: 'of',
	'pool'		: 'pool',
	'then'		: 'then',
	'true'		: 'true',
	'type'		: 'type',
	'while'		: 'while'		
}


# List of token names. This is always required
tokens = [
	'at',
	'colon',
	'comma',
	'divide',
	'dot',
	'identifier',
	'integer',
	'larrow',
	'lbrace',
	'le',
	'lparen',
	'lt',
	'minus',
	'plus',
	'rarrow',
	'rbrace',
	'rparen',
	'semi',
	'string',
	'tilde',
	'times',
] + list(reserved.values())

# Used during file writing
LEXEMES = [ 'integer', 'Main', 'IO', 'main', 'Object', 'type', 'identifier', 'string' ]

# Regex rules for simple tokens
t_colon = r'\:'
t_lparen = r'\('
t_lbrace = r'{'
t_plus = r'\+'
t_rbrace = r'}'
t_rparen = r'\)'
t_semi = r';'

# Regular expression rules - harder
def t_type(t):
	r'([A-Z])\w+'
	t.type = reserved.get(t.value, 'type')
	return t

# Lowercase reserved words
def t_identifier(t):
    r'[a-z_][a-z_0-9]*'
    t.type = reserved.get(t.value, 'identifier')    	# Check for reserved words, if not found
    return t											# default value is 'identifier'

# Match quoted strings
def t_string(t):
	r'"(?:[^"\\]|\\.)*"'
	t.value = t.value[1:-1]
	return t

def t_integer(t):
	r'\d+'
	t.value = int(t.value)	  
	return t

# Define a rule so we can track line numbers
def t_newline(t):
	r'\n+'
	t.lexer.lineno += len(t.value)

# A string containing ignored characters (spaces and tabs)
t_ignore  = ' \t'

# Error handling rule
def t_error(t):
	print "ERROR: %d: LEXER: Illegal character '%s'" % (t.lexer.lineno, t.value[0])
	exit(1)

# Build the lexer
lexer = lex.lex()

# Read in file and run the lexer
filename = sys.argv[1]
f = open(filename, 'r')
file_data = f.read()

lexer.input(file_data)

# Tokenize and write to file
out_string = ""

while True:
	tok = lexer.token()
	if not tok: 
		break	   # No more input
	out_string = out_string + (str(tok.lineno) + "\n")
	out_string = out_string + (str(tok.type) + "\n")
	if tok.type in LEXEMES:
		out_string = out_string + (str(tok.value) + "\n")

out_file = open(sys.argv[1] + "-lex", 'w')
out_file.write(out_string)
out_file.close()
