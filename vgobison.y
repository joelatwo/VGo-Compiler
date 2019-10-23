// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file
// (a copy is at www2.cs.uidaho.edu/~jeffery/courses/445/go/LICENSE).

/*
 * Go language grammar adapted from Go 1.2.2.
 *
 * The Go semicolon rules are:
 *
 *  1. all statements and declarations are terminated by semicolons.
 *  2. semicolons can be omitted before a closing ) or }.
 *  3. semicolons are inserted by the lexer before a newline
 *      following a specific list of tokens.
 *
 * Rules #1 and #2 are accomplished by writing the lists as
 * semicolon-separated lists with an optional trailing semicolon.
 * Rule #3 is implemented in yylex.
 */
%{

#include <stdio.h>
#include <stdlib.h>

#include "tree.h"
#include "globalutilities.h"
#include "nonterminal.h"


// #define YYDEBUG 1
int yylex();
int yyparse();

%}

%union {
	struct Node *node;
}

%token <node>		LLITERAL
%token <node>		CHAR DECIMAL NUMERICLITERAL STRINGLIT OCTAL HEXADECIMAL SCIENTIFICNUM
%token <node>		LASOP LCOLAS
%token <node>		LBREAK LCASE LCHAN LCONST LCONTINUE LDDD
%token <node>		LDEFAULT LDEFER LELSE LFALL LFOR LFUNC LGO LGOTO
%token <node>		LIF LIMPORT LINTERFACE LMAP LNAME
%token <node>		LPACKAGE LRANGE LRETURN LSELECT LSTRUCT LSWITCH
%token <node>		LTYPE LVAR BOOL INT FLOAT64 STRING

%token <node>		LANDAND LANDNOT LCOMM LDEC LEQ LGE LGT
%token <node>		LIGNORE LINC LLE LLSH LLT LNE LOROR LRSH

%token <node>		LBRACKET RBRACKET PERIOD COMA SEMICOLON COLON EXCLAMATION PLUS MINUS STAR DIVIDE MOD LPAREN RPAREN LSQUAREBRACE RSQUAREBRACE EQUAL TILDE AT
%token <node>		LEAF


%type <node>		 import_here
%type <node>		sym packname
%type <node>		oliteral
%type <node>		package
%type <node>		imports
%type <node>		import
%type <node>		import_stmt
%type <node>		import_stmt_list
%type <node>		import_package
%type <node>		ocomma
%type <node>		osemi
%type <node>		lconst
%type <node>		import_safety

%type <node>		stmt ntype
%type <node>		arg_type
%type <node>		compound_stmt dotname embed expr complitexpr bare_complitexpr
%type <node>		expr_or_type
%type <node>		fndcl fnliteral fnlitdcl
%type <node>		for_body for_header for_stmt if_header if_stmt non_dcl_stmt
%type <node>		interfacedcl keyval labelname name
%type <node>		name_or_type non_expr_type
%type <node>		new_name dcl_name oexpr typedclname
%type <node>		onew_name
%type <node>		osimple_stmt pexpr pexpr_no_paren
%type <node>		pseudocall range_stmt
%type <node>		simple_stmt
%type <node>		uexpr
%type <node>		xfndcl typedcl

%type <node>		xdcl fnbody fnres loop_body dcl_name_list
%type <node>		new_name_list expr_list keyval_list braced_keyval_list expr_or_type_list xdcl_list
%type <node>		oexpr_list elseif elseif_list else stmt_list oarg_type_list_ocomma arg_type_list
%type <node>		interfacedcl_list vardcl vardcl_list structdcl structdcl_list
%type <node>		common_dcl constdcl constdcl1 constdcl_list typedcl_list

%type <node>		convtype comptype dotdotdot
%type <node>		indcl interfacetype structtype ptrtype
%type <node>		recvchantype non_recvchantype othertype fnret_type fntype
 
%type <node>		hidden_importsym

