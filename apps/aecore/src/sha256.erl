%%%=============================================================================
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sha256).

-export([hash/1]).

-include("sha256.hrl").


-type hashable() :: term().

-export_type([hashable/0]). 

%%------------------------------------------------------------------------------
%% Calculate the SHA256 hash value of a binary or an erlang term
%%------------------------------------------------------------------------------
-spec hash(hashable()) -> binary().
hash(Data) when is_binary(Data) ->
    <<Hash:?HASH_BITS, _/bitstring>> = crypto:hash(sha256, Data),
    <<Hash:?HASH_BITS>>;
hash(Term) ->
    hash(term_to_binary(Term)).
