-module(aecore_suite_utils).

%% Common Test configuration functions.
-export([init_per_suite/2,
         init_per_suite/3,
         init_per_suite/4]).

-export([top_dir/1,
         make_shortcut/1,
         node_config/2,
         create_config/4,
         make_multi/2,
         node_shortcut/2,
         shortcut_dir/1,
         symlink/2]).

-export([cmd/3, cmd/4, cmd/5, cmd/6,
         cmd_res/1,
         delete_file/1,
         set_env/4,
         unset_env/3]).

-export([start_node/2,  % (N, Config)
         start_node/3,  % (N, Config, ExtraEnv :: [{OSEnvVarName, Value}])

         stop_node/2,
         reinit_with_bitcoin_ng/1,
         reinit_with_ct_consensus/1,
         get_node_db_config/1,
         delete_node_db_if_persisted/1,
         expected_mine_rate/0,
         mine_blocks/2,
         mine_blocks/3,
         mine_blocks/4,
         mine_blocks/5,
         mine_all_txs/2,
         mine_micro_block_emptying_mempool_or_fail/1,
         mine_blocks_until_txs_on_chain/3,
         mine_blocks_until_txs_on_chain/4,
         mine_blocks_until_txs_on_chain/5,
         mine_key_blocks/2,
         mine_key_blocks/3,
         mine_micro_blocks/2,
         mine_micro_blocks/3,
         get_key_hash_by_delta/2,
         wait_for_tx_in_pool/2,
         wait_for_tx_in_pool/3,
         wait_for_height/2,
         flush_new_blocks/0,
         spend/5,         %% (Node, FromPub, ToPub, Amount, Fee) -> ok
         sign_on_node/2,
         sign_on_node/3,
         forks/0,
         latest_fork_height/0,
         latest_protocol_version/0]).

-export([mock_mempool_nonce_offset/2,
         unmock_mempool_nonce_offset/1]).

-export([node_tuple/1,
         node_name/1,
         peer_info/1,
         connect/1,
         connect/2,
         subscribe/2,
         unsubscribe/2,
         events_since/3,
         all_events_since/2,
         check_for_logs/2,
         times_in_epoch_log/3,
         errors_in_logs/2]).

-export([proxy/0,
         start_proxy/0,
         call_proxy/2,
         await_aehttp/1,
         await_sync_complete/2,
         await_is_syncing/2,
         rpc/3,
         rpc/4,
         use_swagger/1,
         http_request/4,
         httpc_request/4,
         http_api_version/0,
         process_http_return/1,
         internal_address/0,
         external_address/0
        ]).

-export([generate_key_pair/0]).

-export([restart_jobs_server/1]).

-export([patron/0,
         sign_keys/0,
         sign_keys/1,
         meta_tx/4]).

%% Mocking helpers for tests
-export([start_mocks/2,
         start_mock/2,
         end_mocks/2,
         end_mock/2]).

-include_lib("kernel/include/file.hrl").
-include_lib("common_test/include/ct.hrl").

-define(OPS_BIN, "aeternity").
-define(DEFAULT_CUSTOM_EXPECTED_MINE_RATE, 100).
-define(DEFAULT_NODE, dev1).
-record(mock_def, { module     :: atom()
                  , init_fun   :: atom()
                  , finish_fun :: atom()}).

%% Keys for P2P communication
peer_keys() ->
    [{dev1, {<<120,30,108,92,13,32,45,162,66,181,135,13,102,186,226,7,134,64,127,57,44,122,62,198,148,18,128,51,162,218,180,97>>,
             <<128,38,224,217,226,249,89,153,69,120,34,192,93,224,163,234,105,76,186,215,58,166,69,75,31,103,31,243,148,225,253,127>>}}, %% pp_ySU7cHqsymnuBP9iSe4rMnH1Rz2FStx5rnoewYMJcuPhdaqPk
     {dev2, {<<112,66,119,236,84,180,214,104,63,254,231,93,110,189,200,155,126,48,77,78,163,89,198,71,59,16,145,112,73,249,93,91>>,
             <<137,121,210,193,164,178,71,99,63,76,25,128,199,153,210,37,125,233,17,162,151,39,188,155,185,197,70,250,93,44,83,52>>}}, %% pp_23YdvfRPQ1b1AMWmkKZUGk2cQLqygQp55FzDWZSEUicPjhxtp5
     {dev3, {<<192,145,22,50,217,175,73,12,42,218,16,92,216,240,151,252,189,80,190,47,62,203,178,89,230,75,253,78,114,65,96,78>>,
             <<177,115,250,203,226,39,102,92,8,182,166,254,125,117,140,134,199,149,211,182,184,107,119,43,218,70,251,60,10,56,12,53>>}} %% pp_2M9oPohzsWgJrBBCFeYi3PVT4YF7F2botBtq6J1EGcVkiutx3R
    ].

%% Keys for signing / verification
sign_keys() ->
     [{dev1, {<<238,121,108,68,47,65,15,139,26,172,250,135,122,63,231,52,188,121,206,144,200,39,37,112,172,29,216,205,172,56,241,4,217,202,108,173,192,99,
               13,10,129,124,71,86,232,121,148,177,243,254,160,88,174,204,22,114,15,42,51,71,75,19,135,16>>,
             <<217,202,108,173,192,99,13,10,129,124,71,86,232,121,148,177,243,254,160,88,174,204,22,114,15,42,51,71,75,19,135,16>>}},
     {dev2, {<<133,191,59,166,119,215,123,78,192,54,29,91,247,72,123,72,245,85,161,97,70,225,58,34,166,141,6,63,193,79,58,65,40,25,191,50,209,111,19,239,
               98,126,125,211,15,133,93,12,13,125,167,137,94,138,27,55,23,50,106,33,28,222,180,102>>,
             <<40,25,191,50,209,111,19,239,98,126,125,211,15,133,93,12,13,125,167,137,94,138,27,55,23,50,106,33,28,222,180,102>>}},
     {dev3, {<<238,230,20,172,221,171,100,208,126,164,204,120,180,48,69,184,235,69,115,91,190,182,78,22,50,182,78,251,154,80,216,250,207,253,207,144,121,
               89,70,193,75,247,195,248,104,132,11,199,133,103,156,209,167,244,82,126,86,51,156,36,165,214,45,50>>,
             <<207,253,207,144,121,89,70,193,75,247,195,248,104,132,11,199,133,103,156,209,167,244,82,126,86,51,156,36,165,214,45,50>>}}].

sign_keys(Node) ->
    {_, {Priv, Pub}} = lists:keyfind(Node, 1, sign_keys()),
    {Priv, Pub}.

patron() ->
    #{ pubkey  => <<206,167,173,228,112,201,249,157,157,78,64,8,128,168,111,29,
                    73,187,68,75,98,241,26,158,187,100,187,207,235,115,254,243>>, %% ak_2a1j2Mk9YSmC1gioUq4PWRm3bsv887MbuRVwyv4KaUGoR1eiKi
       privkey => <<230,169,29,99,60,119,207,87,113,50,157,51,84,179,188,239,27,
                    197,224,50,196,61,112,182,211,90,249,35,206,30,183,77,206,
                    167,173,228,112,201,249,157,157,78,64,8,128,168,111,29,73,
                    187,68,75,98,241,26,158,187,100,187,207,235,115,254,243>>
      }.

-spec known_mocks() -> #{atom() => #mock_def{}}.
known_mocks() -> #{}.

%%%=============================================================================
%%% API
%%%=============================================================================