%type <node>  		file
%type <node>		semicolon
%type <node>		lliteral type

%left		LCOMM	/* outside the usual hierarchy; here for good error messages */

%left		LOROR
%left		LANDAND
%left		LEQ LNE LLE LGE LLT LGT
%left		PLUS MINUS
%left		STAR DIVIDE MOD LLSH LRSH LANDNOT

/*
 * manual override of shift/reduce conflicts.
 * the general form is that we assign a precedence
 * to the token being shifted and then introduce
 * NotToken with lower precedence or PreferToToken with higher
 * and annotate the reducing rule accordingly.
 */
%left		NotPackage
%left		LPACKAGE

%left		NotParen
%left		LPAREN

%left		RPAREN
%left		PreferToRightParen

%%
file:	package imports xdcl_list { treeHead = createTree(file, "file", 3, $1, $2, $3);}  ;

package:
	%prec NotPackage 
	{
		yyerror("package statement must be first");
		exit(1);
	}
|	LPACKAGE sym semicolon {$$ = createTree(package, "package", 3, $1, $2, $3);}
	;

imports: {$$ = NULL;}
|	imports import semicolon {$$ = createTree(imports, "imports", 3, $1, $2, $3);}
        ;

import:
	LIMPORT import_stmt {$$ = createTree(import, "import", 2, $1, $2);}
|	LIMPORT LPAREN import_stmt_list osemi RPAREN {$$ = createTree(import, "import", 5, $1, $2, $3, $4, $5);}
|	LIMPORT LPAREN RPAREN {$$ = createTree(import, "import", 3, $1, $2, $3);}
	;

import_stmt:
	import_here import_package {$$ = createTree(import_stmt, "import_stmt", 2, $1, $2);}
|	import_here {$$ = createTree(import_stmt, "import_stmt", 1, $1);}
	;

import_stmt_list:
	import_stmt {$$ = createTree(import_stmt_list, "import_stmt_list", 1, $1);}
|	import_stmt_list semicolon import_stmt {$$ = createTree(import_stmt_list, "import_stmt_list", 3, $1, $2, $3);}
	;

import_here:
	lliteral {$$ = createTree(import_here, "import_here", 1, $1);}
|	sym lliteral {$$ = createTree(import_here, "import_here", 2, $1, $2);}
|	PERIOD lliteral {$$ = createTree(import_here, "import_here", 2, $1, $2);}
	;

import_package:
	LPACKAGE LNAME import_safety semicolon {$$ = createTree(import_package, "import_package", 4, $1, $2, $3, $4);}
	;

import_safety: {$$ = NULL;}
|	LNAME {$$ = createTree(import_safety, "import_safety", 1, $1);}
	;
	
xdcl:
	{
		yyerror("empty top-level declaration");
		$$ = 0;
	}
|	common_dcl {$$ = $1;}
|	xfndcl {$$ = $1;}
|	non_dcl_stmt	{
		yyerror("non-declaration statement outside function body");
		$$ = 0;
	}
|	error	{
		$$ = 0;
	}
	;

common_dcl:
	LVAR vardcl {$$ = createTree(common_dcl, "common_dcl", 2, $1, $2);}
|	LVAR LPAREN vardcl_list osemi RPAREN {$$ = createTree(common_dcl, "common_dcl", 5, $1, $2, $3, $4, $5);}
|	LVAR LPAREN RPAREN {$$ = createTree(common_dcl, "common_dcl", 3, $1, $2, $3);}
|	lconst constdcl	{$$ = createTree(common_dcl, "common_dcl", 2, $1, $2);}
|	lconst LPAREN constdcl osemi RPAREN	{$$ = createTree(common_dcl, "common_dcl", 5, $1, $2, $3, $4, $5);}
|	lconst LPAREN constdcl semicolon constdcl_list osemi RPAREN	{$$ = createTree(common_dcl, "common_dcl", 7, $1, $2, $3, $4, $5, $6, $7);}
|	lconst LPAREN RPAREN {$$ = createTree(common_dcl, "common_dcl", 3, $1, $2, $3);}
|	LTYPE typedcl {$$ = createTree(common_dcl, "common_dcl", 2, $1, $2);}
|	LTYPE LPAREN typedcl_list osemi RPAREN {$$ = createTree(common_dcl, "common_dcl", 5, $1, $2, $3, $4, $5);}
|	LTYPE LPAREN RPAREN {$$ = createTree(common_dcl, "common_dcl", 3, $1, $2, $3);}
	;

