#include "Scanner.hpp"
#include "Parser.hpp"

int main(int argc, char **argv)
{

    cppcalc::Context ctx;
    cppcalc::Scanner scanner(std::cin,std::cerr);
    cppcalc::Parser parser(&scanner,&ctx);

    while(!ctx.done)
    {
        std::cout << "> ";
        parser.parse();
        if(ctx.node.get()) std::cout << " = " << ctx.node->eval() << std::endl;
    }

    return 0;

}