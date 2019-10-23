CC=gcc
CFLAGS=-c -g -Wall
OBJ=vgomain.o lex.yy.o vgobison.tab.o tree.o globalutilities.o semantic.o symboltable.o linkedlist.o

vgo: $(OBJ)
	$(CC) -o vgo $(OBJ)

vgomain.o: vgomain.c vgobison.tab.h globalutilities.h semantic.h
	$(CC) $(CFLAGS) vgomain.c

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) lex.yy.c

lex.yy.c: vgolex.l vgobison.tab.h tree.h globalutilities.h
	flex vgolex.l

vgobison.tab.o: vgobison.tab.c
	$(CC) $(CFLAGS) vgobison.tab.c

vgobison.tab.c vgobison.tab.h: vgobison.y nonterminal.h globalutilities.h
	bison -d vgobison.y

tree.o:	tree.c tree.h nonterminal.h
	$(CC) $(CFLAGS) tree.c

globalutilities.o: globalutilities.c globalutilities.h tree.h
	$(CC) $(CFLAGS) globalutilities.c

semantic.o: semantic.c semantic.h nonterminal.h symboltable.h
	$(CC) $(CFLAGS) semantic.c

symboltable.o: symboltable.c symboltable.h tree.h linkedlist.h
	$(CC) $(CFLAGS) symboltable.c

linkedlist.o: linkedlist.c linkedlist.h
	$(CC) $(CFLAGS) linkedlist.c
	

clean:
	rm $(OBJ)