-module(elu_t).
-compile(export_all).

%%
%% erlang lucene types - binary encoding
%%

%% byte type
read_byte(Bin) ->
  <<TheByte:1/binary, Rest/binary>> = Bin,
  {ok, TheByte, Rest}.

%% byte array type
read_byte_array(Bin) ->
  {ok, Len, Rest1} = read_vint(Bin),
  <<TheBytes:Len/binary-unit:8, Rest2/binary>> = Rest1,
  {ok, TheBytes, Rest2}.

%% uint32 type - 4 bytes, high-end first
read_uint32(Bin) ->
  <<TheUint32:32/integer, Rest/binary>> = Bin,
  {ok, TheUint32, Rest}.

%% uint64 type - 8 bytes, high-end first
read_long(Bin) -> read_uint64(Bin).

read_uint64(Bin) ->
  <<TheUint64:64/integer, Rest/binary>> = Bin,
  {ok, TheUint64, Rest}.

%% vint type - variable unsigned int
read_vint(Bin) ->
  {ok, RevBytes, Rest} = read_vint_loop(Bin, []),
  Result = lists:foldl(
    fun(X, Accum) ->  X + (Accum bsl 7) end, 0, RevBytes),
  {ok, Result, Rest}.
read_vint_loop(<<0:1, Num:7, Rest/binary>>, Accum) ->
  {ok, [Num | Accum], Rest};
read_vint_loop(<<1:1, Num:7, Rest/binary>>, Accum) ->
  read_vint_loop(Rest, [Num | Accum]).


%% TODO: utf8 chars
%% string type - length(vint), bytes
read_string(Bin) ->
  {ok, Len, Rest1} = read_vint(Bin),
  <<TheString:Len/binary, Rest2/binary>> = Rest1,
  {ok, TheString, Rest2}.

%% compound file format
%% file types
%% .fnm -- field names : field descriptions
%% .fdx -- field index : fixed-size pointers
%% .fdt -- field data  : variable size field data
%% .tis -- term infos  : full term index
%% .tii -- term info index : fast term index
%% .frq -- term frequency : which docs contain frq


