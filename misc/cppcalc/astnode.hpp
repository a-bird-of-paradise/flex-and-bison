#pragma once
#include <memory>
#include <cmath>
#include <iostream>
#include "Context.hpp"

namespace AST {

enum class Nodetype {
    N_GT = 1,
    N_LT = 2,
    N_NEQ = 3,
    N_EQ = 4,
    N_GEQ = 5,
    N_LEQ = 6
};

enum class Builtin_Function {
    B_SQRT = 1,
    B_EXP = 2,
    B_LOG = 3,
    B_PRINT = 4,
    B_DEBUG = 5,
    B_QUIT = 6,
    B_ABS = 7
};

class AST_Node
{
public:
    virtual ~AST_Node() {}
    virtual double eval() = 0;
};

class Binary_Operation_Node : virtual public AST_Node
{
public:
    Binary_Operation_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        m_left(std::move(left)), m_right(std::move(right)) {}
    friend class User_Node;
protected:
    std::unique_ptr<AST_Node> m_left, m_right;
};

class Add_Node : virtual public Binary_Operation_Node
{
public:
    Add_Node() = delete;
    Add_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left), std::move(right)) {}
    virtual double eval() override { return m_left->eval() + m_right->eval(); }
};

class Sub_Node : virtual public Binary_Operation_Node
{
public:
    Sub_Node() = delete;
    Sub_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left), std::move(right)) {}
    virtual double eval() override { return m_left->eval() - m_right->eval(); }
};

class Mul_Node : virtual public Binary_Operation_Node
{
public:
    Mul_Node() = delete;
    Mul_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left), std::move(right)) {}
    virtual double eval() override { return m_left->eval() * m_right->eval(); }
};

class Div_Node : virtual public Binary_Operation_Node
{
public:
    Div_Node() = delete;
    Div_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left), std::move(right)) {}
    virtual double eval() override { return m_left->eval() / m_right->eval(); }
};

class CMP_Node : virtual public Binary_Operation_Node
{
public:
    CMP_Node() = delete;
    CMP_Node(Nodetype op, std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left),std::move(right)), m_op(op) {}
    virtual double eval() override {
        double l = m_left->eval();
        double r = m_right->eval();
        double answer = 0;
        switch(m_op) {
            case Nodetype::N_GT:    answer = l >    r ? 1 : 0; break;
            case Nodetype::N_LT:    answer = l <    r ? 1 : 0; break;
            case Nodetype::N_GEQ:   answer = l >=   r ? 1 : 0; break;
            case Nodetype::N_LEQ:   answer = l <=   r ? 1 : 0; break;
            case Nodetype::N_EQ:    answer = l ==   r ? 1 : 0; break;
            case Nodetype::N_NEQ:   answer = l !=   r ? 1 : 0; break;
            default:    answer = -1;
        }
        return answer;
    }
protected:
    Nodetype m_op;
};

class List_Node : virtual public Binary_Operation_Node
{
public:
    List_Node() = delete;
    List_Node(std::unique_ptr<AST_Node>&& left, std::unique_ptr<AST_Node>&& right) :
        Binary_Operation_Node(std::move(left), std::move(right)) {}
    virtual double eval() override {
        m_left->eval();
        return m_right->eval();
    }
};

class Unary_Operation_Node : virtual public AST_Node
{
public:
    Unary_Operation_Node(std::unique_ptr<AST_Node>&& left) : m_left(std::move(left)) {}
protected:
    std::unique_ptr<AST_Node> m_left;
};

class Abs_Node : virtual public Unary_Operation_Node
{
public:
    Abs_Node() = delete;
    Abs_Node(std::unique_ptr<AST_Node>&& left) : Unary_Operation_Node(std::move(left)) {}
    virtual double eval() override { double x = m_left->eval(); return x >= 0 ? x : -x; }
};

class Minus_Node : virtual public Unary_Operation_Node
{
public:
    Minus_Node() = delete;
    Minus_Node(std::unique_ptr<AST_Node>&& left) : Unary_Operation_Node(std::move(left)) {}
    virtual double eval() override { return -m_left->eval(); }
};

class Number_Node : virtual public AST_Node
{
public:
    Number_Node(double x) : m_x(x) {}
    virtual double eval() override { return m_x; }
protected:
    double m_x;
};

class Conditional_Node : virtual public AST_Node
{
public:
    Conditional_Node() = delete;
    Conditional_Node(std::unique_ptr<AST_Node>&& cond, 
                    std::unique_ptr<AST_Node>&& then_branch, 
                    std::unique_ptr<AST_Node>&& else_branch) :
                    m_cond(std::move(cond)), 
                    m_then_branch(std::move(then_branch)),
                    m_else_branch(std::move(else_branch)) {}
protected:
    std::unique_ptr<AST_Node> m_cond, m_then_branch, m_else_branch;
};

class If_Node : virtual public Conditional_Node
{
public:
    If_Node() = delete;
    If_Node(std::unique_ptr<AST_Node>&& cond, std::unique_ptr<AST_Node>&& then_branch, std::unique_ptr<AST_Node>&& else_branch) :
        Conditional_Node(std::move(cond), std::move(then_branch),std::move(else_branch)) {}
    virtual double eval() override {
        double answer = 0;
        if(m_cond->eval() != 0) { // true
            answer = m_then_branch->eval();
        }
        else {
            if(m_else_branch.get() != nullptr) {
                answer = m_else_branch->eval();
            }
        }
        return answer;
    }
};

class While_Node : virtual public Conditional_Node
{
public:
    While_Node() = delete;
    While_Node(std::unique_ptr<AST_Node>&& cond, std::unique_ptr<AST_Node>&& then_branch, std::unique_ptr<AST_Node>&& else_branch) :
        Conditional_Node(std::move(cond), std::move(then_branch),std::move(else_branch)) {}
    virtual double eval() override {
        double answer = 0;
        while(m_cond->eval() != 0) answer = m_then_branch->eval();
        return answer;
    }
};

class Assign_Node : virtual public AST_Node
{
public:
    Assign_Node(Symbol *s, std::unique_ptr<AST_Node>&& v) : m_s(s), m_v(std::move(v)) {}
    Assign_Node() = delete;
    virtual double eval() override { return m_s->Value = m_v->eval(); }
protected:
    Symbol *m_s;
    std::unique_ptr<AST_Node> m_v;
};

class Ref_Node : virtual public AST_Node
{
public:
    Ref_Node() = delete;
    Ref_Node(Symbol *s) : m_s(s) {}
    virtual double eval() override { return m_s->Value; }
protected:
    Symbol *m_s;
};

class Builtin_Node : virtual public AST_Node
{
public:
    Builtin_Node() = delete;
    Builtin_Node(Builtin_Function func, std::unique_ptr<AST_Node>&& v, cppcalc::Context *ctx);
    virtual double eval() override;
protected:
    Builtin_Function m_func;
    std::unique_ptr<AST_Node> m_v;
    cppcalc::Context *m_ctx;
};

class User_Node : virtual public AST_Node
{
public:
    User_Node() = delete;
    User_Node(Symbol *s, std::unique_ptr<AST_Node>&& v, cppcalc::Context *ctx);
    virtual double eval() override;

protected:
    Symbol *m_s;
    std::unique_ptr<AST_Node> m_v;
    cppcalc::Context *m_ctx;
};

std::unique_ptr<AST_Node> single_or_list(std::unique_ptr<AST_Node>&& l, std::unique_ptr<AST_Node>&& r);


}