lconst:
	LCONST {$$ = $1;}
	;

vardcl:
	dcl_name_list ntype {$$ = createTree(vardcl, "vardcl", 2, $1, $2);}
|	dcl_name_list ntype EQUAL expr_list {$$ = createTree(vardcl, "vardcl", 4, $1, $2, $3, $4);}
|	dcl_name_list EQUAL expr_list {$$ = createTree(vardcl, "vardcl", 3, $1, $2, $3);}
	;

constdcl:
	dcl_name_list ntype EQUAL expr_list {$$ = createTree(constdcl, "constdcl", 4, $1, $2, $3, $4);}
|	dcl_name_list EQUAL expr_list {$$ = createTree(constdcl, "constdcl", 3, $1, $2, $3);}
	;

constdcl1:
	constdcl {$$ = createTree(constdcl1, "constdcl1", 1, $1);}
|	dcl_name_list ntype {$$ = createTree(constdcl1, "constdcl1", 2, $1, $2);}
|	dcl_name_list {$$ = createTree(constdcl1, "constdcl1", 1, $1);}
	;

typedclname:
	sym	{
		// the name becomes visible right here, not at the end
		// of the declaration.
	}
	;

typedcl:
	typedclname ntype {$$ = createTree(typedcl, "typedcl", 2, $1, $2);}
	;

simple_stmt:
	expr {$$ = createTree(simple_stmt, "simple_stmt", 1, $1);}
|	expr LASOP expr {$$ = createTree(simple_stmt, "simple_stmt", 3, $1, $2, $3);}
|	expr_list EQUAL expr_list {$$ = createTree(simple_stmt, "simple_stmt", 3, $1, $2, $3);}
|	expr_list LCOLAS expr_list {$$ = createTree(simple_stmt, "simple_stmt", 3, $1, $2, $3);}
|	expr LINC {$$ = createTree(simple_stmt, "simple_stmt", 2, $1, $2);}
|	expr LDEC {$$ = createTree(simple_stmt, "simple_stmt", 2, $1, $2);}
	;

compound_stmt:
        LBRACKET stmt_list RBRACKET {$$ = createTree(compound_stmt, "compound_stmt", 3, $1, $2, $3);}
	;

loop_body:
        LBRACKET stmt_list RBRACKET {$$ = createTree(loop_body, "loop_body", 3, $1, $2, $3);}
	;

range_stmt:
	expr_list EQUAL LRANGE expr {$$ = createTree(range_stmt, "range_stmt", 4, $1, $2, $3, $4);}
|	expr_list LCOLAS LRANGE expr {$$ = createTree(range_stmt, "range_stmt", 4, $1, $2, $3, $4);}
	;

for_header:
	osimple_stmt semicolon osimple_stmt semicolon osimple_stmt {$$ = createTree(for_header, "for_header", 5, $1, $2, $3, $4, $5);}
|	osimple_stmt {$$ = createTree(for_header, "for_header", 1, $1);}
|	range_stmt {$$ = createTree(for_header, "for_header", 1, $1);}
	;

for_body:
	for_header loop_body {$$ = createTree(for_body, "for_body", 2, $1, $2);}
	;

for_stmt:
        LFOR for_body {$$ = createTree(for_stmt, "for_stmt", 2, $1, $2);}
	;

if_header:
	osimple_stmt {$$ = createTree(if_header, "if_header", 1, $1);}
