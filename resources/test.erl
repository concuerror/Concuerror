%%%----------------------------------------------------------------------
%%% File    : test.erl
%%% Authors : Alkis Gotovos <el3ctrologos@hotmail.com>
%%%           Maria Christakis <christakismaria@gmail.com>
%%% Description : Tests
%%%
%%% Created : 16 May 2010 by Alkis Gotovos <el3ctrologos@hotmail.com>
%%%----------------------------------------------------------------------

-module(test).
-export([test01/0, test02/0, test03/0, test04/0,
	 test05/0, test06/0, test07/0, test08/0,
	 test09/0, test10/0, test11/0, test12/0,
         test13/0]).

-include("ced.hrl").

%% Normal, 2 proc: Simple send-receive.
-spec test01() -> 'ok'.

test01() ->
    ?assert(foo1() =:= ok).

foo1() ->
    Self = self(),
    spawn(fun() -> foo1_1(Self) end),
    receive _Any -> ok end.

foo1_1(Pid) ->
    Pid ! 42.

%% Normal, 3 proc: Only spawns.
-spec test02() -> 'ok'.

test02() ->
    ?assert(foo2() =:= ok).

foo2() ->
    spawn(fun() -> foo2_1() end),
    spawn(fun() -> foo2_2() end),
    ok.

foo2_1() ->
    spawn(fun() -> foo2_2() end).

foo2_2() ->
    42.

%% Normal, 3 proc: Simple send-receive.
-spec test03() -> 'ok'.

test03() ->
    ?assert(foo3() =:= ok).

foo3() ->
    Self = self(),
    spawn(fun() -> foo3_1(Self) end),
    spawn(fun() -> foo3_2(Self) end),
    receive
	_Any1 -> ok
    end,
    receive
	_Any2 -> ok
    end.

foo3_1(Pid) ->
    Pid ! msg1.

foo3_2(Pid) ->
    Pid ! msg2.

%% Deadlock, 2 proc: Both receiving.
-spec test04() -> no_return().

test04() ->
    ?assert(foo4() =:= ok).

foo4() ->
    spawn(fun() -> foo4_1() end),
    receive _Any -> ok end.

foo4_1() ->
    receive _Any -> ok end.

%% Deadlock, 2 proc: Sending 42, expecting to receive 43.
-spec test05() -> no_return().

test05() ->
    ?assert(foo5() =:= ok).

foo5() ->
    Self = self(),
    spawn(fun() -> foo1_1(Self) end),
    receive 43 -> ok end.

%% Normal, 2 proc: Nested send.
-spec test06() -> 'ok'.

test06() ->
    ?assert(foo6() =:= ok).

foo6() ->
    Self = self(),
    spawn(fun() -> foo6_1(Self) end),
    receive
	Any -> receive
		   Any -> ok
	       end
    end.

foo6_1(Pid) ->
    Pid ! Pid ! 42.

%% Normal, 2 proc: Nested send-receive.
-spec test07() -> 'ok'.

test07() ->
    ?assert(foo7() =:= ok).

foo7() ->
    Self = self(),
    Pid = spawn(fun() -> foo7_1(Self) end),
    Msg = hello,
    Pid ! Msg,
    receive
	Msg -> ok
    end.

foo7_1(Pid) ->
    Pid ! receive
	      Any -> Any
	  end.

%% Race, 2 proc: Classic spawn-link race.
-spec test08() -> 'ok'.

test08() ->
    ?assert(foo8() =:= ok).

foo8() ->
    Self = self(),
    Pid = spawn(fun() -> foo1_1(Self) end),
    link(Pid),
    receive
	_Any -> ok
    end.

%% Normal, 2 proc: Like test1/0, but using function from other file.
-spec test09() -> 'ok'.

test09() ->
    ?assert(foo9() =:= ok).

foo9() ->
    Self = self(),
    spawn(fun() -> test_aux:bar(Self) end),
    receive _Any -> ok end.

%% Assertion violation, 3 proc: 
-spec test10() -> 'ok'.

test10() ->
    Self = self(),
    spawn(fun() -> foo3_1(Self) end),
    spawn(fun() -> foo3_2(Self) end),
    receive
	Msg -> ?assert(Msg =:= msg1)
    end.

%% Normal, 2 proc: Simple receive-after with no patterns.
-spec test11() -> 'ok'.

test11() ->
    ?assert(foo11() =:= ok).

foo11() ->
    Self = self(),
    spawn(fun() -> foo1_1(Self) end),
    receive after 42 -> ok end,
    receive _Any -> ok end.

%% Normal, 2 proc: Call to erlang:spawn.
-spec test12() -> 'ok'.

test12() ->
    ?assert(foo12() =:= ok).

foo12() ->
    Self = self(),
    erlang:spawn(fun() -> foo1_1(Self) end),
    receive _Any -> ok end.

%% Normal, 2 proc: Call to erlang:yield.
-spec test13() -> 'ok'.

test13() ->
    ?assert(foo13() =:= ok).

foo13() ->
    Self = self(),
    spawn(fun() -> foo1_1(Self) end),
    erlang:yield(),
    receive _Any -> ok end.