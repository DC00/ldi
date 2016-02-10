# Daniel Coo (djc4ku)
# Raymond Zhao (
# Lexer for Cool
# Parts adapted from PLY documentation

import sys
import lex as lex
from lex import TOKEN

global comment_level
comment_level = 0
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
	'capclass',
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
	'singlecomment',
	'string',
	'tilde',
	'times',
] + list(reserved.values())

# Used during file writing
LEXEMES = [ 
	'integer', 
	'Main', 
	'IO', 
	'main', 
	'Object', 
	'type', 
	'identifier',
	'string', 
	'Int',
	'SELF_TYPE'
]

# Regex helpers
digit            = r'([0-9])'
nondigit         = r'([A-Za-z])'
identifier       = r'(' + nondigit + r'(' + digit + r'|' + nondigit + r')*)'  

# Regex rules for simple tokens
t_at = r'@'
t_colon = r'\:'
t_comma = r','
t_dot = r'\.'
t_divide = r'\/'
t_equals = r'='
t_larrow = r'<-'
t_lparen = r'\('
t_lbrace = r'{'
t_le = r'<='
t_lt = r'<'
t_minus = r'\-'
t_plus = r'\+'
t_rarrow = r'=>'
t_rbrace = r'\}'
t_rparen = r'\)'
t_semi = r'\;'
t_tilde = r'\~'
t_times = r'\*'

# Comments - Single line and block comments. Nested
# Adapted from PLY documentation

def t_comment(t):
	r'((\(\*(.|\n)*?\*\))|(.*\*\)))|((--)+(.)*)'
	# Update line number
	new_lines = 0
	for c in t.value:
		if c == '\n':
			t.lexer.lineno += 1	
	pass

def t_singlecomment(t):
	r'\-\-(.*)?'
	pass


# states = (
# 	('comment', 'exclusive'),
# )

# def t_begin_comment(t):
# 	r'\(\*'
# 	global comment_level
# 	t.lexer.push_state('comment')             # Starts 'foo' state
# 	comment_level += 1

# def t_comment_end(t):
# 	r'\*\)'
# 	t.lexer.pop_state()                   # Back to the previous state
# 	global comment_level
# 	comment_level -= 1

# def t_comment_string(t):
# 	r'\"([^\\\n]|(\\.))*?\"'	
# 	pass

# def t_comment_literal(t):
# 	r'\'([^\\\n]|(\\.))*?\''
# 	pass

# def t_comment_words(t):
# 	r'[\w]+'
# 	pass

# t_comment_ignore = ' \t\r'

# def t_comment_error(t):
# 	t.lexer.skip(1)



# Handles capitalized Class
def t_capclass(t):
	r'Class'
	t.type = "class"
	return t

# Regex expression rules - harder
def t_type(t):
	r'[A-Z]+(\_)*[\w]*'
	t.type = reserved.get(t.value, 'type')
	return t

# Lowercase reserved words
def t_identifier(t):
	r'\b[a-z]+(\_)*(\-)*(\w)*'
	# r'\b[a-z]+(\_)*[A-Za-z]+'
	t.type = reserved.get(t.value, 'identifier')    	# Check for reserved words, if not found
	return t											# default value is 'identifier'

# Match quoted strings
def t_string(t):
	r'"(?:[^"\\]|\\.)*"'
	t.value = t.value[1:-1]
	return t

def t_integer(t):
	r'[0-9]+'
	t.value = int(t.value)
	return t

# Define a rule so we can track line numbers
def t_newline(t):
	r'\n+'
	t.lexer.lineno += len(t.value)

# A string containing ignored characters (spaces and tabs)
t_ignore  = ' \t\r\f\v'

# Error handling rule
def t_error(t):
	print "ERROR: %d: Lexer: Illegal character %s" % (t.lexer.lineno, t.value[0])
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