|	osimple_stmt semicolon osimple_stmt {$$ = createTree(if_header, "if_header", 3, $1, $2, $3);}
	;

/* IF cond body (ELSE IF cond body)* (ELSE block)? */
if_stmt:
       LIF 
	   if_header 
	   loop_body 
	   elseif_list else {$$ = createTree(if_stmt, "if_stmt", 5, $1, $2, $3, $4, $5);}
	;

elseif:
	LELSE LIF 
	if_header loop_body {$$ = createTree(elseif, "elseif", 2, $1, $2);}
	;

elseif_list: {$$ = NULL;}
|	elseif_list elseif {$$ = createTree(elseif_list, "elseif_list", 2, $1, $2);}
	;

else: {$$ = NULL;}
|	LELSE compound_stmt {$$ = createTree(nonterminal_else, "nonterminal_else", 2, $1, $2);}
	;

/*
 * expressions
 */
expr:
	uexpr {$$ = $1;}
|	expr LOROR expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LANDAND expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LEQ expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LNE expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LLT expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LLE expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LGE expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LGT expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr PLUS expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr MINUS expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr STAR expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr DIVIDE expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr MOD expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LANDNOT expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LLSH expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
|	expr LRSH expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
	/* not an expression anymore, but left in so we can give a good error */
|	expr LCOMM expr {$$ = createTree(expr, "expr", 3, $1, $2, $3);}
	;

uexpr:
	pexpr {$$ = $1;}
|	STAR uexpr {$$ = createTree(uexpr, "uexpr", 2, $1, $2);}
|	PLUS uexpr {$$ = createTree(uexpr, "uexpr", 2, $1, $2);}
|	MINUS uexpr {$$ = createTree(uexpr, "uexpr", 2, $1, $2);}
|	EXCLAMATION uexpr {$$ = createTree(uexpr, "uexpr", 2, $1, $2);}
|	TILDE uexpr	{
		yyerror("the bitwise complement operator is ^");
	}
|	LCOMM uexpr {$$ = createTree(uexpr, "uexpr", 2, $1, $2);}
	;

/*
 * call-like statements that
 * can be preceded by 'defer' and 'go'
 */
pseudocall:
	pexpr LPAREN RPAREN {$$ = createTree(pseudocall, "pseudocall", 3, $1, $2, $3);}
|	pexpr LPAREN expr_or_type_list ocomma RPAREN {$$ = createTree(pseudocall, "pseudocall", 5, $1, $2, $3, $4, $5);}
|	pexpr LPAREN expr_or_type_list LDDD ocomma RPAREN {$$ = createTree(pseudocall, "pseudocall", 6, $1, $2, $3, $4, $5, $6);}
	;

pexpr_no_paren:
	lliteral {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 1, $1);}
|	name {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 1, $1);}
|	pexpr PERIOD sym {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 3, $1, $2, $3);}
|	pexpr PERIOD LPAREN expr_or_type RPAREN {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 5, $1, $2, $3, $4, $5);}
|	pexpr PERIOD LPAREN LTYPE RPAREN {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 5, $1, $2, $3, $4, $5);}
|	pexpr LSQUAREBRACE expr RSQUAREBRACE {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 4, $1, $2, $3, $4);}
|	pexpr LSQUAREBRACE oexpr COLON oexpr RSQUAREBRACE {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 6, $1, $2, $3, $4, $5, $6);}
|	pexpr LSQUAREBRACE oexpr COLON oexpr COLON oexpr RSQUAREBRACE {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 8, $1, $2, $3, $4, $5, $6, $7, $8);}
|	pseudocall {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 1, $1);}
|	convtype LPAREN expr ocomma RPAREN {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 5, $1, $2, $3, $4, $5);}
|	comptype LBRACKET braced_keyval_list RBRACKET {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 4, $1, $2, $3, $4);}
|	fnliteral {$$ = createTree(pexpr_no_paren, "pexpr_no_paren", 1, $1);}

