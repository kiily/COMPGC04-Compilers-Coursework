//User code section

package Example;

import java_cup.runtime.SymbolFactory;

%%
//options and declarations section
%cup
%line
%class Scanner
%{
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
	}
	private SymbolFactory sf;
%}
%eofval{
    return sf.newSymbol("EOF",sym.EOF);
%eofval}

//Lexical rules section

/* I used macro definitions in order to help me define
the regular expressions needed to represent the different
JSONcomponents*/

/*Building a regex for real numbers. In JSON numbers are in base 10 and can 
preceeded by a minus (-) sign; they may have a fractional part (.) and can be in 
scientific notation using an exponent of 10 (E or e) */

digit = [0-9]
non_zero_digit =[1-9]
integer = -? (0|{non_zero_digit}{digit}*)

//adding decimal numbers and scientific notation
dot = [\.]
exp = [eE][+-]?
frac = {dot}{digit}+
sci_notation = {exp}{digit}+
real_number ={integer}{frac}?{sci_notation}?

//adding Booleans
Boolean = (true|false)

/*Adding strings: always start with " and end with ". Note that \", \\, \/, \b, \f, \n, \r, \t,
  \u(four hex digits) are allowed. However any other control character i.e. \followed by anything else
  that is not an escape sequence is illegal; separated macros for the escape sequence and all the unicode
  characters were crated (esc, unichar)*/

esc = \\
unichar =[^\"\\]
StringIn = \"( ({esc}(\" | \\ | \/ |b|f|n|r|t|u[0-9a-fA-F]{4})) | {unichar})* \"



%%
/*scan for start and end symbols for objects and return terminals to the parser (CUP)
Terminals: COMMA, COLON, LCBRACE, RCBRACE, LSQBRACKET, RSQBRACKET, BOOLEAN, NULL, NUMBER, STRING */

"{" {return sf.newSymbol("Left Curly Bracket",sym.LCBRACE);}
"}" {return sf.newSymbol("Right Curly Bracket",sym.RCBRACE);}

//start and end symbols for arrays
"[" { return sf.newSymbol("Left Square Bracket",sym.LSQBRACKET); }
"]" { return sf.newSymbol("Right Square Bracket",sym.RSQBRACKET); }

//separators
"," { return sf.newSymbol("Comma",sym.COMMA); }
":" { return sf.newSymbol( "Colon", sym.COLON);}

//scan for booleans; catches true or false
{Boolean} {return sf.newSymbol("Boolean",sym.BOOLEAN);}

///scan for null string; this will catch null pointers
"null" {return sf.newSymbol("Null", sym.NULL);}

//scan for real numbers; catches any real number 
{real_number} { return sf.newSymbol("Integral Number",sym.NUMBER, new Double(yytext())); }

//scan for strings
{StringIn} { return sf.newSymbol("String",sym.STRING);}
[ \t\r\n\f] { /* ignore white space. */ }

. { System.err.println("Illegal character: "+yytext()+" at line "+(yyline)+ "; at column"+(yycolumn)); }

/*last line will print anything that the lexer does not catch; it outputs the illegal character sepcifying the line
and column at which it was encountered*/
