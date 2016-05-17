game.erl module

- How to run game.erl in a distributed environment 
- with clients playing on two separate networks. 

@assert: User has linux distribution
@assert: game.erl in on CIS moat server 
1. Open up two terminals and ssh into moat with cis username in both terminals
	> ssh kbedsole@moat.cis.uab.edu
	(This should put you on two separate vulcan servers)

2. Compile game.erl module (make sure game.erl is in your current directory)
    > erl
	> c(game).
   	> (Ctrl+Z) to exit erl

3. Start a different erl instance on each server (Make sure the name matches the 
current vulcan server you are on)
    > erl -name black@vulcan1.cis.uab.edu -setcookie XYZ
    > erl -name white@vulcan2.cis.uab.edu -setcookie XYZ

4. Now, on black@vulcan1.cis.uab.edu, you can start a new game 
using the game.erl module.
The black vulcan instance you created will sit and wait for a "handshake"
or remote client to connect to him. Initiating the TCP/IP connection. 
    
	black> game:new().

5. On the white vulcan, connect to the remote listener (black vulcan).
By doing so white vulcan accepts "handshake" and sends acknowledgement 
back to black vulcan to let him know he accepted connection. This 
will complete the TCP connection between the two clients. 

	white> game:playWith('black@vulcan1.cis.uab.edu').

6. Now you can send messages back and forth between clients using the following
module funcions:

% communicate 
%        - send messages back and forth:
%             black> game:tell('hello there').
%             white> game:tell('hey what's going on').
%
%         // coordinates args are 1, 2, or 3
%        - play coordinate on tic tac toe board:
%             black> game:playToken(x, 1, 2).
%             white> game:playToken(o, 2, 2).

7. End game by using following function on one of the clients:

	white> game:end().



