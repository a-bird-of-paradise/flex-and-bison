Very straightforward adaptation of the book example here. 

Only snag was `opt_if_not_exists`. Now that `NOT EXISTS` and `EXISTS` are completely different tokens this nonterminal needed a minor amendment. Basically: if `%empty` return 0 else if `IF NOT EXISTS` return 1. 