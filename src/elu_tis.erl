-module(elu_tis).
-compile(export_all).

%% elu TIS : how to read a term infos file


show_terms(tis, Bin, Count) ->
  {ok, _, _, _, _, _, {term_infos, TermInfos}} = read_tis(tis, Bin),
  show_term_loop(TermInfos, Count).

show_term_loop(_, 0) -> true;
show_term_loop([H|T], Count) ->
  {Term, _, _, _, _} = H,
  io:format("~p~n", [Term]),
  show_term_loop(T, Count -1).


read_tis(tis, Bin) ->
  Rest0 = Bin,
  {ok, TIVersion, Rest1}      = elu_t:read_uint32(Rest0),
  {ok, IndexTermCount, Rest2} = elu_t:read_long(Rest1),
  {ok, IndexInterval, Rest3}  = elu_t:read_uint32(Rest2),
  {ok, SkipInterval, Rest4}   = elu_t:read_uint32(Rest3),
  {ok, MaxSkipLevels, Rest5}  = elu_t:read_uint32(Rest4),
  {ok, TermInfos} = accum_term_infos(Rest5, SkipInterval, [], IndexTermCount),
  {ok, {ti_version, TIVersion}, {term_count, IndexTermCount},
  {index_interval, IndexInterval}, {skip_interval, SkipInterval},
  {max_skip_levels, MaxSkipLevels}, {term_infos, TermInfos}}.


accum_term_infos(_, _, Accum, 0) -> {ok, lists:reverse(Accum)};
accum_term_infos(Bin, SkipInterval, Accum, Count) ->
  {ok, PrefixLen, Rest1}   = elu_t:read_vint(Bin),
  {ok, Suffix, Rest2}      = elu_t:read_string(Rest1),
  {ok, FieldNum, Rest3}    = elu_t:read_vint(Rest2),
  Term = {term, Count, PrefixLen, Suffix, FieldNum},
  {ok, DocFreq, Rest4}     = elu_t:read_vint(Rest3),
  {ok, FreqDelta, Rest5}   = elu_t:read_vint(Rest4),
  {ok, ProxDelta, Rest6}   = elu_t:read_vint(Rest5),
  {ok, SkipDelta, Rest7} = case (DocFreq >= 16) of
     true -> 
       elu_t:read_vint(Rest6);
     false -> {ok, 0, Rest6}
  end,
  accum_term_infos(Rest7, SkipInterval,
    [{Term, {doc_freq, DocFreq}, {freq_delta, FreqDelta},
     {prox_delta, ProxDelta}, {skip_delta, SkipDelta}} | Accum],
    Count - 1).
