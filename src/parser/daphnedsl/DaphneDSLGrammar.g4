/*
 * Copyright 2021 The DAPHNE Consortium
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ****************************************************************************
// Grammar
// ****************************************************************************

// The reason why we do not call it just DaphneDSL is that then, the files
// generated by ANTLR for the parser would have the same name as our own
// "DaphneDSLParser.h/cpp".
grammar DaphneDSLGrammar;

// ****************************************************************************
// Parser rules
// ****************************************************************************

script:
    statement* EOF ;

statement:
    blockStatement
    | exprStatement
    | assignStatement
    | ifStatement
    | whileStatement
    | forStatement
    ;

blockStatement:
    '{' statement* '}' ';'? ;

exprStatement:
    expr ';' ;

assignStatement:
    IDENTIFIER ( ',' IDENTIFIER )* '=' expr ';' ;

ifStatement:
    KW_IF '(' cond=expr ')' thenStmt=statement (KW_ELSE elseStmt=statement)? ;

whileStatement:
    ( KW_WHILE '(' cond=expr ')' bodyStmt=statement | KW_DO bodyStmt=statement KW_WHILE '(' cond=expr ')' ';'? );

forStatement:
    KW_FOR '(' var=IDENTIFIER KW_IN from=expr ':' to=expr (':' step=expr)? ')' bodyStmt=statement ;

expr:
    literal # literalExpr
    | var=IDENTIFIER # identifierExpr
    | '(' expr ')' # paranthesesExpr
    | func=IDENTIFIER '(' expr (',' expr)* ')' # callExpr
    | KW_AS ('.' DATA_TYPE)? ('.' VALUE_TYPE)? '(' expr ')' # castExpr
    | obj=expr '[[' (rows=expr)? ',' (cols=expr)? ']]' # rightIdxFilterExpr
    | obj=expr '[' (rows=expr)? ',' (cols=expr)? ']' # rightIdxExtractExpr
    | lhs=expr op='@' rhs=expr # matmulExpr
    | lhs=expr op='^' rhs=expr # powExpr
    | lhs=expr op=('*'|'/') rhs=expr # mulExpr
    | lhs=expr op=('+'|'-') rhs=expr # addExpr
    | lhs=expr op=('=='|'!='|'<'|'<='|'>'|'>=') rhs=expr # cmpExpr
    ;

literal:
    INT_LITERAL
    | FLOAT_LITERAL
    | bl=boolLiteral
    | STRING_LITERAL
    ;

boolLiteral:
    KW_TRUE | KW_FALSE;

// ****************************************************************************
// Lexer rules
// ****************************************************************************

KW_IF: 'if';
KW_ELSE: 'else';
KW_WHILE: 'while';
KW_DO: 'do';
KW_FOR: 'for';
KW_IN: 'in';
KW_TRUE: 'true';
KW_FALSE: 'false';
KW_AS: 'as';

fragment DIGIT:
    [0-9] ;

fragment NON_ZERO_DIGIT:
    [1-9] ;

fragment LETTER:
    [a-zA-Z] ;

DATA_TYPE:
    ('matrix') ;

VALUE_TYPE:
    ('f64' | 'f32' | 'si64' | 'si32' | 'si8' | 'ui64' | 'ui32' | 'ui8') ;

INT_LITERAL:
    ('0' | '-'? NON_ZERO_DIGIT DIGIT*) ;

FLOAT_LITERAL:
    ('nan' | '-'? 'inf' | '-'? ('0' | NON_ZERO_DIGIT DIGIT*) '.' DIGIT+ );

STRING_LITERAL:
    '"' (ESCAPE_SEQ | ~["\\])* '"';

// Identifiers should come last to disallow any of the above tokens (e.g.
// "matrix", "nan", etc.) as valid identifiers.
IDENTIFIER:
    (LETTER | '_')(LETTER | '_' | DIGIT)* ;

fragment ESCAPE_SEQ: '\\' [bfnrt"\\];

// Comments, whitespaces and new line
SCRIPT_STYLE_LINE_COMMENT : '#' ~('\r' | '\n')* -> skip;
C_STYLE_LINE_COMMENT : '//' ~('\r' | '\n')* -> skip;
MULTILINE_BLOCK_COMMENT : '/*' .*? '*/' -> skip;
WS: [ \t\r\n]+ -> skip;