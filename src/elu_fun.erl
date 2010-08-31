-module(elu_fun).
-compile(export_all).

%%
%% a couple functions that capture file munging idioms
%%

%
% fold over an entire binary
%
bin_foldl(_Fun, Accum, <<>>) -> lists:reverse(Accum);
bin_foldl(Fun, Accum, Bin) ->
  [Result, Rest] = Fun(Accum, Bin),
  bin_foldl(Fun, Result, Rest).

%
% fold over a binary while a count is nonzero
%
bin_iter(_Fun, Accum, 0, Bin) -> [lists:reverse(Accum), Bin];
bin_iter(Fun, Accum, Count, Bin) ->
  [Result, Rest] = Fun(Accum, Bin),
  bin_iter(Fun, Result, Count - 1, Rest).

