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

SOURCES=lex.yy.cc cppcalc-parser.tab.cc 
OBJS:=$(addprefix build/, $(SOURCES:.cc=.o))
DEPS:=$(OBJS:.o=.d)

cppcalc: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) $(LDFLAGS) $^ -o $@	

build/%.o: %.cc
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@
	
build/%.o: %.cc %.hh
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

cppcalc-parser.tab.cc cppcalc-parser.tab.hh: cppcalc-parser.yy
	$(BISON) -Wcounterexamples -d $^

lex.yy.cc lex.yy.hh:	cppcalc.l cppcalc-parser.tab.hh
	$(FLEX) $<

.PHONY: clean

clean:
	rm -f lex.yy.cc lex.yy.hh cppcalc cppcalc-parser.tab.cc cppcalc-parser.tab.hh location.hh
	rm -f $(OBJS)
	rm -f $(DEPS)

-include $(DEPS)