init_per_suite(NodesList, CTConfig) ->
    init_per_suite(NodesList, #{}, CTConfig).

init_per_suite(NodesList, CustomNodeConfig, CTConfig) ->
    init_per_suite(NodesList, CustomNodeConfig, [], CTConfig).

init_per_suite(NodesList, CustomNodeCfg, NodeCfgOpts, CTConfig) ->
    DataDir = ?config(data_dir, CTConfig),
    TopDir = top_dir(DataDir),
    CTConfig1 = [{top_dir, TopDir} | CTConfig],
    make_shortcut(CTConfig1),
    ct:log("Environment = ~p", [[{args, init:get_arguments()},
                                 {node, node()},
                                 {cookie, erlang:get_cookie()}]]),
    create_configs(NodesList, CTConfig1, CustomNodeCfg, NodeCfgOpts),
    make_multi(CTConfig1, NodesList),
    CTConfig1.

node_config(Node, CTConfig) ->
    NodeConfig = node_config_dir(Node, CTConfig),
    [OrigCfg] = jsx:consult(NodeConfig, [return_maps]),
    backup_config(NodeConfig),
    OrigCfg.

create_configs(NodesList, CTConfig, CustomConfig, Options) ->
    [create_config(N, CTConfig, CustomConfig, Options) || N <- NodesList].

create_config(Node, CTConfig, CustomConfig, Options) ->
    DbBackendConfig = case os:getenv("AETERNITY_TESTCONFIG_DB_BACKEND") of
        false ->
            ct:fail("The mandatory environment variable is not set: AETERNITY_TESTCONFIG_DB_BACKEND");
        Backend ->
            #{<<"chain">> => #{<<"db_backend">> => binary:list_to_bin(Backend)}}
    end,
    NodeCfgPath = node_config_dir(Node, CTConfig),
    ok = filelib:ensure_dir(NodeCfgPath),
    MergedCfg = maps_merge(default_config(Node, CTConfig), CustomConfig),
    MergedCfg1 = aec_metrics_test_utils:maybe_set_statsd_port_in_user_config(Node, MergedCfg, CTConfig),
    MergedCfg2 = maps_merge(MergedCfg1, DbBackendConfig),
    MergedCfg3 = case proplists:get_value(instant_mining, CTConfig) of
                     undefined ->
                         ct:log("Instant mining consensus disabled in node"),
                         MergedCfg2;
                     _ ->
                         ct:log("Instant mining consensus enabled in node"),
                         maps_merge(MergedCfg2,
                             #{<<"chain">> =>
                                #{<<"consensus">> =>
                                    #{
                                        <<"0">> =>
                                            #{
                                                <<"name">> => <<"ct_tests">>
                                             }
                                    }
                                 }
                              })
                 end,
    Config = config_apply_options(Node, MergedCfg3, Options),
    write_keys(Node, Config),
    write_config(NodeCfgPath, Config).

maps_merge(V1, V2) when not is_map(V1); not is_map(V2) ->
    V2;
maps_merge(Map1, Map2) ->
    lists:foldl(fun({K, V}, Map) ->
                    case maps:is_key(K, Map) of
                        false -> Map#{K => V};
                        true  -> Map#{K => maps_merge(V, maps:get(K, Map))}
                    end
                end, Map2, maps:to_list(Map1)).

make_multi(Config, NodesList) ->
    make_multi(Config, NodesList, "test").

make_multi(Config, NodesList, RefRebarProfile) ->
    ct:log("RefRebarProfile = ~p", [RefRebarProfile]),
    Top = ?config(top_dir, Config),
    ct:log("Top = ~p", [Top]),
    Root = filename:join(Top, "_build/" ++ RefRebarProfile ++ "/rel/aeternity"),
    [setup_node(N, Top, Root, Config) || N <- NodesList].

make_shortcut(Config) ->
    PrivDir  = priv_dir(Config),
    ok = filelib:ensure_dir(filename:join(PrivDir, "foo")),
    Shortcut = shortcut_dir(Config),
    delete_file(Shortcut),
    ok = symlink(PrivDir, Shortcut).

start_node(N, Config) ->
    start_node(N, Config, []).

start_node(N, Config, ExtraEnv) ->
    MyDir = filename:dirname(code:which(?MODULE)),
    ConfigFilename = proplists:get_value(config_name, Config, "default"),
    Flags = ["-pa ", MyDir, " -config ./" ++ ConfigFilename],
    Env0 = [
            {"ERL_FLAGS", Flags},
            {"AETERNITY_CONFIG", "data/aeternity.json"},
            {"RUNNER_LOG_DIR","log"},
            {"CODE_LOADING_MODE", "interactive"}
           ],
    Env = maybe_override(ExtraEnv, Env0),
    cmd(?OPS_BIN, node_shortcut(N, Config), "bin", ["daemon"], Env).

maybe_override([{K,_} = H|T], L0) ->
    [H | maybe_override(T, lists:keydelete(K, 1, L0))];
maybe_override([], L0) ->
    L0.

stop_node(N, _Config) ->
    ct:log("Stopping node ~p", [N]),
    Node = node_name(N),
    monitor_node(Node, true),
    case rpc:call(Node, init, stop, []) of
        ok ->
            ct:log("Stop request to node ~p was sent succesfully", [N]),
            receive
                {nodedown, Node} ->
                    ct:log("Node ~p stopped", [N]),
                    ok
            after 30000 ->
                error(stop_failed)
            end;
        {badrpc, nodedown} ->
            ct:log("Not stopping node ~p as it's stopped", [N])
    end.

