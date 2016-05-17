-module(game).
-export([listen/0,connect/1,play_with/1,new/0,ping/0,stop/0,placeToken/3,
tell/1, new_board/0, play/4, check/1, clear/0]).


%%%
% (1) start two erl instances. e.g.,
%     > erl -name black@vulcan1.cis.uab.edu -setcookie XYZ
%     > erl -name white@vulcan2.cis.uab.edu -setcookie XYZ
% (2) start the first listener
%     black> game:new().
% (3) connect remote listener
%     white> game:playWith('black@vulcan1.cis.uab.edu').
% (4) communicate 
%        - send messages back and forth:
%             black> game:tell('hello there').
%             white> game:tell('hey what's going on').
%
%         // coordinates args are 1, 2, or 3
%        - play coordinate on tic tac toe board:
%             black> game:playToken(x, 1, 2).
%             white> game:playToken(o, 2, 2).
% (5) stop
%     black> game:stop().
%%%


%%%
% listen waits for incoming messages once a connection with Buddy has been
% established.
%
% listen supports two kinds of messages
% a) messages received from remote buddy,
% b) requests from local users, to talk to remote buddy.
%%%
listen(Buddy, Board) ->
   receive
      %% remote communication
      {_, ping} ->
         io:format("ping", []),
         Buddy!{self(), ack},
         listen(Buddy, Board);
      {_, get_msg, Message} ->
         io:format("msg received : ~w~n", [Message]),
         Buddy!{self(), ack},
         listen(Buddy, Board);
      {_, played_coordinate, NewBoard} ->
         io:format("New board is: ~p. ~n", [NewBoard]),
         io:format("Your Turn! Play your move ~n", []),
         listen(Buddy, NewBoard);
      {_, ack} ->
         io:format("ack : ~n", []),
         listen(Buddy, Board);
      {_, stop} ->
         unregister(alistener),
         io:format("stop~n", []);
            
      %% local communication
      {_, reqping} ->
         Buddy!{self(), ping},
         io:format("sendping~n", []),
         listen(Buddy, Board);
      {_, message, Message} ->
         Buddy!{self(), get_msg, Message},
         io:format("msg sent : ~w~n", [Message]),
         listen(Buddy, Board);
      {_, place_coordinate, Who, X, Y} ->
         NewBoard = play(Who, X, Y, Board),
         io:format("New board is: ~p. ~n", [NewBoard]),
         io:format("now waiting on opponent to make move...~n", []),
         Buddy!{self(), played_coordinate, NewBoard},
         listen(Buddy, NewBoard);
      {_, reqstop} ->
         Buddy!{self(), stop},
         io:format("sendstop~n", [])
   end.

%%%
% - Listen waits for an initial handshake from a remote Buddy,
%     before it invokes listen/1
% - Randomly chooses which client will start first.
% - Creates a new tic tac toe board to be passed around between 
%     clients.
%%%
listen() ->
   %% gen rand # to see which client will start game first
   random:seed(erlang:now()),
   Ran = (random:uniform()), 
   if Ran < 0.5 ->
      PlaysFirst = false;
   true ->
      PlaysFirst = true
   end,
   
   %% initialize board
   NewBoard = new_board(),

   receive
      %% remote communication %%
      {PID, handshake} ->
         io:format("connected to client : ~p~n", [PID]),     
         if PlaysFirst == true ->
            io:format("You go first! Place token.. ~n", []);
         true -> 
            io:format("You go second. Wait for other player..  ~n", [])
         end,
         PID!{self(), ack},
         listen(PID, NewBoard);
      {PID, ack} ->
         io:format("connected to client : ~p~n", [PID]),
         if PlaysFirst == true ->
             io:format("You go first! Place token.. ~n", []);
         true -> 
             io:format("You go second. Wait for other player..  ~n", [])
         end,
         listen(PID, NewBoard);
      
      %% local communication %%
      {_, reqping} ->
         io:format("no buddy~n", []),
         listen();
      {_, reqstop} ->
         io:format("stopped~n", [])
   end.

%%%
% connect can be called from a remote instance to initiate communication.
% Buddy   remote Buddy's PID
%%%
connect(Buddy) ->
   alistener!{Buddy, handshake}.

%%%
% rconnect sets up local listener and then establishes a connection
% with a remote listener.
%%%
play_with(Opponent) ->
   PID = spawn(game, listen, []),
   register(alistener, PID),
   spawn(Opponent, game, connect, [PID]).
  
%%%
% spawns and registers a local listener
%%%
new() ->
   PID = spawn(game, listen, []),
   register(alistener, PID).

%%%
% sends a request to ping the buddy
%%%
ping() ->
   alistener!{self(), reqping}.

%%%
% sends a request to ping the buddy
%%%
tell(Message) ->
   alistener!{self(), message, Message}.

%%%
% places tic tac toe  
%%%
placeToken(Who, X, Y) ->
   alistener!{self(), place_coordinate, Who, X, Y}.

%%%
% sends a request to stop the communication, and unregisters alistener
%%%
stop() ->
   alistener!{self(), reqstop},
   unregister(alistener).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Tic Tac Toe Logic %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new_board() ->
   {l, l, l,
    l, l, l,
    l, l, l}.

%%%
% Updates board and returns new board
%%%
play(Who, X, Y, Board) ->
   NewBoard = setelement((Y - 1) * 3 + X, Board, Who), 
   NewBoard.

%%%
% clears terminal screen
%%%
clear() ->
   io:format("\033[2J").

check(Board) ->
   case Board of
      {x, x, x,
       _, _, _,
       _, _, _} -> {victory, x};

      {_, _, _,
       x, x, x,
       _, _, _} -> {victory, x};

      {_, _, _,
       _, _, _,
       x, x, x} -> {victory, x};

      {x, _, _,
       x, _, _,
       x, _, _} -> {victory, x};

      {_, x, _,
       _, x, _,
       _, x, _} -> {victory, x};

      {_, _, x,
       _, _, x,
       _, _, x} -> {victory, x};

      {x, _, _,
       _, x, _,
       _, _, x} -> {victory, x};

      {_, _, x,
       _, x, _,
       x, _, _} -> {victory, x};

      {o, o, o,
       _, _, _,
       _, _, _} -> {victory, o};

      {_, _, _,
       o, o, o,
       _, _, _} -> {victory, o};

      {_, _, _,
       _, _, _,
       o, o, o} -> {victory, o};

      {o, _, _,
       o, _, _,
       o, _, _} -> {victory, o};

      {_, o, _,
       _, o, _,
       _, o, _} -> {victory, o};
      
      {_, _, o,
       _, _, o,
       _, _, o} -> {victory, o};
      
      {o, _, _,
       _, o, _,
       _, _, o} -> {victory, o};

      {_, _, o,
       _, o, _,
       o, _, _} -> {victory, o};

      {A, B, C,
       D, E, F,
       G, H, I} when A =/= undefined, B =/= undefined, C =/= undefined,
                       D =/= undefined, E =/= undefined, F =/= undefined,
                       G =/= undefined, H =/= undefined, I =/= undefined ->
                draw;

                _ -> ok
   end.

