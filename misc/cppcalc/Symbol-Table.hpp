#pragma once
#include <string>
#include <vector>
#include <unordered_map>    

namespace AST { class AST_Node; }

class Symbol // cheating: more like a struct
{
public:
    Symbol() = delete;
    Symbol(const std::string& Name) : Name(Name), Value(0) {}
    std::string Name;
    double Value;
    std::unique_ptr<AST::AST_Node> func;
    std::vector<Symbol*> symlist; 
};

class Symbol_Table
{
public:
    Symbol *lookup(const std::string& Name) {
        auto it = table.find(Name);
        if(it == table.end()) it = table.emplace(std::make_pair(Name,Symbol(Name))).first;
        return &(it->second);
    }
protected:
    std::unordered_map<std::string,Symbol> table;
};