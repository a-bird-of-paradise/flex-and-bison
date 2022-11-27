FLEX=/usr/local/opt/flex/bin/flex
BISON=/usr/local/opt/bison/bin/bison

INCLUDE=-I/usr/local/opt/flex/include/ -I/usr/local/opt/llvm/include
LDFLAGS=-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++
DBGFLAGS=-fsanitize=address -g -fsanitize=leak 
FASTFLAGS=-Ofast -flto=full
CXXFLAGS=$(FASTFLAGS) -std=c++2b -MD
CFLAGS=$(FASTFLAGS) -MD
LIBS=

CC=/usr/local/opt/llvm/bin/clang
CXX=/usr/local/opt/llvm/bin/clang++

SOURCES=lex.yy.c main.c buffuncs.c
OBJS:=$(addprefix build/, $(SOURCES:.c=.o))
DEPS:=$(OBJS:.o=.d)

includer: $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) $(LDFLAGS) $^ -o $@	

build/%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

build/%.o: %.c %.h
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

lex.yy.c lex.yy.h:	includer.l
	$(FLEX) $<

.PHONY: clean

clean:
	rm -f lex.yy.c includer lex.yy.h
	rm -f $(OBJS)
	rm -f $(DEPS)

-include $(DEPS)