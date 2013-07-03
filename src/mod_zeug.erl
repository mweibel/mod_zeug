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
-export([start/2, stop/1, log_packet_send/3]).

% module API
-export([start_link/2]).

% gen_server API
-export([init/1,
	handle_call/3, handle_cast/2, handle_info/2,
	terminate/2, code_change/3
]).

start(Host, Opts) ->
	?INFO_MSG("Starting ~p", [?MODULE]),
	ejabberd_hooks:add(user_send_packet, Host, ?MODULE, log_packet_send, 55),
	Proc = gen_mod:get_module_proc(Host, ?MODULE),
	?DEBUG("Proc! ~p", [Proc]),
	ChildSpec =
			{Proc,
				{?MODULE, start_link, [Host, Opts]},
				transient,
				50,
				worker,
				[?MODULE]},
	?DEBUG("start: ~p", [supervisor:start_child(ejabberd_sup, ChildSpec)]).

stop(Host) ->
	?INFO_MSG("Stopping ~p", [?MODULE]),
	ejabberd_hooks:delete(user_send_packet, Host,
		?MODULE, log_packet_send, 55),
	Proc = gen_mod:get_module_proc(Host, ?MODULE),
	%gen_server:call(Proc, stop),
	supervisor:delete_child(ejabberd_sup, Proc).

start_link(Host, Opts) ->
	Proc = gen_mod:get_module_proc(Host, ?MODULE),
	gen_server:start_link({local, Proc}, ?MODULE, [Host, Opts], []).

init([_Host, _Opts]) ->
	State = {},

	{ok, State}.

log_packet_send(From, To, Packet) ->
	Proc = gen_mod:get_module_proc(From#jid.server, ?MODULE),
	gen_server:cast(Proc, {log_packet, From, To, Packet}).

handle_call(stop, _From, State) ->
	{stop, normal, State}.

handle_cast({log_packet, From, To, Packet}, State) ->
	?DEBUG("Packet received:~nFrom: ~p~nTo: ~p~nPacket: ~p", [From, To, Packet]),
	{noreply, State};

handle_cast(Msg, State) ->
	?DEBUG("Unknown packet received ~p", [Msg]),
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.