FLEX=/usr/local/opt/flex/bin/flex
BISON=/usr/local/opt/bison/bin/bison

INCLUDE=-I/usr/local/opt/flex/include/ -I/usr/local/opt/llvm/include
LDFLAGS=-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++
DBGFLAGS=-fsanitize=address -g -fsanitize=leak
FASTFLAGS=-Ofast -flto=full
CXXFLAGS=$(DBGFLAGS) -std=c++2b -MD
CFLAGS=$(DBGFLAGS) -MD
LIBS=

CC=/usr/local/opt/llvm/bin/clang
CXX=/usr/local/opt/llvm/bin/clang++

SOURCES=Scanner.cpp Parser.cpp astnode.cpp main.cpp
OBJS:=$(addprefix build/, $(SOURCES:.cpp=.o))
DEPS:=$(OBJS:.o=.d)

cppcalc: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LIBS) $(LDFLAGS) $^ -o $@	

build/%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@
	
build/%.o: %.cpp %.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

Parser.hpp Parser.cpp: cppcalc.y
	$(BISON) -Wcounterexamples -d $^

Scanner.cpp:	cppcalc.l Parser.hpp Parser.cpp
	$(FLEX) $<

.PHONY: clean

clean:
	rm -f location.hh cppcalc Scanner.cpp Parser.hpp Parser.cpp
	rm -f $(OBJS)
	rm -f $(DEPS)

-include $(DEPS)