reinit_with_bitcoin_ng(N) ->
    ct:log("Reinitializing chain on ~p with bitcoin ng consensus", [N]),
    Node = node_name(N),
    ok = set_env(Node, aecore, consensus, #{<<"0">> => #{<<"name">> => <<"pow_cuckoo">>}}),
    ok = rpc:call(Node, aec_conductor, reinit_chain, []).

reinit_with_ct_consensus(N) ->
    ct:log("Reinitializing chain on ~p with ct_tests consensus", [N]),
    Node = node_name(N),
    ok = set_env(Node, aecore, consensus, #{<<"0">> => #{<<"name">> => <<"ct_tests">>}}),
    ok = rpc:call(Node, aec_conductor, reinit_chain, []).

get_node_db_config(Rpc) when is_function(Rpc, 3) ->
    IsDbPersisted = Rpc(application, get_env, [aecore, persist, false]),
    MaybeMnesiaDir =
        case Rpc(application, get_env, [mnesia, dir]) of
            undefined -> undefined;
            {ok, MnesiaDir0} ->
                {ok, Rpc(filename, absname, [MnesiaDir0])}
        end,
    ct:log("Is DB persisted? ~p. What is Mnesia dir if any? ~p",
           [IsDbPersisted, MaybeMnesiaDir]),
    {ok, {IsDbPersisted, MaybeMnesiaDir}}.

delete_node_db_if_persisted({false, undefined}) ->
    ok;
delete_node_db_if_persisted({true, {ok, MnesiaDir}}) ->
    ct:log("Deleting Mnesia Dir ~p", [MnesiaDir]),
    {true, _} = {filelib:is_file(MnesiaDir), MnesiaDir},
    {true, _} = {filelib:is_dir(MnesiaDir), MnesiaDir},
    cmd("rm", ".", ".", ["-r", MnesiaDir], [], false),
    {false, _} = {filelib:is_file(MnesiaDir), MnesiaDir},
    ok.

rpc_test_consensus_enabled(Node) ->
    aec_consensus_common_tests =:= rpc:call(Node, aec_conductor, get_active_consensus_module, []).

rpc_consensus_request(Node, Request) ->
    rpc:call(Node, aec_conductor, consensus_request, [Request]).

expected_mine_rate() ->
    ?DEFAULT_CUSTOM_EXPECTED_MINE_RATE.

mine_key_blocks(Node, NumBlocksToMine) ->
    mine_key_blocks(Node, NumBlocksToMine, #{}).

mine_key_blocks(Node, NumBlocksToMine, Opts) ->
    mine_blocks(Node, NumBlocksToMine, ?DEFAULT_CUSTOM_EXPECTED_MINE_RATE, key, Opts).

mine_micro_blocks(Node, NumBlocksToMine) ->
    mine_micro_blocks(Node, NumBlocksToMine, #{}).

mine_micro_blocks(Node, NumBlocksToMine, Opts) ->
    mine_blocks(Node, NumBlocksToMine, ?DEFAULT_CUSTOM_EXPECTED_MINE_RATE, micro, Opts).

mine_blocks(Node, NumBlocksToMine) ->
    mine_blocks(Node, NumBlocksToMine, #{}).

mine_blocks(Node, NumBlocksToMine, Opts) when is_map(Opts) ->
    mine_blocks(Node, NumBlocksToMine, ?DEFAULT_CUSTOM_EXPECTED_MINE_RATE, any, Opts).

mine_blocks(Node, NumBlocksToMine, MiningRate, Opts) ->
    mine_blocks(Node, NumBlocksToMine, MiningRate, any, Opts).

mine_blocks(Node, NumBlocksToMine, MiningRate, Type, Opts) ->
    case rpc_test_consensus_enabled(Node) of
        true ->
            rpc_consensus_request(Node, {mine_blocks, NumBlocksToMine, Type});
        false ->
            Fun = fun() ->
                mine_blocks_loop(NumBlocksToMine, Type)
            end,
            mine_safe_setup(Node, MiningRate, Opts, Fun)
    end.

mine_all_txs(Node, MaxBlocks) ->
    case rpc:call(Node, aec_tx_pool, peek, [infinity]) of
        {ok, []} -> {ok, []};
        {ok, Txs} ->
            TxsHs = [ aeser_api_encoder:encode(tx_hash, aetx_sign:hash(T)) || T <- Txs],
            mine_blocks_until_txs_on_chain(Node, TxsHs, MaxBlocks)
    end.

wait_for_tx_in_pool(Node, Tx) ->
    wait_for_tx_in_pool(Node, Tx, 5000).

wait_for_tx_in_pool(Node, SignedTx, Timeout) ->
    true = rpc:call(Node, aec_events, subscribe , [tx_created]),
    true = rpc:call(Node, aec_events, subscribe , [tx_received]),
    Hash = aetx_sign:hash(SignedTx),
    case rpc:call(Node, aec_chain, find_tx_location, [Hash]) of
        mempool -> ok;
        B when is_binary(B) -> error({already_on_chain, SignedTx});
        none -> error({already_gc, SignedTx});
        not_found ->
            receive
                {gproc_ps_event, tx_received, #{info := SignedTx}} -> ok;
                {gproc_ps_event, tx_created, #{info :=SignedTx}} -> ok
            after
                Timeout ->
                    ct:log("timeout waiting for transaction ~p~n"
                            "~p", [SignedTx, process_info(self(), messages)]),
                    error({timeout_waiting_for_tx, SignedTx})
            end,
            rpc:call(Node, aec_events, unsubscribe , [tx_created]),
            rpc:call(Node, aec_events, unsubscribe , [tx_received])
    end.

mine_blocks_until_txs_on_chain(Node, TxHashes, MaxBlocks) ->
    mine_blocks_until_txs_on_chain(Node, TxHashes, ?DEFAULT_CUSTOM_EXPECTED_MINE_RATE, MaxBlocks).

mine_blocks_until_txs_on_chain(Node, TxHashes, MiningRate, Max) ->
    mine_blocks_until_txs_on_chain(Node, TxHashes, MiningRate, Max, #{}).

mine_blocks_until_txs_on_chain(Node, TxHashes, MiningRate, Max, Opts) ->
    %% Fail early rather than having to wait until max_reached if txs already on-chain
    ok = assert_not_already_on_chain(Node, TxHashes),
    case rpc_test_consensus_enabled(Node) of
        true ->
            rpc_consensus_request(Node, {mine_blocks_until_txs_on_chain, TxHashes, Max});
        false ->
            Fun = fun() ->
                mine_blocks_until_txs_on_chain_loop(Node, TxHashes, Max, [])
            end,
            mine_safe_setup(Node, MiningRate, Opts, Fun)
    end.

mine_micro_block_emptying_mempool_or_fail(Node) ->
    case rpc_test_consensus_enabled(Node) of
        true ->
            rpc_consensus_request(Node, mine_micro_block_emptying_mempool_or_fail);
        false ->
            Fun = fun() ->
                      mine_blocks_loop(2, any)
                  end,
            {ok, Blocks} = mine_safe_setup(Node, expected_mine_rate(), #{}, Fun),
            [key, micro] = [aec_blocks:type(B) || B <- Blocks],

            case rpc:call(Node, aec_tx_pool, peek, [infinity]) of
                {ok, []} ->
                    {ok, Blocks};
                {ok, [_|_]} ->
                    %% So, Tx(s) is/are back in the mempool, this means (unless some Txs arrived
                    %% from thin air) that we had a micro-fork. Let's check what state we stopped in
                    {ok, NewBlocks} = mine_safe_setup(Node, expected_mine_rate(), #{}, Fun),
                    [key, micro] = [aec_blocks:type(B) || B <- NewBlocks],
                    {ok, NewBlocks}
            end
    end.

assert_not_already_on_chain(Node, TxHashes) ->
    Lookup = lists:map(
               fun(TxHash) ->
                       {TxHash, rpc:call(Node, aec_chain, find_tx_location, [TxHash])}
               end, TxHashes),
    case [T || {T, W} <- Lookup, is_binary(W)] of
        [] ->
            ok;
        [_|_] = AlreadyOnChain ->
            error({already_on_chain, AlreadyOnChain})
    end.

mine_blocks_until_txs_on_chain_loop(_Node, _TxHashes, 0, _Acc) ->
    {error, max_reached};
mine_blocks_until_txs_on_chain_loop(Node, TxHashes, Max, Acc) ->
    case mine_blocks_loop(1, key) of
        {ok, [Block]} -> %% We are only observing key blocks
            NewAcc = [Block | Acc],
            case txs_not_on_chain(Node, Block, TxHashes) of
                []        -> {ok, NewAcc};
                TxHashes1 -> mine_blocks_until_txs_on_chain_loop(Node, TxHashes1, Max - 1, NewAcc)
            end;
        {error, _} = Error -> Error
    end.

txs_not_on_chain(Node, Block, TxHashes) ->
    {ok, BlockHash} = aec_blocks:hash_internal_representation(Block),
    case rpc:call(Node, aec_chain, get_generation_by_hash, [BlockHash, backward]) of
        error -> TxHashes;
        {ok, #{micro_blocks := MBs }} -> txs_not_in_generation(MBs, TxHashes)
    end.

txs_not_in_generation([], TxHashes) -> TxHashes;
txs_not_in_generation([MB | MBs], TxHashes) ->
    txs_not_in_generation(MBs, txs_not_in_microblock(MB, TxHashes)).

txs_not_in_microblock(MB, TxHashes) ->
    [ TxHash || TxHash <- TxHashes, not tx_in_microblock(MB, TxHash) ].

tx_in_microblock(MB, TxHash) ->
    lists:any(fun(STx) ->
                      aeser_api_encoder:encode(tx_hash, aetx_sign:hash(STx)) == TxHash
              end, aec_blocks:txs(MB)).

mine_blocks_loop(Cnt, Type) ->
    mine_blocks_loop([], Cnt, Type).

mine_blocks_loop(Blocks, 0, _Type) ->
    {ok, Blocks};
mine_blocks_loop(Blocks, BlocksToMine, Type) when is_integer(BlocksToMine), BlocksToMine > 0 ->
    {ok, Block} = wait_for_new_block(),
    case aec_blocks:type(Block) of
        Type1 when Type =/= any andalso Type =/= Type1 ->
            %% Don't decrement
            mine_blocks_loop(Blocks, BlocksToMine, Type);
        _ ->
            mine_blocks_loop([Block | Blocks], BlocksToMine - 1, Type)
    end.

wait_for_new_block() ->
    wait_for_new_block(30000).

wait_for_new_block(T) when is_integer(T), T >= 0 ->
    receive
        {gproc_ps_event, block_created, Info} ->
            #{info := Block} = Info,
            {ok, Block};
        {gproc_ps_event, micro_block_created, Info} ->
            ct:log("micro block created, Info=~p", [Info]),
            #{info := Block} = Info,
            {ok, Block}
    after
        T ->
            case T of
                0 ->
                    not_logging;
                _ ->
                    ct:log("timeout waiting for block event~n"
                           "~p", [process_info(self(), messages)])
            end,
            {error, timeout_waiting_for_block}
    end.

flush_new_blocks() ->
    flush_new_blocks_([]).

flush_new_blocks_(Acc) ->
    case wait_for_new_block(0) of
        {error, timeout_waiting_for_block} ->
            lists:reverse(Acc);
        {ok, Block} ->
            flush_new_blocks_([Block | Acc])
    end.

%% block the process until a certain height is reached
%% this has the expectation that the Node is mining
%% there is a timeout of 30 seconds for a single block to be produced
wait_for_height(Node, Height) ->
    flush_new_blocks(),
    subscribe(Node, block_created),
    subscribe(Node, micro_block_created),
    wait_for_height_(Node, Height),
    unsubscribe(Node, block_created),
    unsubscribe(Node, micro_block_created).

wait_for_height_(Node, Height) ->
    TopHeight =
        case rpc:call(Node, aec_chain, top_header, []) of
            undefined -> 0;
            Header -> aec_headers:height(Header)
        end,
    case TopHeight >= Height of
        true -> % reached height
            ok;
        false ->
            _ = wait_for_new_block(),
            wait_for_height_(Node, Height)
    end.

spend(Node, FromPub, ToPub, Amount, Fee) ->
    {ok, Nonce} = rpc:call(Node, aec_next_nonce, pick_for_account, [FromPub]),
    Params = #{sender_id    => aeser_id:create(account, FromPub),
               recipient_id => aeser_id:create(account, ToPub),
               amount       => Amount,
               fee          => Fee,
               nonce        => Nonce,
               payload      => <<"foo">>},

    {ok, Tx} = rpc:call(Node, aec_spend_tx, new, [Params]),
    {ok, SignedTx} = sign_on_node({dev1, Node}, Tx),
    ok = rpc:call(Node, aec_tx_pool, push, [SignedTx]),
    {ok, SignedTx}.

sign_on_node(Id, Tx) ->
    sign_on_node(Id, Tx, false).

sign_on_node({Id, _Node}, Tx, SignHash) ->
    {_, {SignPrivKey, _}} = lists:keyfind(Id, 1, sign_keys()),
    {ok, aec_test_utils:sign_tx(Tx, SignPrivKey, SignHash)};
sign_on_node(Id, Tx, SignHash) ->
    sign_on_node(node_tuple(Id), Tx, SignHash).

forks() ->
    Vs = aec_hard_forks:sorted_protocol_versions(),
    Hs = lists:seq(0, (length(Vs) - 1)),
    maps:from_list(lists:zip(Vs, Hs)).

latest_fork_height() ->
    lists:max(maps:values(forks())).

latest_protocol_version() ->
    lists:max(maps:keys(aec_hard_forks:protocols())).

mock_mempool_nonce_offset(Node, Offset) ->
    ok = set_env(Node, aecore, mempool_nonce_offset, Offset).

unmock_mempool_nonce_offset(Node) ->
    ok = unset_env(Node, aecore, mempool_nonce_offset).


top_dir(DataDir) ->
    %% Split the DataDir path at "_build"
    [Top, _] = re:split(DataDir, "_build", [{return, list}]),
    Top.

node_tuple(N) when N == dev1; N == dev2; N == dev3 ->
    {N, node_name(N)}.

node_name(N) when N == dev1; N == dev2; N == dev3 ->
    [_,H] = re:split(atom_to_list(node()), "@", [{return,list}]),
    list_to_atom("aeternity_" ++ atom_to_list(N) ++ "@" ++ H).

-spec connect(atom(), list(atom()) | all_mocks) -> ok.
connect(N, all_mocks) ->
    Mocks = maps:keys(known_mocks()),
    connect(N, Mocks);
connect(N, Mocks) when is_list(Mocks) ->
    ok = connect(N),
    start_mocks(N, Mocks),
    ok.

-spec connect(atom()) -> ok.
connect(N) ->
    connect_(N, 50),
    report_node_config(N),
    ok.

subscribe(N, Event) ->
    call_proxy(N, {subscribe, Event}).

unsubscribe(N, Event) ->
    ok = call_proxy(N, {unsubscribe, Event}),
    flush_events(N, Event).

flush_events(N, Event) ->
    receive
        {app_started, #{test_node := N}} when Event == app_started ->
            flush_events(N, Event);
        {gproc_ps_event, Event, #{sender := From}} when node(From) == N ->
            flush_events(N, Event)
    after 0 ->
            ok
    end.

all_events_since(N, TS) ->
    [{E, try events_since(N, E, TS) catch error:Err -> Err end}
     || E <- [block_created, micro_block_created, chain_sync, app_started]].

events_since(N, EvType, TS) ->
    call_proxy(N, {events, EvType, TS}).

check_for_logs(Nodes, Config) ->
    [] = [{N, F} || N <- Nodes,
                    F <- expected_logs(),
                    is_missing_log(N, F, Config)],
    ok.

is_missing_log(N, F, Config) ->
    LogDir = log_dir(N, Config),
    file_missing(filename:join(LogDir, F)).

file_missing(F) ->
    case file:read_link_info(F) of
        {ok, _} ->
            false;
        _ ->
            true
    end.

errors_in_logs(Nodes, Config) ->
    [{N, Errs} || N <- Nodes,
                  Errs <- check_errors_logs(N, Config)].

check_errors_logs(Node, Config) ->
    LogDir = log_dir(Node, Config),
    [{F, Errs} || F <- expected_logs(),
                  Errs <- grep_error(filename:join(LogDir, F))].

grep_error(FileName) ->
    {ok, Bin} = file:read_file(FileName),
    Entries = string:lexemes(Bin, [$\r,$\n]),
    [ Entry || Entry <- Entries,
               string:find(Entry, "[error]") =/= nomatch ].

times_in_epoch_log(Node, Config, Str) ->
    LogFile = filename:join(log_dir(Node, Config), "aeternity.log"),
    ct:log("Reading logfile ~p", [LogFile]),
    {ok, Bin} = file:read_file(LogFile),
    Entries = string:lexemes(Bin, [$\r,$\n]),
    [ Entry || Entry <- Entries,
               string:find(Entry, Str) =/= nomatch ].

expected_logs() ->
    ["aeternity.log", "aeternity_mining.log", "aeternity_sync.log",
     "aeternity_pow_cuckoo.log", "aeternity_metrics.log"].

await_sync_complete(T0, Nodes) ->
    [ok = subscribe(N, chain_sync) || N <- Nodes],
    AllEvents = events_since_on_nodes(chain_sync, T0, Nodes),
    ct:log("AllEvents = ~p", [AllEvents]),
    SyncNodes =
        lists:foldl(
          fun(Msg, Acc) ->
                  check_event(Msg, Acc)
          end, Nodes, AllEvents),
    ct:log("SyncNodes = ~p", [SyncNodes]),
    ct:log("Messages = ~p", [process_info(self(), messages)]),
    Res = collect_sync_events(SyncNodes, 100),
    [ok = unsubscribe(N, chain_sync) || N <- Nodes],
    Res.

await_is_syncing(T0, Nodes) ->
    [ok = subscribe(N, chain_sync) || N <- Nodes],
    AllEvents = events_since_on_nodes(chain_sync, T0, Nodes),
    ct:log("AllEvents = ~p", [AllEvents]),
    {Sofar, RestNodes} =
        lists:foldl(
          fun(#{sender := From, info := {is_syncing, Flag}, time := Te}, {Found, Ns} = Acc) ->
                  Node = node(From),
                  case lists:member(Node, Ns) of
                      true ->
                          {[{Node, Flag, Te}|Found], Ns -- [Node]};
                      false ->
                          Acc
                  end;
             (_, Acc) ->
                  Acc
          end, {[], Nodes}, AllEvents),
    [ok = unsubscribe(N, chain_sync) || {N,_,_} <- Sofar],
    Res = collect_is_syncing(RestNodes, Sofar),
    [ok = unsubscribe(N, chain_sync) || N <- RestNodes],
    %% Ensure same order as in the Nodes list
    [{_,_,_} = lists:keyfind(N, 1, Res) || N <- Nodes].

events_since_on_nodes(Event, T0, Nodes) ->
    lists:flatten(
      [events_since(N, Event, T0) || N <- Nodes]
     ).

collect_sync_events(_, 0) -> error(retry_exhausted);
collect_sync_events([], _) -> done;
collect_sync_events(SyncNodes, N) ->
    receive
        {gproc_ps_event, chain_sync, #{info := {chain_sync_done, _}} = Msg} ->
            ct:log("chain_sync event: ~p", [Msg]),
            SyncNodes1 = check_event(Msg, SyncNodes),
            collect_sync_events(SyncNodes1, N-1)
    after 20000 ->
            ct:log("Timeout in collect_sync_events: ~p~n"
                   "~p", [SyncNodes, process_info(self(), messages)]),
            error(timeout)
    end.

collect_is_syncing(Nodes, Acc) ->
    TRef = erlang:start_timer(10000, self(), is_syncing),
    collect_is_syncing(Nodes, TRef, Acc).

collect_is_syncing([], TRef, Acc) ->
    erlang:cancel_timer(TRef),
    Acc;
collect_is_syncing([N|Ns], TRef, Acc) ->
    receive
        {timeout, TRef, _} ->
            error(timeout);
        {gproc_ps_event, chain_sync, #{ sender := From
                                      , info := {is_syncing, Flag}
                                      , time := Te }} when node(From) == N ->
            collect_is_syncing(Ns, TRef, [{N, Flag, Te}|Acc])
    end.

check_event(#{sender := From, info := Info}, Nodes) ->
    case Info of
        {chain_sync_done, _} ->
            lists:delete(node(From), Nodes);
        _ ->
            Nodes
    end.

restart_jobs_server(N) ->
    JobsP = rpc:call(N, erlang, whereis, [jobs_server]),
    true = rpc:call(N, erlang, exit, [JobsP, kill]),
    await_new_jobs_pid(N, JobsP).

delete_file(F) ->
    case file:delete(F) of
        ok -> ok;
        {error, enoent} -> ok;
	 {error, Err} ->
            case {os:type(), Err} of
                {{win32, _}, eperm} ->
                    win32_delete_junction(F);
		 _ ->
            		ct:fail("Could not delete file ~s: ~p~n", [F, Err])
	    end
    end.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

connect_(N, Timeout) when Timeout < 10000 ->
    timer:sleep(Timeout),
    case net_kernel:hidden_connect_node(N) of
        true ->
            ct:log("hidden_connect_node(~p) -> true", [N]),
            await_aehttp(N),
            true;
        false ->
            ct:log("hidden_connect_node(~p) -> false, retrying ...", [N]),
            connect_(N, Timeout * 2)
    end;
connect_(N, _) ->
    ct:log("exhausted retries (~p)", [N]),
    erlang:error({could_not_connect, N}).

report_node_config(N) ->
    [ct:log("~w env: ~p", [A, rpc:call(N, application, get_all_env, [A], 2000)]) ||
        A <- [aeutil, aecore, aehttp]].

start_mocks(N, Mocks) ->
    ct:log("Enabling mocks: ~p for node ~p", [Mocks, N]),
    lists:foreach(fun(Mock) -> start_mock(N, Mock) end, Mocks).

start_mock(N, Mock) ->
    #mock_def{module = Module, init_fun = InitF} = maps:get(Mock, known_mocks()),
    rpc:call(N, Module, InitF, [], 2000).

end_mocks(N, Mocks) ->
    lists:foreach(fun(Mock) -> end_mock(N, Mock) end, Mocks).

end_mock(N, Mock) ->
    #mock_def{module = Module, finish_fun = FinishF} = maps:get(Mock, known_mocks()),
    rpc:call(N, Module, FinishF, [], 2000).

await_aehttp(N) ->
    subscribe(N, app_started),
    Events = events_since(N, app_started, 0),
    ct:log("`app_started` Events since 0: ~p", [Events]),
    case [true || #{info := aehttp} <- Events] of
        [] ->
            receive
                {app_started, #{info := aehttp}} ->
                    ct:log("aehttp started", []),
                    ok
            after 30000 ->
                    error(timeout_waiting_for_aehttp)
            end;
        [_|_] ->
            ct:log("aehttp already started", []),
            ok
    end,
    unsubscribe(N, app_started),
    ok.

setup_node(N, Top, Root, Config) ->
    ct:log("setup_node(~p,Config)", [N]),
    DDir = node_shortcut(N, Config),
    filelib:ensure_dir(filename:join(DDir, "foo")),
    cp_dir(filename:join(Root, "releases"), DDir ++ "/"),
    cp_dir(filename:join(Root, "bin"), DDir ++ "/"),
    symlink(filename:join(Root, "lib"), filename:join(DDir, "lib")),
    symlink(filename:join(Root, "patches"), filename:join(DDir, "patches"), true),
    {ok, VerContents} = file:read_file(filename:join(Root, "VERSION")),
    [VerB |_ ] = binary:split(VerContents, [<<"\n">>, <<"\r">>], [global]),
    Version = binary_to_list(VerB),
    %%
    CfgD = filename:join([Top, "config/", N]),
    RelD = filename:dirname(filename:join([DDir, "releases", Version, "aeternity.rel"])),
    [cp_file(filename:join(CfgD, F), filename:join(RelD, F)) || F <- ["vm.args", "sys.config"]],
    [cp_file(filename:join(Root, F), filename:join(DDir, F)) || F <- ["VERSION", "REVISION"]],
    delete_file(filename:join(RelD, "vm.args.orig")),
    delete_file(filename:join(RelD, "sys.config.orig")),
    TestsDir = filename:dirname(code:which(?MODULE)),
    TestD = filename:join(TestsDir, "data"),
    ConfigFilename = proplists:get_value(config_name, Config, "default") ++ ".config",
    cp_file(filename:join(TestD, ConfigFilename),
            filename:join(DDir , ConfigFilename)),
    aec_test_utils:copy_forks_dir(Root, DDir).


cp_dir(From, To) ->
    ToDir = case lists:last(To) of
                $/ ->
                    filename:join(To, filename:basename(From));
                _ ->
                    To
            end,
    ok = filelib:ensure_dir(filename:join(ToDir, "foo")),
    cp_dir(file:list_dir(From), From, ToDir).

cp_dir({ok, Fs}, From, To) ->
    ct:log("cp_dir({ok, ~p}, ~p, ~p)", [Fs, From, To]),
    Res =
        lists:foldl(
            fun(F, Acc) ->
                FullF = filename:join(From, F),
                case filelib:is_dir(FullF) of
                    true ->
                        To1 = filename:join(To, F),
                        cp_dir(FullF, To1),
                        [FullF|Acc];
                    false ->
                        Tgt = filename:join(To, F),
                        ok = filelib:ensure_dir(Tgt),
                        ok = file_copy(FullF, Tgt),
                        ok = match_mode(FullF, Tgt),
                        [FullF|Acc]
                end
            end, [], Fs),
    ct:log("cp_dir(~p, ~p) -> ~p", [From, To, Res]),
    ok;
cp_dir({error, _} = Error, From, To) ->
    ct:log("cp_dir(~p, ~p) -> ~p", [From, To, Error]),
    Error.

file_copy(From, To) ->
    case file:copy(From, To) of
        {ok, _} ->
            ok;
        Other ->
            ct:log("ERROR in file:copy(~p, ~p):~n   ~p", [From, To, Other]),
            error(Other, [From, To])
    end.

match_mode(A, B) ->
    case {file:read_link_info(A), file:read_file_info(B)} of
        {{ok, #file_info{mode = M}}, {ok, FI}} ->
            file:write_file_info(B, FI#file_info{mode = M});
        Other ->
            ct:log("Error matching mode ~p -> ~p: ~p", [A, B, Other]),
            {error, {match_mode, {A, B}, Other}}
    end.

cp_file(From, To) ->
    case file:copy(From, To) of
        {ok, _} ->
            ct:log("Copied ~s to ~s", [From, To]);
        Err ->
            ct:fail("Error copying ~s to ~s: ~p", [From, To, Err])
    end,
    ok.

symlink(From, To) ->
    symlink(From, To, false).
symlink(From, To, CanFail) ->
    case {symlink_or_copy(From, To), CanFail} of
        {ok, _} ->
            ct:log("symlinked ~s to ~s", [From, To]);
        {Err, false} ->
            ct:fail("Error symlinking ~s to ~s: ~p", [From, To, Err]);
        {Err, true} ->
            ct:log("Error symlinking ~s to ~s: ~p", [From, To, Err])
    end,
    ok.

cmd(Cmd, Dir, Args) ->
    cmd(Cmd, Dir, ".", Args, []).
cmd(Cmd, Dir, BinDir, Args) ->
    cmd(Cmd, Dir, BinDir, Args, []).
cmd(Cmd, Dir, BinDir, Args, Env) ->
    cmd(Cmd, Dir, BinDir, Args, Env, true).
cmd(C, Dir, BinDir, Args, Env, FindLocalBin) ->
    Cmd = binary_to_list(iolist_to_binary(C)),
    CmdRes = cmd_run(Cmd, Dir, BinDir, Args, Env, FindLocalBin),
    {Fmt, FmtArgs} =
        case cmd_res(CmdRes) of
            {0, Out} ->
                {"> ~s~n~s", [Cmd, Out]};
            {ErrCode, Out} ->
                {"> ~s~nERR ~p: ~s~n", [Cmd, ErrCode, Out]}
        end,
    ct:log(Fmt, FmtArgs),
    CmdRes.

cmd_run(Cmd, Dir, BinDir, Args, Env, FindLocalBin) ->
    %% On Windows we need to ensure that Erlang is available in the path.
    Env1 = case os:type() of
               {win32, _} ->
                   Path = filename:dirname(os:find_executable("erl")),
                   [{"PATH", Path ++ ";%PATH%"} | Env];
               _ ->
                   Env
           end,
    Opts = [
            {env, Env1},
            exit_status,
            overlapped_io,
            stderr_to_stdout,
            hide, %% will note spawn an extra window on win32 for the executed command
            {args, Args},
            {cd, Dir}
           ],
    ct:log("Running command ~p in ~p with ~p, opts ~p", [Cmd, Dir, Args, Opts]),
    Bin = case FindLocalBin of
              true ->
                  os:find_executable(Cmd, filename:join(Dir, BinDir));
              false ->
                  os:find_executable(Cmd)
          end,
    %% A bug in OTP requires us to copy the start script such that it has the extension .bat
    Bin1 = case {os:type(), filename:extension(Bin)} of
               {{win32, _}, ".cmd"} ->
                   NewBin = filename:rootname(Bin) ++ ".bat",
                   ok = symlink(Bin, NewBin),
                   NewBin;
               _ ->
                   Bin
    end,
    Port = erlang:open_port({spawn_executable, Bin1}, Opts),
    WaitFun = fun(Fun, P, Res) ->
                     receive
                         {P, {exit_status, 0}} ->
                             {ok, 0, Res};
                         {P, {exit_status, Err}} ->
                             {error, Err, Res};
                         {P, {data, Msg}} ->
                             Fun(Fun, P, Res ++ Msg);
                         AMsg ->
                             ct:log("Ignoring unrecognized message received: ~p", [AMsg]),
                             Fun(Fun, P, Res)
                     after 30000 -> {error, timeout, Res}
                     end
             end,
    WaitFun(WaitFun, Port, "").

cmd_res({_, Code, L}) ->
    {Code, L}.

set_env(Node, App, Key, Value) ->
    ok = rpc:call(Node, application, set_env, [App, Key, Value], 5000).

unset_env(Node, App, Key) ->
    ok = rpc:call(Node, application, unset_env, [App, Key], 5000).

config_apply_options(_Node, Cfg, []) ->
    Cfg;
config_apply_options(Node, Cfg, [{block_peers, BlockedPeers}| T]) ->
    Cfg1 = Cfg#{<<"blocked_peers">> => [peer_info(P) || P <- BlockedPeers]},
    config_apply_options(Node, Cfg1, T);
config_apply_options(Node, Cfg, [{trusted_peers, Peers}| T]) ->
    Cfg1 = Cfg#{<<"peers">> => Peers},
    config_apply_options(Node, Cfg1, T);
config_apply_options(Node, Cfg, [{add_peers, true}| T]) ->
    Cfg1 = Cfg#{<<"peers">> =>
              [peer_info(N1) || N1 <- [dev1, dev2, dev3] -- [Node]]},
    config_apply_options(Node, Cfg1, T);
config_apply_options(Node, Cfg, [no_peers| T]) ->
    Cfg1 = maps:remove(<<"peers">>, Cfg),
    config_apply_options(Node, Cfg1, T);
config_apply_options(Node, Cfg, [OptNodesCfg | T]) when is_map(OptNodesCfg) ->
    Cfg1 = case OptNodesCfg of
               #{Node := OptNodeCfg} -> maps_merge(Cfg, OptNodeCfg);
               #{} -> Cfg
           end,
    config_apply_options(Node, Cfg1, T).


write_keys(Node, Config) ->
    #{ <<"keys">> := #{ <<"dir">> := Path, <<"peer_password">> := Pwd } } = Config,
    ok = filelib:ensure_dir(filename:join(Path, "foo")),
    ct:log("Writing peer keys to ~p (~p)", [Path, filelib:is_dir(Path)]),
    {Node, {PeerPrivKey, PeerPubKey}} = lists:keyfind(Node, 1, peer_keys()),
    ok = file:write_file(filename:join(Path, "peer_key.pub"), aec_keys:encrypt_key(Pwd, PeerPubKey)),
    ok = file:write_file(filename:join(Path, "peer_key"), aec_keys:encrypt_key(Pwd, PeerPrivKey)),
    ok.

write_config(F, Config) ->
    JSON = jsx:prettify(jsx:encode(Config)),
    {ok, Fd} = file:open(F, [write]),
    ct:log("Writing config (~p)~n~s", [F, JSON]),
    try io:fwrite(Fd, "~s~n", [JSON])
    after
        file:close(Fd)
    end,
    VRes = aeu_env:check_config(F),
    ct:log("Config (~p) check: ~p", [F, VRes]),
    {ok,_} = VRes.

default_config(N, Config) ->
    {A,B,C} = os:timestamp(),
    {N, {_PrivKey, PubKey}} = lists:keyfind(N, 1, sign_keys()),
    {ok, NetworkId} = application:get_env(aecore, network_id),
    #{<<"keys">> =>
          #{<<"dir">> => iolist_to_binary(keys_dir(N, Config)),
            <<"peer_password">> => iolist_to_binary(io_lib:format("~w.~w.~w", [A,B,C]))},
      <<"logging">> =>
          #{<<"hwm">> => 5000},
      <<"mining">> =>
          #{<<"autostart">> => false,
            <<"beneficiary">> => aeser_api_encoder:encode(account_pubkey, PubKey),
            <<"beneficiary_reward_delay">> => 2},
      <<"chain">> =>
          #{<<"persist">> => true},
      <<"fork_management">> =>
          #{<<"network_id">> => NetworkId},
      <<"include_default_peers">> => false
     }.

node_config_dir(N, Config) ->
    filename:join(data_dir(N, Config), "aeternity.json").

%% dirs
node_shortcut(N, Config) ->
    filename:join(shortcut_dir(Config), N).

shortcut_dir(Config) ->
    Top = ?config(top_dir, Config),
    SymlinkName = ?config(symlink_name, Config),
    filename:join([Top, "_build/test/logs", SymlinkName]).

priv_dir(Config) ->
    SubDir = atom_to_list(?config(test_module, Config)),
    filename:join(?config(priv_dir, Config), SubDir).

data_dir(N, Config) ->
    filename:join(node_shortcut(N, Config), "data").

log_dir(N, Config) ->
    filename:join(node_shortcut(N, Config), "log").

keys_dir(N, Config) ->
    filename:join(data_dir(N, Config), "keys").

%% Use localhost here, because some systems have both 127.0.0.1 and 127.0.1.1
%% defined, resulting in a conflict during testing
peer_info(N) ->
    list_to_binary(["aenode://", aeser_api_encoder:encode(peer_pubkey, pubkey(N)),
                  "@localhost:", integer_to_list(port_number(N))]).

port_number(dev1) -> 3015;
port_number(dev2) -> 3025;
port_number(dev3) -> 3035.

pubkey(N) ->
    {N, {_, PubKey}} = lists:keyfind(N, 1, peer_keys()),
    PubKey.

backup_config(NodeConfig) ->
    Dir = filename:dirname(NodeConfig),
    Ext = filename:extension(NodeConfig),
    Base = filename:basename(NodeConfig, Ext),
    {A,B,C} = os:timestamp(),
    BackupBase = lists:flatten(
                   [Base, "-",
                    integer_to_list(A),
                    "-",
                    integer_to_list(B),
                    "-",
                    integer_to_list(C),
                    Ext]),
    Backup = filename:join(Dir, BackupBase),
    ct:log("Back up ~p to ~p", [NodeConfig, Backup]),
    cp_file(NodeConfig, Backup).


%% ============================================================
%% Proxy process
%% ============================================================

-define(PROXY, aeternity_multi_node_test_proxy).
-define(PROXY_CALL_RETRIES, 50).

proxy() ->
    register(?PROXY, self()),
    process_flag(trap_exit, true),
    {ok, _} = aec_test_app_checker:start_link(self()),
    error_logger:info_msg("starting test suite proxy~n", []),
    proxy_loop([{marker, app_started}], dict:new()).

start_proxy() ->
    io:fwrite("starting proxy...~n", []),
    proc_lib:spawn(?MODULE, proxy, []).

proxy_loop(Subs, Events) ->
    receive
        {From, Ref, debug} ->
            From ! {Ref, #{pid => self(),
                           subs => Subs,
                           events => Events}},
            proxy_loop(Subs, Events);
        {From, Ref, {subscribe, Event}} ->
            case lists:keymember(Event, 2, Subs) of
                true ->
                    From ! {Ref, ok},
                    proxy_loop([{From, Event}|Subs], Events);
                false ->
                    case lists:member(Event, events()) of
                        true ->  % pre-subscribed
                            From ! {Ref, ok},
                            proxy_loop([{From, Event}|Subs], Events);
                        false ->
                            case catch aec_events:subscribe(Event) of
                                ok ->
                                    From ! {Ref, ok},
                                    proxy_loop(
                                      [{From, Event}|
                                       ensure_markers([Event], Subs)], Events);
                                Other ->
                                    From ! {Ref, Other},
                                    proxy_loop(Subs, Events)
                            end
                    end
            end;
        {From, Ref, {unsubscribe, Event}} ->
            From ! {Ref, ok},
            proxy_loop([S || S <- Subs,
                             S =/= {From, Event}], Events);
        {From, Ref, {events, E, Since}} ->
            Res = case dict:find(E, Events) of
                      error -> [];
                      {ok, Es} ->
                          %% exclude events before or AT Since
                          lists:dropwhile(
                            fun(#{time := T}) -> T =< Since end, Es)
                  end,
            From ! {Ref, Res},
            proxy_loop(Subs, Events);
        {gproc_ps_event, Event, Info0} ->
            Info = Info0#{test_node => node()}, % for easier debugging
            tell_subscribers(Subs, Event, {gproc_ps_event, Event, Info}),
            proxy_loop(Subs, dict:append(Event, Info, Events));
        {application_started, T, App} ->
            Info = #{time => T, info => App, test_node => node()},
            tell_subscribers(Subs, app_started, {app_started, Info}),
            Subs1 = case App of
                        gproc ->
                            Es = set_subscriptions(),
                            ensure_markers(Es, Subs);
                        _ -> Subs
                    end,
            proxy_loop(Subs1, dict:append(app_started, Info, Events));
        Other ->
            io:fwrite("Proxy got ~p~n", [Other]),
            proxy_loop(Subs, Events)
    end.

call_proxy(N, Req) ->
    call_proxy(N, Req, ?PROXY_CALL_RETRIES, 3000).

call_proxy(N, Req, Tries, Timeout) when Tries > 0 ->
    Ref = erlang:monitor(process, {?PROXY, N}),
    {?PROXY, N} ! {self(), Ref, Req},
    receive
        {'DOWN', Ref, _, _, noproc} ->
            ct:log("proxy not yet there, retrying in 0.1 sec...", []),
            receive
            after 100 ->
                    call_proxy(N, Req, Tries-1, Timeout)
            end;
        {'DOWN', Ref, _, _, Reason} ->
            error({proxy_died, N, Reason});
        {Ref, Result} ->
            erlang:demonitor(Ref),
            Result
    after Timeout ->
            error(proxy_call_timeout)
    end;
call_proxy(N, _, _, _) ->
    erlang:error({proxy_not_running, N}).

events() -> [block_created, micro_block_created, chain_sync, top_changed].

tell_subscribers(Subs, Event, Msg) ->
    lists:foreach(
      fun({P, E}) when E =:= Event, is_pid(P) ->
              P ! Msg;
         (_) ->
              ok
      end, Subs).

set_subscriptions() ->
    Es = events(),
    [aec_events:subscribe(E) || E <- Es],
    Es.

ensure_markers(Es, Subs) ->
    lists:foldl(
      fun(E, Acc) ->
              case lists:member({marker, E}, Acc) of
                  true ->
                      Acc;
                  false ->
                      [{marker, E}|Acc]
              end
      end, Subs, Es).

await_new_jobs_pid(N, OldP) ->
    TRef = erlang:start_timer(5000, self(), await_jobs_pid),
    await_new_jobs_pid(N, OldP, TRef).

await_new_jobs_pid(N, OldP, TRef) ->
    case rpc:call(N, erlang, whereis, [jobs_server]) of
        OldP      -> await_new_jobs_pid_recurse(N, OldP, TRef);
        undefined -> await_new_jobs_pid_recurse(N, OldP, TRef);
        NewP when is_pid(NewP) ->
            erlang:cancel_timer(TRef),
            NewP
    end.

await_new_jobs_pid_recurse(N, OldP, TRef) ->
    receive
        {timeout, TRef, _} ->
            erlang:error(timeout)
    after 100 ->
            await_new_jobs_pid(N, OldP, TRef)
    end.

use_swagger(SpecVsn) ->
    Prefix =
        case SpecVsn of
            oas3 -> "/v3/";
            swagger2 -> "/v2/"
        end,
    put(api_prefix, Prefix).

get(Key, Default) ->
    case get(Key) of
        undefined -> Default;
        V -> V
    end.

http_api_version() ->
    case get(api_prefix, "/v2/") of
       "/v2/" -> swagger2;
       "/v3/" -> oas3
    end.

http_request(Host, get, Path, Params) ->
    Prefix = get(api_prefix, "/v2/"),
    URL = binary_to_list(
            iolist_to_binary([Host, Prefix, Path, encode_get_params(Params)])),
    ct:log("GET ~p", [URL]),
    R = httpc_request(get, {URL, []}, [], []),
    process_http_return(R);
http_request(Host, post, Path, Params) ->
    Prefix = get(api_prefix, "/v2/"),
    URL = binary_to_list(iolist_to_binary([Host, Prefix, Path])),
    {Type, Body} = case Params of
                       Map when is_map(Map) ->
                           %% JSON-encoded
                           {"application/json", jsx:encode(Params)};
                       [] ->
                           {"application/x-www-form-urlencoded",
                            http_uri:encode(Path)}
                   end,
    %% lager:debug("Type = ~p; Body = ~p", [Type, Body]),
    ct:log("POST ~p, type ~p, Body ~p", [URL, Type, Body]),
    R = httpc_request(post, {URL, [], Type, Body}, [], []),
    process_http_return(R);
http_request(Host, delete, Path, Params) ->
    Prefix = get(api_prefix, "/v2/"),
    URL = binary_to_list(
            iolist_to_binary([Host, Prefix, Path, encode_get_params(Params)])),
    ct:log("DELETE ~p", [URL]),
    R = httpc_request(delete, {URL, []}, [], []),
    process_http_return(R).

httpc_request(Method, Request, HTTPOptions, Options) ->
    httpc_request(Method, Request, HTTPOptions, Options, test_browser).

httpc_request(Method, Request, HTTPOptions, Options, Profile) ->
    {ok, Pid} = inets:start(httpc, [{profile, Profile}], stand_alone),
    Response = httpc:request(Method, Request, HTTPOptions, Options, Pid),
    ok = gen_server:stop(Pid, normal, infinity),
    Response.

encode_get_params(#{} = Ps) ->
    encode_get_params(maps:to_list(Ps));
encode_get_params([{K,V}|T]) ->
    Enc =
        fun(Key, Value) ->
            case Value of
                true -> str(Key);
                _ -> [str(Key), "=", uenc(Value)]
            end
        end,
    lists:flatten(
        ["?", [Enc(K, V)
              | [["&", Enc(K1, V1)]
                  || {K1, V1} <- T]]]);
encode_get_params([]) ->
    [].

str(A) when is_atom(A) ->
    str(atom_to_binary(A, utf8));
str(S) when is_list(S); is_binary(S) ->
    S.

uenc(B) when is_boolean(B) ->
    uenc(atom_to_list(B));
uenc(I) when is_integer(I) ->
    uenc(integer_to_list(I));
uenc(V) ->
    http_uri:encode(V).

process_http_return(R) ->
    case R of
        {ok, {{_, ReturnCode, _State}, _Head, Body}} ->
            try
                ct:log("Return code ~p, Body ~p", [ReturnCode, Body]),
                Result =
                    case iolist_to_binary(Body) of
                        <<>> ->
                            #{};
                        BodyB ->
                            jsx:decode(BodyB, [return_maps])
                    end,
                {ok, ReturnCode, Result}
            catch error:E:ST ->
                {error, {parse_error, [E, ST]}}
            end;
        {error, _} = Error ->
            Error
    end.

internal_address() ->
    Port = rpc(aeu_env, user_config_or_env,
              [ [<<"http">>, <<"internal">>, <<"port">>],
                aehttp, [internal, port], 8143]),
    "http://127.0.0.1:" ++ integer_to_list(Port).

external_address() ->
    Port = rpc(aeu_env, user_config_or_env,
              [ [<<"http">>, <<"external">>, <<"port">>],
                aehttp, [external, port], 8043]),
    "http://127.0.0.1:" ++ integer_to_list(Port).     % good enough for requests

rpc(Mod, Fun, Args) ->
    rpc(?DEFAULT_NODE, Mod, Fun, Args).

rpc(Node, Mod, Fun, Args) ->
    rpc:call(node_name(Node), Mod, Fun, Args, 5000).

generate_key_pair() ->
    #{ public := Pubkey, secret := Privkey } = enacl:sign_keypair(),
    {Pubkey, Privkey}.

meta_tx(Owner, AuthOpts, AuthData, InnerTx0) ->
    InnerSTx =
        try aetx_sign:tx(InnerTx0) of
            _Tx -> InnerTx0
        catch _:_ ->
            aetx_sign:new(InnerTx0, [])
        end,
    Options1 = maps:merge(#{auth_data => AuthData, tx => InnerSTx}, AuthOpts),
    MetaTx   = aega_test_utils:ga_meta_tx(Owner, Options1),
    aetx_sign:new(MetaTx, []).

get_key_hash_by_delta(Node, Delta) ->
    TopHeader = rpc(Node, aec_chain, top_header, []),
    TopHeight = aec_headers:height(TopHeader),
    {ok, Header} = rpc(Node, aec_chain, get_key_header_by_height, [TopHeight - Delta]),
    {ok, Hash} = aec_headers:hash_header(Header),
    Hash.

mine_safe_setup(Node, MiningRate, Opts, LoopFun) ->
    ok = rpc:call(Node, application, set_env,
                  [aecore, expected_mine_rate, MiningRate], 5000),

    %% Ensure we are not mining before starting
    stopped = rpc:call(Node, aec_conductor, get_mining_state, [], 5000),
    _ = flush_new_blocks(), %% flush potential hanging message queue messages

    %% Start mining
    subscribe(Node, block_created),
    subscribe(Node, micro_block_created),
    StartRes = rpc:call(Node, aec_conductor, start_mining, [Opts], 5000),
    ct:log("aec_conductor:start_mining(~p) (~p) -> ~p", [Opts, Node, StartRes]),

    %% Run custom loop which is expected to return when done
    Res = LoopFun(),

    %% Stop mining
    StopRes = rpc:call(Node, aec_conductor, stop_mining, [], 5000),
    ct:log("aec_conductor:stop_mining() (~p) -> ~p", [Node, StopRes]),
    unsubscribe(Node, block_created),
    unsubscribe(Node, micro_block_created),

    %% Ensure we are not mining after we've stopped
    stopped = rpc:call(Node, aec_conductor, get_mining_state, [], 5000),
    _ = flush_new_blocks(), %% flush potential hanging message queue messages

    case Res of
        {ok, BlocksReverse} ->
            {ok, lists:reverse(BlocksReverse)};
        {error, Reason} ->
            erlang:error(Reason)
    end.

%%%=============================================================================
%%% Partially imported from https://github.com/erlware/relx/blob/master/src/rlx_util.erl#L232
%%%=============================================================================

symlink_or_copy(Source, Target) ->
    case file:make_symlink(Source, Target) of
        ok ->
            ok;
        {error, eexist} ->
            {error, eexist};
        {error, Err} ->
            case {os:type(), Err} of
                {{win32, _}, eperm} ->
                    % We get eperm on Windows if we do not have
                    %   SeCreateSymbolicLinkPrivilege
                    % Try the next alternative
                    win32_make_junction_or_copy(Source, Target);
                _ ->
                    % On other systems we try to copy next
                    cp_r(Source, Target)
            end
    end.

cp_r(Source, Target) ->
    ec_file:copy(Source, Target, [{recursive, true}, {fileinfo, [mode, time, owner, group]}]).

win32_make_junction_or_copy(Source, Target) ->
    case filelib:is_dir(Source) of
        true ->
            win32_make_junction(Source, Target);
        _ ->
            cp_r(Source, Target)
    end.

win32_make_junction(Source, Target) ->
    % The mklink will fail if the target already exists, check for that first
    case file:read_link_info(Target) of
        {error, enoent} ->
            win32_make_junction_cmd(Source, Target);
        {ok, #file_info{type = symlink}} ->
            case file:read_link(Target) of
                {ok, Source} ->
                    ok;
                {ok, _} ->
                    ok = file:del_dir(Target),
                    win32_make_junction_cmd(Source, Target);
                {error, Reason} ->
                    {error, {readlink, Reason}}
            end;
        {ok, #file_info{type = _Type}} ->
            % Directory already exists, so we overwrite the copy
            cp_r(Source, Target);
        Error ->
            Error
    end.

win32_make_junction_cmd(Source, Target) ->
    S = unicode:characters_to_list(Source),
    T = unicode:characters_to_list(Target),
    Cmd = "cmd /c mklink /j " ++ filename:nativename(T) ++ " " ++ filename:nativename(S),
    case os:cmd(Cmd) of
        "Junction created " ++ _ ->
            ok;
        [] ->
            % When mklink fails it prints the error message to stderr which
            % is not picked up by os:cmd() hence this case switch is for
            % an empty message
            cp_r(Source, Target)
    end.

win32_delete_junction(Target) ->
    T = unicode:characters_to_list(Target),
    Cmd = "cmd /c rd /s /q " ++ filename:nativename(T),
    case os:cmd(Cmd) of
        [] ->
            ok;
        Output ->
            ct:log("Output from deleting junction ~s: ~p~n", [Target, Output]),
            ok
    end.
