%option noinput
%option nounput
%option yylineno
%{
    #include "vgobison.tab.h"
    #include "tree.h"
    #include "globalutilities.h"

    int isender(int category);
    int lasttoken;
    int lineno;
    int createSemicolon();
    void createToken(int category);
    void reportGenericError(char *errorMessage);
    void reportError(char *errorMessage);
    void reportErrorOnlyText(char *errorMessage, char *text);
/*
 * This is part of the definitions section.  It starts with %{ and ends with %}.
 * Any text placed in this area will be copied verbatim into the lex.yy.c
 * output file that lex generates, and will be placed near the top of that file.
 *
 * Typically this section is used to #include header files that will be needed
 * in the generated scanner, but any legal C code can be placed here.  This
 * scanner does not need any extra header files, so we don't #include any here.
 *
 * Please see http://flex.sourceforge.net for further details.
 */
%}
    /*
     * This is also part of the definitions section. Anything after the %} above
     * until the %% below is interpreted by lex as formal definitions.  Things
     * here won't be copied verbatim into the generated lex.yy.c output file,
     * but will be analyzed by lex.  Some definitions have been placed below.
     * You may add more definitons here.  You may also add comments, but they
     * must be indented because anything that appears in the leftmost column
     * is considered the start of a formal definition.
     */
WHITESPACE          [ \t\r]
NEWLINE             "\n"

COMMENT             "//".*

IDENTIFIER          [a-zA-Z_][_a-z0-9A-Z]{0,11}

LPAREN              "("
RPAREN              ")"
LSQUAREBRACE        "["
RSQUAREBRACE        "]"
LBRACKET            "{"
RBRACKET            "}"

PERIOD              "."
COMA                ","
SEMICOLON           ";"
COLON               ":"
EXCLAMATION         "!"

EQUAL               "="
EQUALEQUAL          "=="
NOTEQUAL            "!="
LESSTHAN            "<"
GREATERTHAN         ">"
LESSTHANEQUAL       "<="
GREATERTHANEQUAL    ">=" 
ANDAND              "&&"
OROR                "||"

PLUS                "+"
PLUSPLUS            "++"
PLUSEQUAL           "+="
MINUS               "-"
MINUSMINUS          "--"
MINUSEQUAL          "-="
STAR                "*"
DIVIDE              "/"
MOD                 "%"

STRINGLIT              \"[^\"]*\"
CHAR                \'(.|\\.)\'

NUMBER              0|([1-9][0-9]*)
DECIMAL             [0-9]*"."[0-9]+
OCTAL               0[0-7]+
HEXADECIMAL         0x[0-9A-Fa-f]+
SCIENTIFICNUM       [0-9]"."[0-9]*[eE]("-")?[0-9]+

