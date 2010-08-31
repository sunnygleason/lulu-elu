-module(elu_frq).
-compile(export_all).

%% elu FRQ : how to read a frequency file

read_frq(frq, Bin) ->
  Rest0 = Bin,
%  {ok, TIVersion, Rest1}      = elu_t:read_uint32(Rest0),
%  {ok, IndexTermCount, Rest2} = elu_t:read_long(Rest1),
%  {ok, IndexInterval, Rest3}  = elu_t:read_uint32(Rest2),
%  {ok, SkipInterval, Rest4}   = elu_t:read_uint32(Rest3),
%  {ok, MaxSkipLevels, Rest5}  = elu_t:read_uint32(Rest4),
  {ok, TermFreqs} = accum_term_freqs(Rest0, []),
  {ok, {term_freqs, TermFreqs}}.


%% TODO TODO TODO
accum_term_freqs(_, Accum) -> {ok, lists:reverse(Accum)};
accum_term_freqs(Bin, Accum) ->
  {ok, PrefixLen, Rest1}   = elu_t:read_vint(Bin),
  {ok, Suffix, Rest2}      = elu_t:read_string(Rest1),
  {ok, FieldNum, Rest3}    = elu_t:read_vint(Rest2),
  Rest4 = Rest3,
  Term = {term, PrefixLen, Suffix, FieldNum},
  {ok, DocFreq, Rest5}     = elu_t:read_vint(Rest4),
  {ok, FreqDelta, Rest6}   = elu_t:read_vint(Rest5),
  {ok, ProxDelta, Rest7}   = elu_t:read_vint(Rest6),
  {ok, SkipDelta, Rest8}  = case (DocFreq >= SkipInterval) of
    true -> elu_t:read_vint(Rest7);
    _ -> {ok, 0, Rest7}
  end,
  {ok, IndexDelta, Rest9}   = elu_t:read_vint(Rest8),
  accum_term_freqs(Rest9, SkipInterval,
    [{Count, Term, {doc_freq, DocFreq}, {freq_delta, FreqDelta},
     {prox_delta, ProxDelta}, {skip_delta, SkipDelta}, {index_delta, IndexDelta}} | Accum],
    Count - 1).
