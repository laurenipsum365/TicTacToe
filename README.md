<h1>game.erl module</h1>
<p>
<h3>How to run game.erl in a distributed environment with clients playing on two separate networks.</h3>
<br>
@assert: User has linux distribution
<br>
@assert: game.erl in on CIS moat server 
</p>
1. Open up two terminals and ssh into moat with cis username in both terminals:<br>(This should put you on two separate vulcan servers)<br><br>
   		&nbsp;&nbsp;&nbsp;&nbsp;> ssh kbedsole@moat.cis.uab.edu<br><br>
2. Compile game.erl module: <br>(make sure game.erl is in your current directory)<br><br>
    	&nbsp;&nbsp;&nbsp;&nbsp;> erl <br>
	    &nbsp;&nbsp;&nbsp;&nbsp;> c(game). <br>
   		&nbsp;&nbsp;&nbsp;&nbsp;> (Ctrl+Z) to exit erl <br><br>
3. Start a different erl instance on each server: <br> (Make sure the name matches the 
current vulcan server you are on)<br><br>
    	&nbsp;&nbsp;&nbsp;&nbsp;> erl -name black@vulcan1.cis.uab.edu -setcookie XYZ<br>
    	&nbsp;&nbsp;&nbsp;&nbsp;> erl -name white@vulcan2.cis.uab.edu -setcookie XYZ<br><br>

4. Now, on black@vulcan1.cis.uab.edu, you can start a new game 
using the game.erl module. The black vulcan instance you created will 
sit and wait for a "handshake" or remote client to connect to him. 
Initiating the TCP/IP connection: <br><br>
    
	&nbsp;&nbsp;&nbsp;&nbsp;black> game:new().<br><br>

5. On the white vulcan, connect to the remote listener (black vulcan).
By doing so white vulcan accepts "handshake" and sends acknowledgement 
back to black vulcan to let him know he accepted connection. This 
will complete the TCP connection between the two clients: <br><br>

	&nbsp;&nbsp;&nbsp;&nbsp;white> game:playWith('black@vulcan1.cis.uab.edu').<br><br>

6. Now you can send messages back and forth between clients using the following
module funcions: <br><br>

	&nbsp;&nbsp;&nbsp;&nbsp;<b>Send Messages Back and Forth:</b><br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;black> game:tell('hello there').<br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;white> game:tell('hey what's going on').<br><br>
			
	&nbsp;&nbsp;&nbsp;&nbsp;<b>Play Coordinate on TicTacToe Board:</b><br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;black> game:playToken(x, 1, 2). <br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;white> game:playToken(o, 2, 2). <br><br>

7. End game by using following function on one of the clients:<br>

	&nbsp;&nbsp;&nbsp;&nbsp;white> game:end().<br>



