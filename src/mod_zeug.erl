%%
%% mod_zeug
%%
%% An example module for the zurich erlang user group
%%

-module(mod_zeug).
-author('michael.weibel@gmail.com').
-vsn('0.1').

-behaviour(gen_mod).

% required API includes from ejabberd
-include("ejabberd.hrl").
-include("jlib.hrl").

% gen_mod API
-export([start/2, stop/1]).


start(_Host, _Opts) ->
	ok.

stop(_Host) ->
	ok.