keyval:
	expr COLON complitexpr {$$ = createTree(keyval, "keyval", 3, $1, $2, $3);}
	;

bare_complitexpr:
	expr {$$ = createTree(bare_complitexpr, "bare_complitexpr", 1, $1);}
|	LBRACKET braced_keyval_list RBRACKET {$$ = createTree(bare_complitexpr, "bare_complitexpr", 3, $1, $2, $3);}
	;

complitexpr:
	expr {$$ = $1;}
|	LBRACKET braced_keyval_list RBRACKET {$$ = createTree(complitexpr, "complitexpr", 3, $1, $2, $3);}
	;

pexpr:
	pexpr_no_paren {$$ = $1;}
|	LPAREN expr_or_type RPAREN {$$ = createTree(pexpr, "pexpr", 3, $1, $2, $3);}
	;

expr_or_type:
	expr {$$ = createTree(expr_or_type, "expr_or_type", 1, $1);}
|	non_expr_type	%prec PreferToRightParen {$$ = createTree(expr_or_type, "expr_or_type", 1, $1);}

name_or_type:
	ntype {$$ = createTree(name_or_type, "name_or_type", 1, $1);}

/*
 * names and types
 *	newname is used before declared
 *	oldname is used after declared
 */
new_name:
	sym {$$ = createTree(new_name, "new_name", 1, $1);}
	;

dcl_name:
	sym {$$ = createTree(dcl_name, "dcl_name", 1, $1);}
	;

onew_name:
	new_name {$$ = createTree(onew_name, "onew_name", 1, $1);}
	;

sym:
	LNAME {$$ = $1;}
|	hidden_importsym {$$ = $1;}
	;

hidden_importsym:
	AT lliteral PERIOD LNAME {$$ = createTree(hidden_importsym, "hidden_importsym", 4, $1, $2, $3, $4);}
	;

name:
	sym	%prec NotParen {$$ = $1;}
	;

labelname:
	new_name {$$ = $1;}
	;

/*
 * to avoid parsing conflicts, type is split into
 *	channel types
 *	function types
 *	parenthesized types
 *	any other type
 * the type system makes additional restrictions,
 * but those are not implemented in the grammar.
 */
dotdotdot:
	LDDD	{
		yyerror("final argument in variadic function missing type");
	}
|	LDDD ntype {$$ = createTree(dotdotdot, "dotdotdot", 2, $1, $2);}
	;

ntype:
	recvchantype {$$ = $1;}
|	fntype {$$ = $1;}
|	othertype {$$ = $1;}
|	ptrtype {$$ = $1;}
|	dotname {$$ = $1;}
|	LPAREN ntype RPAREN {$$ = createTree(ntype, "ntype", 3, $1, $2, $3);}
	;

non_expr_type:
	recvchantype {$$ = createTree(non_expr_type, "non_expr_type", 1, $1);}
|	fntype {$$ = createTree(non_expr_type, "non_expr_type", 1, $1);}
|	othertype {$$ = createTree(non_expr_type, "non_expr_type", 1, $1);}
|	STAR non_expr_type {$$ = createTree(non_expr_type, "non_expr_type", 2, $1, $2);}
	;

non_recvchantype:
	fntype {$$ = createTree(non_recvchantype, "non_recvchantype", 1, $1);}
|	othertype {$$ = createTree(non_recvchantype, "non_recvchantype", 1, $1);}
|	ptrtype {$$ = createTree(non_recvchantype, "non_recvchantype", 1, $1);}
|	dotname {$$ = createTree(non_recvchantype, "non_recvchantype", 1, $1);}
|	LPAREN ntype RPAREN {$$ = createTree(non_recvchantype, "non_recvchantype", 3, $1, $2, $3);}
	;

convtype:
	fntype {$$ = $1;}
|	othertype {$$ = $1;}

comptype:
	othertype {$$ = $1;}
	;

