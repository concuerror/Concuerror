-module(test).

-export([scenarios/0]).
-export([test_2workers/0]).

scenarios() ->
    [{test_2workers, 0},
     {test_2workers, 2, dpor}].

test_2workers() ->
    rush_hour:test_2workers().