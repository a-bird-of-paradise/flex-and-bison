#pragma once
#include <cassert>
#include <string>

class cppcalc_ctx 
{
    public:
    cppcalc_ctx(int x) : radix(x), filename("stdin")
    {
        assert(radix > 1 && radix <= 10);
    }

    inline int get_radix(void) { return radix;  }

    std::string *get_filename(void) { return &filename; }

    private:
    int radix;
    std::string filename;
};