fnret_type:
	recvchantype {$$ = createTree(fnret_type, "fnret_type", 1, $1);}
|	fntype {$$ = createTree(fnret_type, "fnret_type", 1, $1);}
|	othertype {$$ = createTree(fnret_type, "fnret_type", 1, $1);}
|	ptrtype {$$ = createTree(fnret_type, "fnret_type", 1, $1);}
|	dotname {$$ = createTree(fnret_type, "fnret_type", 1, $1);}
	;

dotname:
	name {$$ = $1;}
|	name PERIOD sym {$$ = createTree(dotname, "dotname", 3, $1, $2, $3);}
	;

othertype:
	LSQUAREBRACE oexpr RSQUAREBRACE ntype {$$ = createTree(othertype, "othertype", 4, $1, $2, $3, $4);}
|	LSQUAREBRACE LDDD RSQUAREBRACE ntype {$$ = createTree(othertype, "othertype", 4, $1, $2, $3, $4);}
|	LCHAN non_recvchantype {$$ = createTree(othertype, "othertype", 2, $1, $2);}
|	LCHAN LCOMM ntype {$$ = createTree(othertype, "othertype", 3, $1, $2, $3);}
|	LMAP LSQUAREBRACE ntype RSQUAREBRACE ntype {$$ = createTree(othertype, "othertype", 5, $1, $2, $3, $4, $5);}
|	structtype {$$ = $1;}
|	interfacetype {$$ = $1;}
|	type {$$ = $1;}
	;

ptrtype:
	STAR ntype {$$ = createTree(ptrtype, "ptrtype", 2, $1, $2);}
	;

recvchantype:
	LCOMM LCHAN ntype {$$ = createTree(recvchantype, "recvchantype", 3, $1, $2, $3);}
	;

structtype:
	LSTRUCT LBRACKET structdcl_list osemi RBRACKET {$$ = createTree(structtype, "structtype", 5, $1, $2, $3, $4, $5);}
|	LSTRUCT LBRACKET RBRACKET {$$ = createTree(structtype, "structtype", 3, $1, $2, $3);}
	;

interfacetype:
	LINTERFACE LBRACKET interfacedcl_list osemi RBRACKET {$$ = createTree(interfacetype, "interfacetype", 5, $1, $2, $3, $4, $5);}
|	LINTERFACE LBRACKET RBRACKET {$$ = createTree(interfacetype, "interfacetype", 3, $1, $2, $3);}
	;

/*
 * function stuff
 * all in one place to show how crappy it all is
 */
xfndcl:
	LFUNC fndcl fnbody {$$ = createTree(xfndcl, "xfndcl", 3, $1, $2, $3);}
	;

fndcl:
	sym LPAREN oarg_type_list_ocomma RPAREN fnres {$$ = createTree(fndcl, "fndcl", 3, $1, $3, $5);}
|	LPAREN oarg_type_list_ocomma RPAREN sym LPAREN oarg_type_list_ocomma RPAREN fnres {yyerror("Not supported in VGo");}
	;

fntype:
	LFUNC LPAREN oarg_type_list_ocomma RPAREN fnres {$$ = createTree(fntype, "fntype", 5, $1, $2, $3, $4, $5);}
	;

fnbody: {$$ = NULL;}
|	LBRACKET stmt_list RBRACKET {$$ = createTree(fnbody, "fnbody", 3, $1, $2, $3);}
	;

fnres:
	%prec NotParen	{$$ = NULL;}
|	fnret_type {$$ = $1;}
|	LPAREN oarg_type_list_ocomma RPAREN {$$ = createTree(fnres, "fnres", 3, $1, $2, $3);}
	;

fnlitdcl:
	fntype {$$ = $1;}
	;

fnliteral:
	fnlitdcl LBRACKET stmt_list RBRACKET	{$$ = createTree(fnliteral, "fnliteral", 4, $1, $2, $3, $4);}
|	fnlitdcl error {
	yyerror("Error found in the function literal");}
	;