BCOMMENT            "/*"[^/]*"*/"
BSTRINGLIT          \"[^\"]*
COLONEQUAL          ":="
AND                 "&"
ANDEQUAL            "&="
OR                  "|"
OREQUAL             "|="
CARET               "^"
STAREQUAL           "*="
CARETEQUAL          "^="
LESSMINUS           "<-"
LESSLESS            "<<"
DIVIDEEQUAL         "/="
LESSLESSEQUAL       "<<="
GREATERGREATER      ">>"
MODEQUAL            "%="
GREATERGREATEREQUAL ">>="
ANDCARET            "&^"
IMAGINARY           ((0|([1-9][0-9]*))|([0-9]*"."[0-9]+)|(0[0-7]+)|(0x[0-9A-Fa-f]+)|([0-9]"."[0-9]*[eE]("-")?[0-9]+))[iI]
TOOLONGSTRINGLIT       [a-z][A-Za-z0-9_]{12,}
BACKTICK            "`"[^`]*"`"
QUESTION            "?"
DOLLAR              "$"


%%
    /*
     * This is the rules section.  It starts with the %% above and continues
     * until the %% down below.  This section contains rules that are analyzed
     * by lex.  Each rule is composed of a pattern and an action. The pattern
     * of a rule uses UNIX-ish regular expressions to indicate what the lexeme
     * "looks like", and the action of a rule specifies what is to be done when
     * a lexeme matching the pattern is encountered.  The pattern and the action
     * of a rule are separated by whitespace.  Patterns of a rule can be chained
     * together using the | operator so that any lexeme matching any of the
     * chained patterns will provoke the action associated with that rule. An
     * example of this appears in the "keyword" rule below.
     *
     * You may also place comments here, but they also must be indented because
     * anything that appears in the leftmost column is considered the start of
     * the pattern of a rule by lex.
     *
     * Please see http://flex.sourceforge.net for further details.
     */

{WHITESPACE}    {}/* Do nothing */
{NEWLINE}       {lineno++; if(isender(lasttoken)){lasttoken = 0; return createSemicolon();};}

{COMMENT}       {}


break   |
default |
interface   |
select  |
case    |
defer   |
go      |
chan    |
goto    |
switch  |
fallthrough |
range   |
continue    {
    reportErrorOnlyText("Error: found `%s` which is not supported in VGo.\n", yytext);
     return -1;
}

func    {createToken(LFUNC); return LFUNC;}
map     {createToken(LMAP); return LMAP;}
struct  {createToken(LSTRUCT); return LSTRUCT;}
else    {createToken(LELSE); return LELSE;}
package {createToken(LPACKAGE); return LPACKAGE; }
const   {createToken(LCONST); return LCONST;}
if      {createToken(LIF); return LIF;}
type    {createToken(LTYPE); return LTYPE;}
for     {createToken(LFOR); return LFOR;}
import  {createToken(LIMPORT); return LIMPORT;}
return  {createToken(LRETURN); return LRETURN;}
var     {createToken(LVAR); return LVAR;}

bool    {createToken(BOOL); return BOOL;}
string  {createToken(STRING); return STRING;}
int     {createToken(INT); return INT;}
float64 {createToken(FLOAT64); return FLOAT64;}

{IDENTIFIER}    {createToken(LNAME); return LNAME;} /* Add more */

{LPAREN}        {createToken(LPAREN); return LPAREN; }
{RPAREN}        {createToken(RPAREN); return RPAREN; }
{LSQUAREBRACE}  {createToken(LSQUAREBRACE); return LSQUAREBRACE;}
{RSQUAREBRACE}  {createToken(RSQUAREBRACE); return RSQUAREBRACE;}
{LBRACKET}      {createToken(LBRACKET); return LBRACKET;}
{RBRACKET}      {createToken(RBRACKET); return RBRACKET;}

{PERIOD}        {createToken(PERIOD); return PERIOD;}
{COMA}          {createToken(COMA); return COMA;}
{SEMICOLON}     {createToken(SEMICOLON); return SEMICOLON;}
{COLON}         {createToken(COLON); return COLON;}
{EXCLAMATION}   {createToken(EXCLAMATION); return EXCLAMATION;}

{EQUAL}         {createToken(EQUAL); return EQUAL;}
{EQUALEQUAL}    {createToken(LEQ); return LEQ;}
{NOTEQUAL}      {createToken(LNE); return LNE;}
{LESSTHAN}      {createToken(LLT); return LLT;}
{GREATERTHAN}   {createToken(LGT); return LGT;}
{LESSTHANEQUAL} {createToken(LLE); return LLE;}
{GREATERTHANEQUAL}  {createToken(LGE); return LGE;}
{ANDAND}        {createToken(LANDAND); return LANDAND;}
{OROR}          {createToken(LOROR); return LOROR;}

{PLUS}          {createToken(PLUS); return PLUS;}
{PLUSPLUS}      {createToken(LINC); return LINC;}
{PLUSEQUAL}     {createToken(LASOP); return LASOP;}
{MINUS}         {createToken(MINUS); return MINUS;}
{MINUSMINUS}    {createToken(LDEC); return LDEC;}
{MINUSEQUAL}    {createToken(LASOP); return LASOP;}
{STAR}          {createToken(STAR); return STAR;}
{DIVIDE}        {createToken(DIVIDE); return DIVIDE;}
{MOD}           {createToken(MOD); return MOD;}

{STRINGLIT}        {createToken(STRINGLIT); return STRINGLIT;}
{CHAR}          {createToken(CHAR); return CHAR;}

{NUMBER}        {createToken(NUMERICLITERAL); return NUMERICLITERAL;}
{DECIMAL}       {createToken(DECIMAL); return DECIMAL;}
{OCTAL}         {createToken(OCTAL); return OCTAL;}
{HEXADECIMAL}   {createToken(HEXADECIMAL); return HEXADECIMAL;}
{SCIENTIFICNUM} {createToken(SCIENTIFICNUM); return SCIENTIFICNUM;}

<<EOF>>           {if(isender(lasttoken)){lasttoken = 0; return createSemicolon();}else{return -1;}}

{BCOMMENT}      {reportGenericError("Error: found C style comments not supported in VGo\n"); return -1;}
{BSTRINGLIT}    {reportGenericError("Error: missing closing \"\n"); return -1;}
{COLONEQUAL}    {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{AND}           {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{ANDEQUAL}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{OR}            {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{OREQUAL}       {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{CARET}         {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{STAREQUAL}     {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{CARETEQUAL}    {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{LESSMINUS}     {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{LESSLESS}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{DIVIDEEQUAL}   {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{LESSLESSEQUAL} {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{GREATERGREATER}    {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{MODEQUAL}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{GREATERGREATEREQUAL}   {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{ANDCARET}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{IMAGINARY}     {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{TOOLONGSTRINGLIT} {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{BACKTICK}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{QUESTION}      {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}
{DOLLAR}        {reportError("Error: %s.%d found `%s` not supported in VGo\n"); return -1;}

.               {reportErrorOnlyText("Error: found `%s` using the . method in flex.\n", yytext); return -1;}
%%
/*
 * This section is the user subroutines section.  It starts after the %% above
 * and continues to the end of the file. Anything appearing in the section is
 * copied verbatim into the lex.yy.c file generated by lex, and will appear
 * toward the bottom of that file.
 *
 * This section is where subroutines specific to a given scanner are placed.
 * Any legal C code can be placed here.
 *
 * The scanner for this application is not intended to be used by yacc, so
 * here we define a main function that will "drive" the lexer.
 */
void createToken(int category){
    struct Token *data = malloc(sizeof(struct Token));
    data->category = category;

    data->text = malloc(strlen(yytext) + 1);
    data->text = strcpy(data->text, yytext);

    data->linenumber = yylineno;
    data->filename = malloc(strlen(currentfile) + 1);
    strcpy(data->filename, currentfile);


    // initialize ival for later use
    data->ival = -1;
    if(category == NUMERICLITERAL || category == OCTAL || category == HEXADECIMAL){
        int ival = atoi (yytext);
        data->ival = ival;
    }else if(category == SCIENTIFICNUM || category == DECIMAL){
        double dval = atof(yytext); 
        data->dval = dval;
    }else if(category == STRINGLIT || category == CHAR){
    int i = 0;
    data->sval = (char *)malloc(strlen(data->text) + 50);
    data->sval[0] = '\0';
    for(i = 0; i < strlen(data->text); i++){
        if(data->text[i] == '\"'){
            // do nothing
        }
        else if(data->text[i] == '\\'){
            // turn escaped character sequence into actual character
            switch(data->text[i+1]){
                case '\"':
                    data->sval = strcat( data->sval, "\"" );
                    break;
                case '\'':
                    data->sval = strcat(data->sval, "\'");
                    break;
                case '\\':
                    data->sval = strcat(data->sval, "\\");
                    break;
                case 'a':
                    data->sval = strcat(data->sval, "\a");
                    break;
                case 'b':
                    data->sval = strcat(data->sval, "\b");
                    break;
                case 'n':
                    data->sval = strcat(data->sval, "\n");
                    break;
                case 't':
                    data->sval = strcat(data->sval, "\t");
                    break;
                case 'e':
                    data->sval = strcat(data->sval, "\e");
                    break;
                case 'f':
                    data->sval = strcat(data->sval, "\f");
                    break;
                case 'v':
                    data->sval = strcat(data->sval, "\v");
                    break;
                case '?':
                    data->sval = strcat(data->sval, "\?");
                    break;
                default:
                    data->sval = strcat(data->sval, "\\");
		            i--;
                    }
            // skip ahead an extra character
            i++;
        }else{
            // base case copy char
	        char *chartostring = malloc(2); // char + \0
	        chartostring[0] = data->text[i];
	        chartostring[1] = '\0';
            strcat(data->sval, chartostring);
	        free(chartostring);
        }
    }
    data->sval = realloc(data->sval, strlen(data->sval)+1);
    
    }

    struct Node *newNode = malloc(sizeof(struct Node));
    newNode->numberOfChildren = 0;
    newNode->children[0] = NULL;
    newNode->data = data;
    newNode->category = data->category;
    newNode->categoryName = "terminal";
    yylval.node = newNode;
    lasttoken = data->category;
}

void reportError(char *errorMessage){
    printf(errorMessage, currentfile, yylineno, yytext);
    exit(1);
}

void reportGenericError(char *errorMessage){
    printf(errorMessage);
    exit(1);
}

void reportErrorOnlyText(char *errorMessage, char *text){
    printf(errorMessage, text);
    exit(1);
}

 int isender(int category)
{
	switch(category) {
	case LNAME: 
    case RPAREN: 
    case RBRACKET: 
    case RSQUAREBRACE: 
    case STRING: 
    case STRINGLIT: 
    case BOOL: 
    case INT: 
    case FLOAT64: 
    case NUMERICLITERAL: 
    case OCTAL: 
    case HEXADECIMAL: 
    case SCIENTIFICNUM: 
    case DECIMAL: 
    case CHAR:
	     return 1;
	}
	return 0;
}

int createSemicolon(){
    struct Token *data = malloc(sizeof(struct Token));
    data->category = SEMICOLON;
    data->text = ";";
    data->linenumber = yylineno;
    data->filename = malloc(strlen(currentfile) + 1);
    strcpy(data->filename, currentfile);
    
    struct Node *newNode = malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->category = SEMICOLON;
    newNode->categoryName = "terminal";
    newNode->numberOfChildren = 0;
    
    
    yylval.node = newNode;
    return SEMICOLON;
}
int yywrap(){
    return -1;
}

/*
 * This defines yywrap, a special function used by lex to determine what should
 * be done when the end of an input file is encountered.  You can read more
 * about this at http://flex.sourceforge.net
 */
 