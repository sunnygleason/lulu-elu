-module(elu_fnm).
-compile(export_all).

%% elu FNM : how to read a fields name file

read_fnm(fnm, Bin) ->
  {ok, FieldCount, Rest1} = elu_t:read_vint(Bin),
  accum_field_info(Rest1, [], FieldCount).

accum_field_info(_, Accum, 0) -> {ok, lists:reverse(Accum)};
accum_field_info(Bin, Accum, Count) ->
  {ok, FieldName, Rest1} = elu_t:read_string(Bin),
  {ok, Bits, Rest2} = elu_t:read_byte(Rest1),
  accum_field_info(Rest2, [{FieldName, Bits} | Accum], Count - 1).
