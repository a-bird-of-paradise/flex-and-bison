FLEX=/usr/local/opt/flex/bin/flex
BISON=/usr/local/opt/bison/bin/bison

INCLUDE=-I/usr/local/opt/flex/include/ -I/usr/local/opt/llvm/include
LDFLAGS=-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++ -L/usr/local/opt/flex/lib/
DBGFLAGS=-fsanitize=address -g -fsanitize=leak 
FASTFLAGS=-Ofast -flto=full
CXXFLAGS=$(DBGFLAGS) -std=c++2b -MD
CFLAGS=$(DBGFLAGS) -MD
LIBS=-lfl

CC=/usr/local/opt/llvm/bin/clang
CXX=/usr/local/opt/llvm/bin/clang++

SOURCES=lex.yy.c
OBJS:=$(addprefix build/, $(SOURCES:.c=.o))
DEPS:=$(OBJS:.o=.d)

calc: $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) $(LDFLAGS) $^ -o $@	

build/%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

lex.yy.c:	calc.l
	$(FLEX) $<

.PHONY: clean

clean:
	rm -f lex.yy.c calc
	rm -f $(OBJS)
	rm -f $(DEPS)

-include $(DEPS)