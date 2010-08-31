-module(elu_cfs).
-compile(export_all).

%% elu CFS : how to read a compound file

desc_file(cfs, Bin) ->
  {ok, FileCount, Rest1} = elu_t:read_vint(Bin),
  accum_file_desc(Rest1, [], FileCount).

read_file(cfs, Bin) ->
  {ok, Desc, _Rest} = desc_file(cfs, Bin),
  accum_file_parts(Bin, Desc, []).


accum_file_desc(Bin, Accum, 0) -> {ok, lists:reverse(Accum), Bin};
accum_file_desc(Bin, Accum, Count) ->
  {ok, FileOffset, Rest1} = elu_t:read_long(Bin),
  {ok, FileName, Rest2} = elu_t:read_string(Rest1),
  accum_file_desc(Rest2, [{FileName, FileOffset} | Accum], Count - 1).

accum_file_parts(Bin, [], Accum) -> {ok, lists:reverse(Accum), Bin};
accum_file_parts(Bin, [{FileName, FileOffset}], Accum) ->
  <<_:FileOffset/binary, FileData/binary>> = Bin,
  accum_file_parts(Bin, [], [{FileName, size(FileData), FileData} | Accum]);
accum_file_parts(Bin, [{FileName, FileOffset}, {NextName, NextOffset} | T], Accum) ->
  FileLen = NextOffset - FileOffset,
  <<_:FileOffset/binary, FileData:FileLen/binary, _Rest/binary>> = Bin,
  accum_file_parts(Bin, [{NextName, NextOffset} | T],
    [{FileName, FileLen, FileData} | Accum]).