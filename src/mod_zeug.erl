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

start(Host, Opts) ->
	ejabberd_hooks:add(user_send_packet, Host, ?MODULE, log_packet_send, 55),
	Proc = gen_mod:get_module_proc(Host, ?MODULE),

	ChildSpec =
			{Proc,
				{?MODULE, start_link, [Host, Opts]},
				transient,
				50,
				worker,
				[?MODULE]},
	supervisor:start_child(ejabberd_sup, ChildSpec).

stop(Host) ->
	ejabberd_hooks:delete(user_send_packet, Host,
		?MODULE, log_packet_send, 55),
	Proc = gen_mod:get_module_proc(Host, ?MODULE),
	gen_server:call(Proc, stop),
	supervisor:delete_child(ejabberd_sup, Proc).

start_link(_Host, _Opts) ->
	ok.

init([_Host, _Opts]) ->
	?INFO_MSG("Starting ~p", [?MODULE]),

	State = {},

	{ok, State}.

log_packet_send(From, To, Packet) ->
	Proc = gen_mod:get_module_proc(From#jid.lserver, ?MODULE),
	gen_server:cast(Proc, {log_packet, From, To, Packet}).

handle_call(stop, _From, State) ->
	{stop, normal, State}.

handle_cast({log_packet, From, To, Packet}, State) ->
	?DEBUG("Packet received:~nFrom: ~s~nTo: ~s~nPacket: ~p", [From, To, Packet]),
	{noreply, State};

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.