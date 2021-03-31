/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(int, char *, char *, int, char *);
    static int lookup_symbol(char*);
    static int lookup_linenum(char*);
    static void dump_symbol();
    static void pop_for();
    static void pop_if();
    void insert_for(int);
    void insert_if(int);
    int top_for();
    int top_if();
    static void init_satck();


    int scope_num = 0;
    int total_index = 0;
    int current_inedx = 0;
    int state = 0;
    int print_flag = 0;
    int print_flag2 = 0;
    int address = 0;
    int dec_flag = 0;
    int bool_flag = 0;
    int condition_flag = 0;
    int e_flag = 0;
    int error_flag = 0;
    int not_flag = 0;
    int num_cmp = 0;
    int assign_flag = 0;
    int if_for_flag = 0;
    int if_end = 0;
    int else_flag = 0;
    int if_flag = 0;
    int for_flag = 0;
    int for_closure = 0;
    int num_if = 0, num_for = 0;

    typedef struct symbol_table{
        int index;
        char name[100];
        char type[100];
        int address;
        int line_num;
        int scope;
        char element_type[15];
    }symbol_table;

    int stack_if[100];
    int stack_for[100];

    FILE *hw3;

    symbol_table table[100], table_n;
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}

/* Token without return */
%token VAR 
%token <s_val> INT FLOAT BOOL STRING TRUE FALSE ID
%token <s_val> '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token <s_val> '!'
%token '(' ')' '[' ']' '{' '}'
%token ';' ',' NEWLINE
%token PRINT PRINTLN IF ELSE FOR

%left <s_val> LOR
%left <s_val> LAND
%left <s_val> '>' '<' GEQ LEQ EQL NEQ
%left <s_val> '+' '-'
%left <s_val>  '*' '/' '%'
%left <s_val> INC DEC

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STR_LIT

/* Nonterminal with return, which need to sepcify type */
%type <s_val> TypeName ArrayType assign_op UnaryExpr unary_op Operand PrimaryExpr Expression BOOL_LIT Literal IncDec_op IndexExpr

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList
;

StatementList
    : StatementList Statement
    | Statement
;

Statement
    : DeclarationStmt NEWLINE
    | SimpleStmt NEWLINE
    | Block NEWLINE
    | PrintStmt NEWLINE
    | ForStmt NEWLINE
    | IFStmt NEWLINE
    | NEWLINE
;

SimpleStmt
    : AssigmentStmt
    | ExpressionStmt
    | IncDecStmt
;

