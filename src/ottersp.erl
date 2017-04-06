%%%-------------------------------------------------------------------
%%% Licensed to the Apache Software Foundation (ASF) under one
%%% or more contributor license agreements.  See the NOTICE file
%%% distributed with this work for additional information
%%% regarding copyright ownership.  The ASF licenses this file
%%% to you under the Apache License, Version 2.0 (the
%%% "License"); you may not use this file except in compliance
%%% with the License.  You may obtain a copy of the License at
%%%
%%%   http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing,
%%% software distributed under the License is distributed on an
%%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%%% KIND, either express or implied.  See the License for the
%%% specific language governing permissions and limitations
%%% under the License.
%%%
%%%-------------------------------------------------------------------

-module(ottersp).

-export([start/1, start/2, start/3,
         tag/2, tag/3,
         log/1, log/2,
         finish/0,
         ids/0,
         get_span/0
        ]).

-define(KEY, otters_span_information).

%% ====================  SPAN process API  ======================
%% This API uses the process dictionary to collect span information
%% and can be used when all span tags an events happen in the same
%% request handling process.

-spec start(otters:info()) -> ok.
start(Name) ->
    put(?KEY, otters:start(Name)).

-spec start(otters:info(), otters:trace_id()) -> ok.
start(Name, TraceId) ->
    put(?KEY, otters:start(Name, TraceId)).

-spec start(otters:info(), otters:trace_id(), otters:span_id()) -> ok.
start(Name, TraceId, ParentId) ->
    put(?KEY, otters:start(Name, TraceId, ParentId)).

-spec tag(otters:info(), otters:info()) -> ok.
tag(Key, Value) ->
    Span = get(?KEY),
    put(?KEY, otters:tag(Span, Key, Value)),
    ok.

-spec tag(otters:info(), otters:info(), otters:service()) -> ok.
tag(Key, Value, Service) ->
    Span = get(?KEY),
    put(?KEY, otters:tag(Span, Key, Value, Service)),
    ok.

-spec log(otters:info()) -> ok.
log(Text) ->
    Span = get(?KEY),
    put(?KEY, otters:log(Span, Text)),
    ok.

-spec log(otters:info(), otters:service()) -> ok.
log(Text, Service) ->
    Span = get(?KEY),
    put(?KEY, otters:log(Span, Text, Service)),
    ok.

-spec finish() -> ok.
finish() ->
    Span = get(?KEY),
    otters:finish(Span),
    put(?KEY, undefined).

%% This call can be used to retrieve the IDs from the calling process
%% e.g. when you have a gen_server and you get an API function call
%% (which is in the context of the calling process) then calling pget_id()
%% returns a {TraceId, SpanId} that is stored with the process API calls
%% above for the calling process, so they can be used in the handling of
%% the call
-spec ids() -> {otters:trace_id(), otters:span_id()} | undefined.
ids() ->
    Span = get(?KEY),
    otters:ids(Span).

-spec get_span() -> otters:maybe_span().
get_span() ->
    get(?KEY).