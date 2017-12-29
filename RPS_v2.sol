pragma solidity 0.4.18;

contract RockPaperScissors {
    
    address private owner;

    struct RPSPlayer
        {
            address player;
            uint256 funds;
            bytes32 moveSecret;
            uint8 playerMove;
            bool winner;      
        }

    enum RPSMoves{
        NC, Rock, Paper, Scissors
    }

    RPSPlayer[2] public activeGame;

    event LogPlayer1Joined(address _playerOne);
    event LogPlayer2Joined(address _playerTwo);
    event LogAnnounceWinner(address _winner, uint8 _moveOne, uint8 moveTwo, uint256 _amount);
   
    modifier twoPlayersJoined() { 
        require(activeGame[0].player != 0 && activeGame[1].player != 0);
        _; 
    }
    
    function RockPaperScissors()
            public
        {
            owner = msg.sender;
        }

    function getOwner()
        public
        view
        returns (address)
        {
            return owner;
        }

    function joinGame(bytes32 _moveHash)
        public
        payable

        {   
            require(_moveHash != 0);
            require(msg.value != 0);
            require(msg.sender != activeGame[0].player);
            
            if(activeGame[0].player == 0){
                activeGame[0].player = msg.sender;
                activeGame[0].funds = msg.value;
                activeGame[0].moveSecret = _moveHash;
                LogPlayer1Joined(msg.sender);
            } else {               
                activeGame[1].player = msg.sender;
                activeGame[1].funds = msg.value;
                activeGame[1].moveSecret = _moveHash;
                LogPlayer2Joined(msg.sender);
            }

            assert(activeGame.length <= 2);
        }

    ///@notice I am concerned about the nested loops but because the arrays are small and fixed I thought it might be ok
    function revealMove(bytes32 _passKey)
        public
        payable
        twoPlayersJoined
        {
            for(uint8 a = 0; a<2; a++){
                if(activeGame[a].player == msg.sender){
                    for(uint8 i = 1; i<4; i++){
                        bytes32 testHash = keccak256(i,_passKey);
                        if(testHash == activeGame[a].moveSecret){
                            activeGame[a].playerMove = i;
                        }
                    }  
                }
            }

            if(activeGame[0].playerMove != 0 && activeGame[1].playerMove != 0){
                determineWinner();
            }
        }

    function determineWinner()
        internal
    {
        uint256 winnings;

        if(activeGame[0].playerMove != activeGame[1].playerMove){

            if(activeGame[0].playerMove == uint8(RPSMoves.Rock) && activeGame[1].playerMove == uint8(RPSMoves.Paper)){activeGame[1].winner = true;}
            if(activeGame[0].playerMove == uint8(RPSMoves.Rock) && activeGame[1].playerMove == uint8(RPSMoves.Scissors)){activeGame[0].winner = true;}
            if(activeGame[0].playerMove == uint8(RPSMoves.Paper) && activeGame[1].playerMove == uint8(RPSMoves.Rock)){activeGame[0].winner = true;}
            if(activeGame[0].playerMove == uint8(RPSMoves.Paper) && activeGame[1].playerMove == uint8(RPSMoves.Scissors)){activeGame[1].winner = true;}
            if(activeGame[0].playerMove == uint8(RPSMoves.Scissors) && activeGame[1].playerMove == uint8(RPSMoves.Rock)){activeGame[1].winner = true;}
            if(activeGame[0].playerMove == uint8(RPSMoves.Scissors) && activeGame[1].playerMove == uint8(RPSMoves.Paper)){activeGame[0].winner = true;}

            winnings = activeGame[0].funds + activeGame[1].funds;
            activeGame[0].funds = 0;
            activeGame[1].funds = 0;

            if(activeGame[0].winner == true){
                activeGame[0].player.transfer(winnings);
                LogAnnounceWinner(activeGame[0].player, activeGame[0].playerMove, activeGame[1].playerMove, winnings);   
            }

            if(activeGame[1].winner == true){
                activeGame[1].player.transfer(winnings);
                LogAnnounceWinner(activeGame[1].player, activeGame[0].playerMove, activeGame[1].playerMove, winnings);   
            }

        } else {

            uint256 fundsOne = activeGame[0].funds;
            uint256 fundsTwo = activeGame[1].funds;
            
            activeGame[0].funds = 0;
            activeGame[1].funds = 0;
            
            activeGame[0].player.transfer(fundsOne);
            activeGame[1].player.transfer(fundsTwo);  
        }
    }

}