xdcl_list: {$$ = NULL;}
|	xdcl_list xdcl semicolon {$$ = createTree(xdcl_list, "xdcl_list", 3, $1, $2, $3);}
	;

vardcl_list:
	vardcl {$$ = createTree(vardcl_list, "vardcl_list", 1, $1);}
|	vardcl_list semicolon vardcl {$$ = createTree(vardcl_list, "vardcl_list", 3, $1, $2, $3);}
	;

constdcl_list:
	constdcl1
|	constdcl_list semicolon constdcl1
	;

typedcl_list:
	typedcl {$$ = createTree(typedcl_list, "typedcl_list", 1, $1);}
|	typedcl_list semicolon typedcl {$$ = createTree(typedcl_list, "typedcl_list", 3, $1, $2, $3);}
	;

structdcl_list:
	structdcl {$$ = createTree(structdcl_list, "structdcl_list", 1, $1);}
|	structdcl_list semicolon structdcl {$$ = createTree(structdcl_list, "structdcl_list", 3, $1, $2, $3);}
	;

interfacedcl_list:
	interfacedcl {$$ = createTree(interfacedcl_list, "interfacedcl_list", 1, $1);}
|	interfacedcl_list semicolon interfacedcl {$$ = createTree(interfacedcl_list, "interfacedcl_list", 3, $1, $2, $3);}
	;

structdcl:
	new_name_list ntype oliteral {$$ = createTree(structdcl, "structdcl", 3, $1, $2, $3);}
|	embed oliteral {$$ = createTree(structdcl, "structdcl", 2, $1, $2);}
|	LPAREN embed RPAREN oliteral {$$ = createTree(structdcl, "structdcl", 4, $1, $2, $3, $4);}
|	STAR embed oliteral {$$ = createTree(structdcl, "structdcl", 3, $1, $2, $3);}
|	LPAREN STAR embed RPAREN oliteral {$$ = createTree(structdcl, "structdcl", 5, $1, $2, $3, $4, $5);}
|	STAR LPAREN embed RPAREN oliteral {$$ = createTree(structdcl, "structdcl", 5, $1, $2, $3, $4, $5);}
	;

packname:
	LNAME {$$ = $1;}
|	LNAME PERIOD sym {$$ = createTree(packname, "packname", 3, $1, $2, $3);}
	;

embed:
	packname {$$ = $1;}
	;

interfacedcl:
	new_name indcl {$$ = createTree(interfacedcl, "interfacedcl", 2, $1, $2);}
|	packname {$$ = $1;}
|	LPAREN packname RPAREN {$$ = createTree(interfacedcl, "interfacedcl", 3, $1, $2, $3);}
	;

indcl:
	LPAREN oarg_type_list_ocomma RPAREN fnres {$$ = createTree(indcl, "indcl", 4, $1, $2, $3, $4);}
	;

arg_type:
	name_or_type {$$ = createTree(arg_type, "arg_type", 1, $1);}
|	sym name_or_type {$$ = createTree(arg_type, "arg_type", 2, $1, $2);}
|	sym dotdotdot {$$ = createTree(arg_type, "arg_type", 2, $1, $2);}
|	dotdotdot {$$ = createTree(arg_type, "arg_type", 1, $1);}
	;

arg_type_list:
	arg_type {$$ = createTree(arg_type_list, "arg_type_list", 1, $1);}
|	arg_type_list COMA arg_type {$$ = createTree(arg_type_list, "arg_type_list", 3, $1, $2, $3);}
	;

oarg_type_list_ocomma: {$$ = NULL;}
|	arg_type_list ocomma {$$ = createTree(oarg_type_list_ocomma, "oarg_type_list_ocomma", 2, $1, $2);}
	;

stmt: {$$ = NULL;}
|	compound_stmt {$$ = $1;}
|	common_dcl {$$ = $1;}
|	non_dcl_stmt {$$ = $1;}
|	error	{
	yyerror("Error found in statement rule");}
	;

