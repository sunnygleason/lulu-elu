-module(elu_fdt).
-compile(export_all).

%% elu FDT : how to read a fields data file

read_doc(fdt, Bin, Offset) ->
  <<_:Offset/binary, Rest1/binary>> = Bin,
  {ok, FieldCount, Rest2} = elu_t:read_vint(Rest1),
  accum_fields(Rest2, [], FieldCount).


accum_fields(_, Accum, 0) -> {ok, lists:reverse(Accum)};
accum_fields(Bin, Accum, Count) ->
  {ok, FieldNum, Rest1} = elu_t:read_vint(Bin),
  {ok, Bits, Rest2} = elu_t:read_byte(Rest1),
  {ok, Value, Rest3} = case Bits of
    <<_:6, 0:1, _:1>> -> elu_t:read_string(Rest2);
    <<_:6, 1:1, _:1>> -> elu_t:read_byte_array(Rest2)
  end,
  accum_fields(Rest3, [{FieldNum, Bits, Value} | Accum], Count - 1).
