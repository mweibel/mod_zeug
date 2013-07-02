%%
%% mod_zeug
%%
%% An example module for the zurich erlang user group
%%

-module(mod_zeug).
-author('michael.weibel@gmail.com').
-vsn('0.1').

-behaviour(gen_mod).
-behaviour(gen_server).

% required API includes from ejabberd
-include("ejabberd.hrl").
-include("jlib.hrl").

% gen_mod API
-export([start/2, stop/1]).

% module API
-export([start_link/2]).

% gen_server API
-export([init/1,
	handle_call/3, handle_cast/2, handle_info/2,
	terminate/2, code_change/3
]).

start(_Host, _Opts) ->
	ok.

stop(_Host) ->
	ok.

start_link(_Host, _Opts) ->
	ok.

init([_Host, _Opts]) ->
	ok.

handle_call(stop, _From, State) ->
	{stop, normal, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.