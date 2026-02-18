%{
#include <stdio.h>
#include <string.h>

int linea = 1;

void print_token(const char* tipo, const char* valor) {
    printf("Linea %d: TOKEN [%-20s] -> Valor: %s\n", linea, tipo, valor);
}
%}

%x COMMENT

DIGITO      [0-9]
LETRA       [a-zA-Z_]
HEX_DIGIT   [0-9a-fA-F]

/* Identificadores */
ID          {LETRA}({LETRA}|{DIGITO})*

/* Números */
ENTERO      {DIGITO}+
HEX         0[xX]{HEX_DIGIT}+
FLOAT       {DIGITO}+\.{DIGITO}+
EXPONENTE   [eE][+-]?{DIGITO}+
CIENTIFICO  ({ENTERO}|{FLOAT}){EXPONENTE}

STRING      \"(\\.|[^"\\])*\"

%%

"//".* { /* Ignorar comentario linea */ }
"/*"            { BEGIN(COMMENT); }
<COMMENT>"*/"   { BEGIN(INITIAL); }
<COMMENT>\n     { linea++; }
<COMMENT>.      { /* Ignorar contenido */ }

"=="            { print_token("OP_REL_IGUAL", yytext); }
"!="            { print_token("OP_REL_DIF", yytext); }
"<="            { print_token("OP_REL_MENOR_IG", yytext); }
">="            { print_token("OP_REL_MAYOR_IG", yytext); }
"&&"            { print_token("OP_LOG_AND", yytext); }
"||"            { print_token("OP_LOG_OR", yytext); }
"+"             { print_token("OP_ARIT_SUMA", yytext); }
"-"             { print_token("OP_ARIT_RESTA", yytext); }
"*"             { print_token("OP_ARIT_MULT", yytext); }
"/"             { print_token("OP_ARIT_DIV", yytext); }
"="             { print_token("OP_ASIGNA", yytext); }
"<"             { print_token("OP_REL_MENOR", yytext); }
">"             { print_token("OP_REL_MAYOR", yytext); }

{HEX}           { print_token("LIT_HEX", yytext); }
{CIENTIFICO}    { print_token("LIT_CIENTIFICO", yytext); }
{FLOAT}         { print_token("LIT_FLOAT", yytext); }
{ENTERO}        { print_token("LIT_ENTERO", yytext); }
{STRING}        { print_token("LIT_STRING", yytext); }

{ID}            { print_token("IDENTIFICADOR", yytext); }

[ \t\r]+        { /* Ignorar espacios */ }
\n              { linea++; }
.               { printf("ERROR en linea %d: Caracter invalido '%s'\n", linea, yytext); }

%%

int yywrap() { return 1; }

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Error abriendo archivo: %s\n", argv[1]);
            return 1;
        }
    } else {
        printf("Ingrese input (Ctrl+D para terminar):\n");
    }
    yylex();
    return 0;
}