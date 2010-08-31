-module(elu_fdx).
-compile(export_all).

%% elu FDX : how to read a field index file

get_doc(fdx, Bin, DocId) ->
  % TODO: explain the magic "4"
  Offset = (DocId * 8) + 4,
  <<_Ignored:Offset/binary, Rest1/binary>> = Bin,
  {ok, FdtOffset, _Rest2} = elu_t:read_long(Rest1),
  {ok, FdtOffset}.

