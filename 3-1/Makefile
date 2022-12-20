FLEX=/usr/local/opt/flex/bin/flex
BISON=/usr/local/opt/bison/bin/bison

INCLUDE=-I/usr/local/opt/flex/include/ -I/usr/local/opt/llvm/include
LDFLAGS=-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++
DBGFLAGS=-fsanitize=address -g -fsanitize=leak -fno-omit-frame-pointer
FASTFLAGS=-Ofast -flto=full
CXXFLAGS=$(DBGFLAGS) -std=c++2b -MD
CFLAGS=$(DBGFLAGS) -MD
LIBS=

CC=/usr/local/opt/llvm/bin/clang
CXX=/usr/local/opt/llvm/bin/clang++

SOURCES=lex.yy.c calculator.tab.c calc.c
OBJS:=$(addprefix build/, $(SOURCES:.c=.o))
DEPS:=$(OBJS:.o=.d)

calc: $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) $(LDFLAGS) $^ -o $@	

build/%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

build/%.o: %.c %.h
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

calculator.tab.c calculator.tab.h: calculator.y
	$(BISON) -Wcounterexamples -Dparse.trace -d $^

lex.yy.c lex.yy.h:	calc.l	calculator.tab.h
	$(FLEX) $<

.PHONY: clean

clean:
	rm -f lex.yy.c lex.yy.h calc calculator.tab.c calculator.tab.h
	rm -f $(OBJS)
	rm -f $(DEPS)

-include $(DEPS)