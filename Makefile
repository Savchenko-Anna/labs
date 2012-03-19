#Makefile 

myreverse: myreverse.o 
	gcc -o myreverse myreverse.o 
myreverse.o:	myreverse.c
	gcc -c myreverse.c
clean: 
	rm -f *.o myreverse
