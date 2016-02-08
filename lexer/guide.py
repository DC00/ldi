# Daniel Coo (djc4ku)
# Lexer for Cool
# Parts adapted from PLY documentation

import sys
import lex as lex


# List of token names. This is always required
tokens = (
   'integer',
   'plus',
) 


# Regular expression rules for simple tokens
t_plus = r'\+'

# A regular expression rule with some action code
def t_integer(t):
	r'[0-9]+'
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
LEXEMES = [ 'integer' ]

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