DeclarationStmt
    : VAR ID TypeName   {
        dec_flag = 1;
        int a = lookup_symbol($2);
        if(!(a+1)) {
            insert_symbol(current_inedx, $2, $3, yylineno, "-");
            current_inedx++;
            total_index++;
        }
        else {
            printf("error:%d: %s %s %d\n", yylineno, $2, "redeclared in this block. previous declaration at line", lookup_linenum($2));
            error_flag = 1;
        }
        dec_flag = 0;
        if(!strcmp($3,"int32")){
            fprintf(hw3,"\tldc 0\n");
            fprintf(hw3,"\tistore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"float32")){
            fprintf(hw3,"\tldc %f\n", 0.0);
            fprintf(hw3,"\tfstore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"string")){
            fprintf(hw3,"\tldc \"\"\n");
            fprintf(hw3,"\tastore %d\n", table[lookup_symbol($2)].address);
        }
    }
    | VAR ID ArrayType  {
        dec_flag = 1;
        int a = lookup_symbol($2);
        if(!(a+1)) {
            insert_symbol(current_inedx, $2, "array", yylineno, $3);
            current_inedx++;
            total_index++;
        }
        else {
            printf("error:%d: %s %s %d\n", yylineno, $2, "redeclared in this block. previous declaration at line", lookup_linenum($2));
            error_flag = 1;
        }
        dec_flag = 0;
        if(!strcmp($3,"int32")){
            fprintf(hw3,"\tnewarray int\n");
            fprintf(hw3,"\tastore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"float32")){
            fprintf(hw3,"\tnewarray float\n");
            fprintf(hw3,"\tastore %d\n", table[lookup_symbol($2)].address);
        }
    }
    | VAR ID TypeName assign_Expression   {
        dec_flag = 1;
        int a = lookup_symbol($2);
        if(!(a+1)) {
            insert_symbol(current_inedx, $2, $3, yylineno, "-");
            current_inedx++;
            total_index++;
        }
        else {
            printf("error:%d: %s %s %d\n", yylineno, $2, "redeclared in this block. previous declaration at line", lookup_linenum($2));
            error_flag = 1;
        }
        dec_flag = 0;
        if(!strcmp($3,"int32")){
            fprintf(hw3,"\tistore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"float32")){
            fprintf(hw3,"\tfstore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"string")){
            fprintf(hw3,"\tastore %d\n", table[lookup_symbol($2)].address);
        }
        else if(!strcmp($3,"bool")){
            fprintf(hw3,"\tistore %d\n", table[lookup_symbol($2)].address);
        }
        assign_flag = 0;
    }
    | VAR ID ArrayType assign_Expression    {
        dec_flag = 1;
        int a = lookup_symbol($2);
        if(!(a+1)) {
            insert_symbol(current_inedx, $2, "array", yylineno, $3);
            current_inedx++;
            total_index++;
        }
        else {
            printf("error:%d: %s %s %d\n", yylineno, $2, "redeclared in this block. previous declaration at line", lookup_linenum($2));
            error_flag = 1;
        }
        dec_flag = 0;
    }
;

assign_Expression
    : '=' Expression
;

AssigmentStmt
    : Expression assign_op Expression   {
        if(strcmp(table[lookup_symbol($1)].element_type,$3) && strcmp(table[lookup_symbol($1)].type,$3) && strcmp($3,"TRUE") && strcmp($3,"FALSE")){
            if(!e_flag) {
                if(!strcmp($2,"ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                else if(!strcmp($2,"ADD_ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                else if(!strcmp($2,"SUB_ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                else if(!strcmp($2,"MUL_ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                else if(!strcmp($2,"QUO_ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                else if(!strcmp($2,"REM_ASSIGN")){
                    if(!strcmp(table[lookup_symbol($1)].type,"int32") || !strcmp(table[lookup_symbol($1)].element_type,"int32"))
                        yyerror("invalid operation: ASSIGN (mismatched types int32 and float32)");
                    else yyerror("invalid operation: ASSIGN (mismatched types float32 and int32)");
                    error_flag = 1;
                }
                e_flag = 0;
            }
        }
        if(!strcmp($2,"ADD_ASSIGN")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tiadd\n");
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tfadd\n");
            }
        }
        else if(!strcmp($2,"SUB_ASSIGN")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tisub\n");
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
               fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tfsub\n");
            }
        }
        else if(!strcmp($2,"MUL_ASSIGN")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\timul\n");
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tfmul\n");
            }
        }
        else if(!strcmp($2,"QUO_ASSIGN")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tidiv\n");
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tswap\n");
                fprintf(hw3,"\tfdiv\n");
            }
        }
        else if(!strcmp($2,"REM_ASSIGN")){
            fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tirem\n");
        }
        if(!strcmp(table[lookup_symbol($1)].type,"int32")){
            fprintf(hw3,"\tistore %d\n", table[lookup_symbol($1)].address);
        }
        else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
            fprintf(hw3,"\tfstore %d\n", table[lookup_symbol($1)].address);
        }
        else if(!strcmp(table[lookup_symbol($1)].type,"array")){
            if(!strcmp(table[lookup_symbol($1)].element_type,"int32")){
                fprintf(hw3,"\tiastore\n");
            }
            else if(!strcmp(table[lookup_symbol($1)].element_type,"float32")){
                fprintf(hw3,"\tfastore\n");
            }
        }
        else if(!strcmp(table[lookup_symbol($1)].type,"string")){
                fprintf(hw3,"\tastore %d\n", table[lookup_symbol($1)].address);
        }
        else if(!strcmp(table[lookup_symbol($1)].type,"bool")){
            fprintf(hw3,"\tistore %d\n", table[lookup_symbol($1)].address);
        }
        assign_flag = 0;
        printf("%s\n",$2);
    }
    | Literal assign_op Expression  {
        printf("error:%d: %s%s\n", yylineno, "cannot assign to ", $1);
        printf("%s\n",$2);
        error_flag = 1;
        assign_flag = 0;
    }
;

assign_op
    : '='   {$$=$1;}
    | ADD_ASSIGN    {$$=$1;}
    | SUB_ASSIGN    {$$=$1;}
    | MUL_ASSIGN    {$$=$1;}
    | QUO_ASSIGN    {$$=$1;}
    | REM_ASSIGN    {$$=$1;}
;

ExpressionStmt
    : Expression
;

IncDecStmt
    : Expression  IncDec_op {
        printf("%s\n",$2);
        if(!strcmp($2,"INC")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tldc 1\n");
                fprintf(hw3,"\tiadd\n");
                fprintf(hw3,"\tistore %d\n", table[lookup_symbol($1)].address);
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tldc %f\n", 1.0);
                fprintf(hw3,"\tfadd\n");
                fprintf(hw3,"\tfstore %d\n", table[lookup_symbol($1)].address);
            }
        }
        else if(!strcmp($2,"DEC")){
            if(!strcmp(table[lookup_symbol($1)].type,"int32")){
                fprintf(hw3,"\tiload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tldc 1\n");
                fprintf(hw3,"\tisub\n");
                fprintf(hw3,"\tistore %d\n", table[lookup_symbol($1)].address);
            }
            else if(!strcmp(table[lookup_symbol($1)].type,"float32")){
                fprintf(hw3,"\tfload %d\n", table[lookup_symbol($1)].address);
                fprintf(hw3,"\tldc %f\n", 1.0);
                fprintf(hw3,"\tfsub\n");
                fprintf(hw3,"\tfstore %d\n", table[lookup_symbol($1)].address);
            }
        }
    }
;

IncDec_op
    : INC   {$$=$1;}
    | DEC   {$$=$1;}
;

Block
    : '{' {
        if(for_closure && !if_flag && !else_flag){
            fprintf(hw3,"for_med_begin_%d:\n", top_for());
        }
        if(for_flag && !if_flag && !else_flag){
            fprintf(hw3,"ifeq for_exit_%d\n", top_for());
        }
        create_symbol();
        } StatementList '}' {
            dump_symbol();
            scope_num--;
        }
;

IFStmt
    : IF Condition '{' {
            num_if++;
            create_symbol();
            insert_if(num_if);
            fprintf(hw3,"\tifeq else_%d\n", top_if());
        } StatementList '}'{
                dump_symbol(); 
                scope_num--;
                fprintf(hw3,"\tgoto end_if_%d\n", top_if());
                fprintf(hw3,"else_%d:\n", top_if()); 
                if_flag = 0;
                else_flag = 0;
            } ELSEStmt {
                fprintf(hw3,"end_if_%d:\n", top_if());
                pop_if();
            }
;

ELSEStmt
    : ELSE IF Condition '{' {
            num_if++;
            insert_if(num_if);
            fprintf(hw3,"\tifeq else_%d\n", top_if());
            create_symbol();
        } StatementList '}'{
                dump_symbol();
                pop_if();
                fprintf(hw3,"\tgoto end_if_%d\n", top_if());
                insert_if(num_if);
                fprintf(hw3,"else_%d:\n", top_if());
                scope_num--;
                if_flag = 0;
                else_flag = 0;
            } ELSEStmt {pop_if();}
    | ELSE '{' {
            create_symbol();
        } StatementList '}'{
                dump_symbol();
                scope_num--;
                if_flag = 0;
                else_flag = 0;
            }
    |
;

Condition
    : Expression    {
        if(condition_flag == 0) {
            printf("error:%d: %s\n", yylineno+1, "non-bool (type int32) used as for condition");
            error_flag = 1;
        }
        else if(condition_flag == 1) {
            printf("error:%d: %s\n", yylineno+1, "non-bool (type float32) used as for condition");
            error_flag = 1;
        }
        if_for_flag = 0;
    }
;

ForStmt
    : FOR Condition Block {
        if(for_flag && !for_closure && !if_flag)
                fprintf(hw3,"goto for_begin_%d\n",top_for());
        else if(for_flag && for_closure && !if_flag)
            fprintf(hw3,"goto for_update_begin_%d\n",top_for());
        fprintf(hw3,"for_exit_%d:\n",top_for()); 
        pop_for();
        for_flag--;
    }
    | FOR Forclause Block {
        if(for_flag && !for_closure && !if_flag)
                fprintf(hw3,"goto for_begin_%d\n",top_for());
        else if(for_flag && for_closure && !if_flag)
            fprintf(hw3,"goto for_update_begin_%d\n",top_for());
        fprintf(hw3,"for_exit_%d:\n",top_for()); 
        pop_for();
        for_flag--;
        for_closure--;
    }
;

Forclause
    : InitStmt ';' {fprintf(hw3,"for_new_begin_%d:\n", top_for()); for_closure += 1;} Condition ';'{
        fprintf(hw3,"goto for_med_begin_%d\n",top_for());
        fprintf(hw3,"for_update_begin_%d:\n",top_for());
    } PostStmt {fprintf(hw3,"goto for_new_begin_%d\n",top_for());}
;

InitStmt
    : SimpleStmt
;

PostStmt
    : SimpleStmt
;

PrintStmt
    : PRINT {print_flag = 0; print_flag2 = 1;} '(' Expression ')'    {
        if(print_flag == 0) {
            printf("PRINT int32\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/print(I)V\n");
        }
        else if(print_flag == 1) {
            printf("PRINT float32\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/print(F)V\n");
        }
        else if(print_flag == 2) {
            num_cmp += 2;
            printf("PRINT bool\n");
            fprintf(hw3,"\tifne L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\tldc \"false\"\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\tldc \"true\"\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        }
        else if(print_flag == 3) {
            printf("PRINT string\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        }
        print_flag2 = 0;
    }
    | PRINTLN {print_flag = 0; print_flag2 = 1;} '(' Expression ')'  {
        if(print_flag == 0) {
            printf("PRINTLN int32\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/println(I)V\n");
        }
        else if(print_flag == 1) {
            printf("PRINTLN float32\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/println(F)V\n");
        }
        else if(print_flag == 2) {
            num_cmp += 2;
            printf("PRINTLN bool\n");
            fprintf(hw3,"\tifne L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\tldc \"false\"\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\tldc \"true\"\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
        }
        else if(print_flag == 3) {
            printf("PRINTLN string\n");
            fprintf(hw3,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(hw3,"\tswap\n");
            fprintf(hw3,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
        }
        print_flag2 = 0;
    }
;

Expression
    : UnaryExpr {$$=$1;}
    | Expression '%' Expression {
        int a = lookup_symbol($1), b = lookup_symbol($3);
        if(!strcmp($1,"float32") || !strcmp($3,"float32") || !strcmp(table[a].type,"float32") || !strcmp(table[b].element_type,"float32")){
            yyerror("invalid operation: (operator REM not defined on float32)");
            error_flag = 1;
        }
        printf("%s\n",$2);
        fprintf(hw3,"\tirem\n");
        $$ = strdup("int32");
    }
    | Expression '*' Expression {
        int a = lookup_symbol($1), b = lookup_symbol($3);
        if((a+1) && (b+1)){
            if(!strcmp(table[a].element_type,table[b].element_type) && strcmp(table[a].type,table[b].type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: MUL (mismatched types int32 and float32)");
                else yyerror("invalid operation: MUL (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
            else if (!strcmp(table[a].type,table[b].type) && strcmp(table[a].element_type,table[b].element_type)){
                if(!strcmp(table[a].element_type,"int32"))
                    yyerror("invalid operation: MUL (mismatched types int32 and float32)");
                else yyerror("invalid operation: MUL (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && (b+1)){
            if(strcmp($1,table[b].type) && strcmp($1,table[b].element_type)){
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: MUL (mismatched types int32 and float32)");
                else yyerror("invalid operation: MUL (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if((a+1) && !(b+1)){
            if(strcmp($3,table[a].type) && strcmp($3,table[a].element_type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: MUL (mismatched types int32 and float32)");
                else yyerror("invalid operation: MUL (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && !(b+1)){
            if(strcmp($1,$3)) {
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: MUL (mismatched types int32 and float32)");
                else yyerror("invalid operation: MUL (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        printf("%s\n",$2);
        if((a+1) && (!strcmp(table[a].type,"float32") || !strcmp(table[a].element_type,"float32"))) {
            fprintf(hw3,"\tfmul\n");
            $$ = strdup("float32");
        }
        else if(!(a+1) && !strcmp($1,"float32")) {
            fprintf(hw3,"\tfmul\n");
            $$ = strdup("float32");
        }
        else if((b+1) && (!strcmp(table[b].type,"float32") || !strcmp(table[b].element_type,"float32"))) {
            fprintf(hw3,"\tfmul\n");
            $$ = strdup("float32");
        }
        else if(!(b+1) && !strcmp($3,"float32")) {
            fprintf(hw3,"\tfmul\n");
            $$ = strdup("float32");
        }
        else {
            fprintf(hw3,"\timul\n");
            $$ = strdup("int32");
        }
    }
    | Expression '/' Expression {
        int a = lookup_symbol($1), b = lookup_symbol($3);
        if((a+1) && (b+1)){
            if(!strcmp(table[a].element_type,table[b].element_type) && strcmp(table[a].type,table[b].type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: QUO (mismatched types int32 and float32)");
                else yyerror("invalid operation: QUO (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
            else if (!strcmp(table[a].type,table[b].type) && strcmp(table[a].element_type,table[b].element_type)){
                if(!strcmp(table[a].element_type,"int32"))
                    yyerror("invalid operation: QUO (mismatched types int32 and float32)");
                else yyerror("invalid operation: QUO (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && (b+1)){
            if(strcmp($1,table[b].type) && strcmp($1,table[b].element_type)){
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: QUO (mismatched types int32 and float32)");
                else yyerror("invalid operation: QUO (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if((a+1) && !(b+1)){
            if(strcmp($3,table[a].type) && strcmp($3,table[a].element_type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: QUO (mismatched types int32 and float32)");
                else yyerror("invalid operation: QUO (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && !(b+1)){
            if(strcmp($1,$3)) {
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: QUO (mismatched types int32 and float32)");
                else yyerror("invalid operation: QUO (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        printf("%s\n",$2);
        if((a+1) && (!strcmp(table[a].type,"float32") || !strcmp(table[a].element_type,"float32"))) {
            fprintf(hw3,"\tfdiv\n");
            $$ = strdup("float32");
        }
        else if(!(a+1) && !strcmp($1,"float32")) {
            fprintf(hw3,"\tfdiv\n");
            $$ = strdup("float32");
        }
        else if((b+1) && (!strcmp(table[b].type,"float32") || !strcmp(table[b].element_type,"float32"))) {
            fprintf(hw3,"\tfdiv\n");
            $$ = strdup("float32");
        }
        else if(!(b+1) && !strcmp($3,"float32")) {
            fprintf(hw3,"\tfdiv\n");
            $$ = strdup("float32");
        }
        else {
            fprintf(hw3,"\tidiv\n");
            $$ = strdup("int32");
        }
    }
    | Expression '+' Expression {
        int a = lookup_symbol($1), b = lookup_symbol($3);
        if((a+1) && (b+1)){
            if(!strcmp(table[a].element_type,table[b].element_type) && strcmp(table[a].type,table[b].type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: ADD (mismatched types int32 and float32)");
                else yyerror("invalid operation: ADD (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
            else if (!strcmp(table[a].type,table[b].type) && strcmp(table[a].element_type,table[b].element_type)){
                if(!strcmp(table[a].element_type,"int32"))
                    yyerror("invalid operation: ADD (mismatched types int32 and float32)");
                else yyerror("invalid operation: ADD (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && (b+1)){
            if(strcmp($1,table[b].type) && strcmp($1,table[b].element_type)){
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: ADD (mismatched types int32 and float32)");
                else yyerror("invalid operation: ADD (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if((a+1) && !(b+1)){
            if(strcmp($3,table[a].type) && strcmp($3,table[a].element_type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: ADD (mismatched types int32 and float32)");
                else yyerror("invalid operation: ADD (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && !(b+1)){
            if(strcmp($1,$3)) {
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: ADD (mismatched types int32 and float32)");
                else yyerror("invalid operation: ADD (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        printf("%s\n",$2);
        if((a+1) && (!strcmp(table[a].type,"float32") || !strcmp(table[a].element_type,"float32"))) {
            fprintf(hw3,"\tfadd\n");
            $$ = strdup("float32");
        }
        else if(!(a+1) && !strcmp($1,"float32")) {
            fprintf(hw3,"\tfadd\n");
            $$ = strdup("float32");
        }
        else if((b+1) && (!strcmp(table[b].type,"float32") || !strcmp(table[b].element_type,"float32"))) {
            fprintf(hw3,"\tfadd\n");
            $$ = strdup("float32");
        }
        else if(!(b+1) && !strcmp($3,"float32")) {
            fprintf(hw3,"\tfadd\n");
            $$ = strdup("float32");
        }
        else {
            fprintf(hw3,"\tiadd\n");
            $$ = strdup("int32");
        }
    }
    | Expression '-' Expression {
        int a = lookup_symbol($1), b = lookup_symbol($3);
        if((a+1) && (b+1)){
            if(!strcmp(table[a].element_type,table[b].element_type) && strcmp(table[a].type,table[b].type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: SUB (mismatched types int32 and float32)");
                else yyerror("invalid operation: SUB (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
            else if (!strcmp(table[a].type,table[b].type) && strcmp(table[a].element_type,table[b].element_type)){
                if(!strcmp(table[a].element_type,"int32"))
                    yyerror("invalid operation: SUB (mismatched types int32 and float32)");
                else yyerror("invalid operation: SUB (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && (b+1)){
            if(strcmp($1,table[b].type) && strcmp($1,table[b].element_type)){
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: SUB (mismatched types int32 and float32)");
                else yyerror("invalid operation: SUB (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if((a+1) && !(b+1)){
            if(strcmp($3,table[a].type) && strcmp($3,table[a].element_type)){
                if(!strcmp(table[a].type,"int32"))
                    yyerror("invalid operation: SUB (mismatched types int32 and float32)");
                else yyerror("invalid operation: SUB (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        else if(!(a+1) && !(b+1)){
            if(strcmp($1,$3)) {
                if(!strcmp($1,"int32"))
                    yyerror("invalid operation: SUB (mismatched types int32 and float32)");
                else yyerror("invalid operation: SUB (mismatched types floatt32 and intt32)");
                error_flag = 1;
            }
        }
        printf("%s\n",$2);
        if((a+1) && (!strcmp(table[a].type,"float32") || !strcmp(table[a].element_type,"float32"))) {
            fprintf(hw3,"\tfsub\n");
            $$ = strdup("float32");
        }
        else if(!(a+1) && !strcmp($1,"float32")) {
            fprintf(hw3,"\tfsub\n");
            $$ = strdup("float32");
        }
        else if((b+1) && (!strcmp(table[b].type,"float32") || !strcmp(table[b].element_type,"float32"))) {
            fprintf(hw3,"\tfsub\n");
            $$ = strdup("float32");
        }
        else if(!(b+1) && !strcmp($3,"float32")) {
            fprintf(hw3,"\tfsub\n");
            $$ = strdup("float32");
        }
        else {
            fprintf(hw3,"\tisub\n");
            $$ = strdup("int32");
        }
    }
    | Expression LOR Expression {
        if(bool_flag == 0 && (strcmp($1,"TRUE") || strcmp($3,"TRUE") || strcmp($1,"FALSE") || strcmp($3,"FALSE"))) {
            yyerror("invalid operation: (operator LOR not defined on int32)");
            error_flag = 1;
        }

        printf("%s\n",$2); 
        fprintf(hw3,"\tior\n");
        print_flag = 2;
        condition_flag = 2;
        bool_flag = 0;
    }
    | Expression LAND Expression    {
        if(bool_flag == 0 && (strcmp($1,"TRUE") || strcmp($3,"TRUE") || strcmp($1,"FALSE") || strcmp($3,"FALSE"))) {
            yyerror("invalid operation: (operator LAND not defined on int32)");
            error_flag = 1;
        }
        printf("%s\n",$2);
        fprintf(hw3,"\tiand\n"); 
        print_flag = 2;
        condition_flag = 2;
    }
    | Expression EQL Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tifeq L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tifeq L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
    | Expression NEQ Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tifne L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tifne L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
    | Expression '<' Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tiflt L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tiflt L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
    | Expression GEQ Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tifge L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tifge L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
    | Expression '>' Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tifgt L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tifgt L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
    | Expression LEQ Expression {
        printf("%s\n",$2); 
        print_flag = 2; 
        bool_flag = 1; 
        condition_flag = 2;
        num_cmp += 2;
        if((!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp($3,"int32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"int32") && !strcmp(table[lookup_symbol($3)].type,"int32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tisub\n");
            fprintf(hw3,"\tifle L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
        else if((!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp($3,"float32")) 
                || (!strcmp(table[lookup_symbol($1)].type,"float32") && !strcmp(table[lookup_symbol($3)].type,"float32"))
                || (!strcmp($1,"int32") && !strcmp($1,"int32"))){
            fprintf(hw3,"\tfcmpl\n");
            fprintf(hw3,"\tifle L_cmp_%d\n", num_cmp-2);
            fprintf(hw3,"\ticonst_0\n");
            fprintf(hw3,"\tgoto L_cmp_%d\n", num_cmp-1);
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-2);
            fprintf(hw3,"\ticonst_1\n");
            fprintf(hw3,"L_cmp_%d:\n", num_cmp-1);
        }
    }
;

UnaryExpr
    : PrimaryExpr   {$$=$1;}
    | unary_op UnaryExpr  {
        if(!strcmp($1,"NEG")){
            if(!strcmp(table[lookup_symbol($2)].type,"float32") || !strcmp($2,"float32")) fprintf(hw3,"\tfneg\n");
            else fprintf(hw3,"\tineg\n");
        }
        else if(!strcmp($1,"NOT")){
            if(!strcmp($2,"FALSE")){
                fprintf(hw3,"\ticonst_1\n");
                fprintf(hw3,"\ticonst_0\n");
            }
            else if(!strcmp($2,"TRUE")){
                fprintf(hw3,"\ticonst_0\n");
                fprintf(hw3,"\ticonst_1\n");
            }
            fprintf(hw3,"\tixor\n");
        }
        not_flag = 0;
        printf("%s\n", $1);
        $$=$2;
    }
;

unary_op
    : '+'   {$$=strdup("POS");}
    | '-'   {$$=strdup("NEG");}
    | '!'   {$$=strdup("NOT"); not_flag = 1;}
;

PrimaryExpr
    : Operand   {$$ = $1;}
    | IndexExpr {$$ = $1;}
    | ConversionExpr    {;}
;

Operand
    : Literal   {$$=$1;}
    | ID    {
        int a = lookup_symbol($1);
        if((a+1)){
            int a = lookup_symbol($1);
            printf("IDENT (name=%s, address=%d)\n", $1, table[a].address);

            if(!strcmp(table[a].type,"float32") || !strcmp(table[a].element_type,"float32")) {
                $$ = $1;
                print_flag = 1;
            }
            else if(!strcmp(table[a].type,"bool") || !strcmp(table[a].element_type,"bool")){
                $$ = $1;
                print_flag = 2;
            }
            else if(!strcmp(table[a].type,"string") || !strcmp(table[a].element_type,"string")){
                $$ = $1;
                print_flag = 3;
            }
            else if(!strcmp(table[a].type,"int32") || !strcmp(table[a].element_type,"int32")){
                $$ = $1;
            }

            if(strcmp(table[a].type,"array")) $$ = $1;
            else if(!strcmp(table[a].type,"array")) $$ = $1;

            if(!strcmp(table[a].type,"int32") && (assign_flag == 1 || print_flag2 == 1 || if_for_flag == 1)){
                fprintf(hw3,"\tiload %d\n", table[a].address);
            }
            else if(!strcmp(table[a].type,"float32") && (assign_flag == 1 || print_flag2 == 1 || if_for_flag == 1)){
                fprintf(hw3,"\tfload %d\n", table[a].address);
            }
            else if(!strcmp(table[a].type,"array")) {
                fprintf(hw3,"\taload %d\n", table[a].address);
            }
            else if(!strcmp(table[a].type,"string")) {
                fprintf(hw3,"\taload %d\n", table[a].address);
            }
            else if(!strcmp(table[a].type,"bool") && (assign_flag == 1 || print_flag2 == 1 || if_for_flag == 1)) {
                fprintf(hw3,"\tiload %d\n", table[a].address);
            }
        }
        else if(!(a+1)){
            printf("error:%d: %s%s\n", yylineno+1, "undefined: ", $1);
            e_flag = 1;
            error_flag = 1;
        }
    }
    | '(' Expression ')'    {$$=$2;}
;

Literal
    : INT_LIT   {
        fprintf(hw3,"\tldc %d\n",$1);
        printf("INT_LIT %d\n",$1);
        $$ = strdup("int32");
        printf("%s\n",$$);
    }
    | FLOAT_LIT {
        fprintf(hw3,"\tldc %f\n",$1);printf("FLOAT_LIT %f\n",$1); 
        print_flag = 1; 
        $$ = strdup("float32"); 
        condition_flag = 1;
    }
    | BOOL_LIT  {
        printf("%s\n",$1); 
        print_flag = 2; 
        $$ = $1;
    }
    | STR_LIT   {
        fprintf(hw3,"\tldc \"%s\"\n",$1);
        printf("STRING_LIT %s\n",$1); 
        print_flag = 3; 
        $$ = strdup("string");
    }
;

BOOL_LIT
    : TRUE {
        if(!not_flag)
            fprintf(hw3,"\ticonst_1\n");
        $$=$1;
    }
    | FALSE {
        if(!not_flag)
            fprintf(hw3,"\ticonst_0\n");
        $$=$1;
    }
;

IndexExpr
    : PrimaryExpr '[' Expression ']'{
        if(!strcmp(table[lookup_symbol($1)].element_type,"int32") && (assign_flag == 1 || print_flag2 == 1)){
            fprintf(hw3,"\tiaload\n");
        }
        else if(!strcmp(table[lookup_symbol($1)].element_type,"float32") && (assign_flag == 1 || print_flag2 == 1)){
            fprintf(hw3,"\tfaload\n");
        }
        $$ = $1;
    }
;

ConversionExpr
    : TypeName '(' Expression ')'   {
        if(!strcmp($1,"int32")){
            printf("F to I\n");
            fprintf(hw3,"\tf2i\n");
            print_flag = 0;
        }
        else if(!strcmp($1,"float32")){
            printf("I to F\n");
            fprintf(hw3,"\ti2f\n");
            print_flag = 1;
        }
    }
;

TypeName
    : INT   {$$=$1;}
    | FLOAT {$$=$1;}
    | STRING    {$$=$1;}
    | BOOL  {$$=$1;}
;

ArrayType
    : '[' Expression ']' TypeName   {$$=$4;}
;

%%

/* C code section */
int main(int argc, char *argv[])
{   
    init_satck();
    hw3 = fopen("hw3.j","w+");
    
    fprintf(hw3,".source hw3.j\n");
    fprintf(hw3,".class public Main\n");
    fprintf(hw3,".super java/lang/Object\n");
    fprintf(hw3,".method public static main([Ljava/lang/String;)V\n");
    fprintf(hw3,".limit stack 100 ; Define your storage size.\n");
    fprintf(hw3,".limit locals 100 ; Define your local space number.\n");

    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    

    yylineno = 0;
    yyparse();
    dump_symbol();
	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    fprintf(hw3,"\treturn\n");
    fprintf(hw3,".end method\n");
    fclose(hw3);
    if(error_flag)
        remove("hw3.j");
    return 0;
}

static void create_symbol() {
    scope_num++;
    current_inedx = 0;
}

static void insert_symbol(int index, char *name, char * type, int line_no, char *element_type) {
    printf("> Insert {%s} into symbol table (scope level: %d)\n", name, scope_num);
    table[total_index].index = index;
    table[total_index].scope = scope_num;
    strcpy(table[total_index].name, name);
    strcpy(table[total_index].type, type);
    table[total_index].line_num = line_no;
    strcpy(table[total_index].element_type, element_type);
    table[total_index].address = address;
    address++;
}

static int lookup_symbol(char* name) {
    int i;
    for(i = total_index-1 ; i >= 0; i--){
        if(!strcmp(table[i].name,name) && table[i].scope == scope_num && dec_flag == 1){
                return i;
        }
        else  if(!strcmp(table[i].name,name) && table[i].scope <= scope_num && dec_flag == 0){
                return i;
        }
    }
    return -1;
}

static void dump_symbol() {
    printf("> Dump symbol table (scope level: %d)\n", scope_num);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    int i, count = 0;
    for(i=0; i < total_index; i++){
        if(table[i].scope == scope_num){
            printf("%-10d%-10s%-10s%-10d%-10d%s\n",
                table[i].index, table[i].name, table[i].type, table[i].address, table[i].line_num, table[i].element_type);
            table[i] = table_n;
            count++;
        }
    }
    total_index -= count;
    if(total_index != 0) current_inedx = table[total_index-1].index + 1;
    else current_inedx = 0;
}

void insert_for(int x){
    for(int i = 0; i < 100; i++){
        if(stack_for[i] == -1){
            stack_for[i] = x;
            return;
        }
    }
}

void insert_if(int x){
    for(int i = 0; i < 100; i++){
        if(stack_if[i] == -1){
            stack_if[i] = x;
            return;
        }
    }
}

int top_for(){
    for(int i = 1; i < 100;i++){
        if(stack_for[i] == -1)
            return stack_for[i-1];
    }
    return -1;
}

int top_if(){
    for(int i = 1; i < 100;i++){
        if(stack_if[i] == -1)
            return stack_if[i-1];
    }
    return -1;
}

static void pop_for(){
    for(int i = 99; i >= 0; i--){
        if(stack_for[i] != -1){
            stack_for[i] = -1;
            return;
        }
    }
}

static void pop_if(){
    for(int i = 99; i >= 0; i--){
        if(stack_if[i] != -1){
            stack_if[i] = -1;
            return;
        }
    }
}

static void init_satck(){
    for(int i = 0;i < 100;i++){
        stack_for[i] = -1;
        stack_if[i] = -1;
    }
}

static int lookup_linenum(char* name) {
    int i;
    for(i = total_index-1 ; i >= 0; i--){
        if(!strcmp(table[i].name,name)){
                return table[i].line_num;

        }
    }
    return -1;
}