non_dcl_stmt:
	simple_stmt {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 1, $1);}
|	for_stmt {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 1, $1);}
|	if_stmt {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 1, $1);}
|	labelname COLON 
	stmt {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 3, $1, $2, $3);}
|	LFALL {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 1, $1);}
|	LBREAK onew_name {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
|	LCONTINUE onew_name {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
|	LGO pseudocall {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
|	LDEFER pseudocall {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
|	LGOTO new_name {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
|	LRETURN oexpr_list {$$ = createTree(non_dcl_stmt, "non_dcl_stmt", 2, $1, $2);}
	;

stmt_list:
	stmt {$$ = createTree(stmt_list, "stmt_list", 1, $1);}
|	stmt_list semicolon stmt {$$ = createTree(stmt_list, "stmt_list", 3, $1, $2, $3);}
	;

new_name_list:
	new_name {$$ = createTree(new_name_list, "new_name_list", 1, $1);}
|	new_name_list COMA new_name {$$ = createTree(new_name_list, "new_name_list", 3, $1, $2, $3);}
	;

dcl_name_list:
	dcl_name {$$ = createTree(dcl_name_list, "dcl_name_list", 1, $1);}
|	dcl_name_list COMA dcl_name {$$ = createTree(dcl_name_list, "dcl_name_list", 2, $1, $3);}
	;

expr_list:
	expr {$$ = createTree(expr_list, "expr_list", 1, $1);}
|	expr_list COMA expr {$$ = createTree(expr_list, "expr_list", 3, $1, $2, $3);}
	;

expr_or_type_list:
	expr_or_type {$$ = createTree(expr_or_type_list, "expr_or_type_list", 1, $1);}
|	expr_or_type_list COMA expr_or_type {$$ = createTree(expr_or_type_list, "expr_or_type_list", 3, $1, $2, $3);}
	;

/*
 * list of combo of keyval and val
 */
keyval_list:
	keyval {$$ = createTree(keyval_list, "keyval_list", 1, $1);}
|	bare_complitexpr {$$ = createTree(keyval_list, "keyval_list", 1, $1);}
|	keyval_list COMA keyval {$$ = createTree(keyval_list, "keyval_list", 3, $1, $2, $3);}
|	keyval_list COMA bare_complitexpr {$$ = createTree(keyval_list, "keyval_list", 3, $1, $2, $3);}
	;

braced_keyval_list: {$$ = NULL;}
|	keyval_list ocomma {$$ = createTree(braced_keyval_list, "braced_keyval_list", 2, $1, $2);}
	;

osemi: {$$ = NULL;}
|	semicolon {$$ = $1;}
	;

ocomma: {$$ = NULL;}
|	COMA {$$ = $1;}
	;

oexpr: {$$ = NULL;}
|	expr {$$ = $1;}
	;

oexpr_list: {$$ = NULL;}
|	expr_list {$$ = createTree(oexpr_list, "oexpr_list", 1, $1);}
	;

osimple_stmt: {$$ = NULL;}
|	simple_stmt {$$ = createTree(osimple_stmt, "osimple_stmt", 1, $1);}
	;

oliteral: {$$ = NULL;}
|	lliteral {$$ = $1;}
	;

semicolon:
	SEMICOLON {$$ = $1;}
|	SEMICOLON SEMICOLON {$$ = $1;}
	;

lliteral:
	CHAR {$$ = $1;}
|	DECIMAL {$$ = $1;}
|	NUMERICLITERAL {$$ = $1;}
|	STRINGLIT {$$ = $1;}
|	OCTAL {$$ = $1;}
|	HEXADECIMAL {$$ = $1;}
|	SCIENTIFICNUM {$$ = $1;}
	;

type:
	INT {$$ = $1;}
|	BOOL {$$ = $1;}
|	FLOAT64 {$$ = $1;}
|	STRING {$$ = $1;}
%%
 