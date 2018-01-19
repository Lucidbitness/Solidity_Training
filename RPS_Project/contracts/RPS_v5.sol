pragma solidity 0.4.18;

contract RockPaperScissors {
    address public owner;
    
    enum RPSMoves{
        NC, Rock, Paper, Scissors
    }

    struct RPSGame
        {
            address playerOne;
            address playerTwo;
            address winner;
            bytes32 playerOneMove;      
            RPSMoves playerTwoMove;
            uint256 betAmount;
            uint256 gameDuration;
        }

    mapping(bytes32 => RPSGame) public activeGames;
    mapping(bytes32 => bool) public usedPlayerMoves;
    mapping(address => uint256) public funds;

    event LogGameCreated(address playerOne, bytes32 gameHash, uint256 betAmount);
    event LogPlayerTwoSetMove(RPSMoves playerTwoMove);
    event LogTieGame(address playerOne, RPSMoves playerOneMove, address playerTwo, RPSMoves playerTwoMove);
    event LogWinner(address winningPlayer, uint256 funds);
    
    function RockPaperScissors()
            public
        {
            owner = msg.sender;
        }

    function createGame(bytes32 hashPlayerOneMove, uint256 gameDuration)
        external
        payable

        {   
            bytes32 gameID = keccak256(msg.sender, hashPlayerOneMove);
            RPSGame storage activeGame = activeGames[gameID];
            require(activeGame.playerOne == 0); 
            require(hashPlayerOneMove != bytes32(0));
            require(msg.value > 0.1 ether);
            require(usedPlayerMoves[hashPlayerOneMove] == false);
            activeGame.playerOne = msg.sender;
            activeGame.playerOneMove = hashPlayerOneMove;
            activeGame.betAmount = msg.value;
            activeGame.gameDuration = block.number + gameDuration;
            usedPlayerMoves[hashPlayerOneMove] == true;
            LogGameCreated(msg.sender, gameID, msg.value);
        }

    
    function joinGame(RPSMoves playerTwoMove, bytes32 existingGameHash)
        public
        payable
        {
            RPSGame storage activeGame = activeGames[existingGameHash];
            require(msg.sender != activeGame.playerOne && msg.sender != activeGame.playerTwo);
            require(msg.value == activeGame.betAmount);
            require(now < activeGame.gameDuration);
            activeGame.playerTwo = msg.sender;
            activeGame.playerTwoMove = playerTwoMove;
        }


    function playerOneRevealMove(bytes32 hashPlayerOneMove, bytes32 passKey, RPSMoves move)
        public
        {
            bytes32 gameID = keccak256(msg.sender, hashPlayerOneMove);
            bytes32 checkMove = keccak256(move, passKey);
            require(checkMove == hashPlayerOneMove);
            require(activeGames[gameID].playerTwo != 0);       
            determineWinner(gameID, move);
        }


    function determineWinner(bytes32 gameID, RPSMoves move)
        internal
        {
            RPSGame storage activeGame = activeGames[gameID];

            if(move != activeGame.playerTwoMove){

                if(move == RPSMoves.Rock && activeGame.playerTwoMove == RPSMoves.Paper){activeGame.winner = activeGame.playerTwo;}
                if(move == RPSMoves.Rock && activeGame.playerTwoMove == RPSMoves.Scissors){activeGame.winner = activeGame.playerOne;}
                if(move == RPSMoves.Paper && activeGame.playerTwoMove == RPSMoves.Rock){activeGame.winner = activeGame.playerOne;}
                if(move == RPSMoves.Paper && activeGame.playerTwoMove == RPSMoves.Scissors){activeGame.winner = activeGame.playerTwo;}
                if(move == RPSMoves.Scissors && activeGame.playerTwoMove == RPSMoves.Rock){activeGame.winner = activeGame.playerTwo;}
                if(move == RPSMoves.Scissors && activeGame.playerTwoMove == RPSMoves.Paper){activeGame.winner = activeGame.playerOne;}

                uint256 totalBet = 2*activeGame.betAmount;
                funds[activeGame.winner] = totalBet;
                LogWinner(activeGame.winner, totalBet);
            } else {
                funds[activeGame.playerOne] = activeGame.betAmount;
                funds[activeGame.playerTwo] = activeGame.betAmount; 
                LogTieGame(activeGame.playerOne, move, activeGame.playerTwo, activeGame.playerTwoMove);
            }
            resetGameID(gameID);
        }
    
    function durationPassedPlayerClaim(bytes32 gameID)
        external
        {
            RPSGame storage activeGame = activeGames[gameID];
            require(msg.sender == activeGame.playerTwo || msg.sender == activeGame.playerOne);
            require(now > activeGame.gameDuration);
            if(activeGame.playerTwo == 0 && msg.sender == activeGame.playerOne){
                funds[activeGame.playerOne] = activeGame.betAmount; 
            }else{
                funds[activeGame.playerTwo] = 2*activeGame.betAmount;
            }
            resetGameID(gameID);
        }

    function resetGameID(bytes32 gameID)
        internal
        {
            RPSGame storage activeGame = activeGames[gameID];
            activeGame.playerOne = address(0);
            activeGame.playerTwo = address(0);
            activeGame.winner = address(0);
            activeGame.playerOneMove = bytes32(0);
            activeGame.playerTwoMove = RPSMoves(0);
            activeGame.betAmount = 0;    
        }

    ///@notice allows participants to withdraw funds win quit or tie
    function withdrawFunds()
        external
        returns(bool withdrawSuccess)
        {
            require(funds[msg.sender] >= 0.1 ether);
            uint256 amount = funds[msg.sender];
            funds[msg.sender] = 0;
            msg.sender.transfer(amount);
            return(true);
        }

}