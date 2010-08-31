-module(elu_test).
-compile(export_all).

%% elu test

test() ->
  {ok, F} = file:read_file("index/_0.cfs"),
  % {ok, Files, _} = elu_cfs:desc_file(cfs, F),
  % io:format("~p~n", [Files]),

  {ok, Files, _} = elu_cfs:read_file(cfs, F),
  
  [{_Nrm, _Lrm, Nrm}, {_Nis, _Lis, Tis},
   {_Nnm, _Lnm, Fnm}, {_Nii, _Lii, Tii},
   {_Nrq, _Lrq, Frq}, {_Nrx, _Lrx, Prx}] = Files,

  % Result = elu_tii:read_tii(tii, Tii),
  % io:format("~p~n", [Result])
  % Result = elu_tis:read_tis(tis, Tis),
  % io:format("~p~n", [size(Result)]),
  % elu_tis:show_terms(tis, Tis, 1000),

  Result = elu_frq:read_frq(frq, Frq),
  io:format("~p~n", [Result]),

  true.