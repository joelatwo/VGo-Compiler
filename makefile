CC=gcc
CFLAGS=-c -g -Wall
OBJ=vgo.o lex.yy.o linkedlist.o

vgo: $(OBJ)
	$(CC) -o vgo $(OBJ)

vgo.o: vgo.c
	$(CC) $(CFLAGS) vgo.c

lex.yy.o: lex.yy.c 
	$(CC) $(CFLAGS) lex.yy.c 

lex.yy.c: vgolex.l vgo.tab.h linkedlist.h
	flex vgolex.l

linkedlist.o: linkedlist.c linkedlist.h
	$(CC) $(CFLAGS) linkedlist.c