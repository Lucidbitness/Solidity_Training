pragma solidity 0.4.18;

contract RockPaperScissors {
    
    address private owner;
        
    struct RPSGame
        {
            address playerOne;
            address playerTwo;
            uint256 playerOneFunds;
            uint256 playerTwoFunds;
            uint8 playerOneMove;      
            uint8 playerTwoMove; 
        }

    enum RPSMoves{
        NC, Rock, Paper, Scissors
    }
    mapping (uint256 => RPSGame) public activeGame; //address is for the Ether transmitter

    event LogPlayer1Joined(address _playerOne, uint256 _amountDeposited);
    event LogPlayer2Joined(address _playerTwo, uint256 _amountDeposited);
    event LogPlayer1Move(address _playerOne, uint256 _amountDeposited);
    event LogPlayer2Move(address _playerTwo, uint256 _amountDeposited);
    event LogAnnounceWinner(address _winner, uint256 _amount);
    //event TESTINGLogHASH(bytes32 _hash);

    function RockPaperScissors()
            public
        {
            owner = msg.sender;
        }

    function getOwner()
        public
        returns (address)
        {
            return owner;
        }

    ///@notice must send Ether to this function
    function joinGame()
        public
        payable

        {
            if(activeGame[msg.value].playerOneMove != 0){
                    activeGame[msg.value].playerTwoFunds = msg.value;
                    activeGame[msg.value].playerTwo = msg.sender;
                    LogPlayer2Joined(address _playerTwo, uint256 _amountDeposited);
                } else {
                    activeGame[msg.value].playerOneFunds = msg.value;
                    activeGame[msg.value].playerOne = msg.sender;
                    LogPlayer1Joined(address _playerOne, uint256 _amountDeposited);
                }
        }

   

    function determineWinner(address _player, uint8 _rockpaperscissors, uint256 _value)
        internal
        payable
    {
        uint256 winnings;
        bool player1;
        bool player2;

        if(activeGame[_value].playerOneMove != activeGame[_value].playerTwoMove){

            if((activeGame[_value].playerOneMove == RPSMoves.rock) && activeGame[_value].playerTwoMove == RPSMoves.paper){player2 = true;}
            if((activeGame[_value].playerOneMove == RPSMoves.rock) && activeGame[_value].playerTwoMove == RPSMoves.scissors){player1 = true;}
            if((activeGame[_value].playerOneMove == RPSMoves.paper) && activeGame[_value].playerTwoMove == RPSMoves.rock){player1 = true;}
            if((activeGame[_value].playerOneMove == RPSMoves.paper) && activeGame[_value].playerTwoMove == RPSMoves.scissors){player2 = true;}
            if((activeGame[_value].playerOneMove == RPSMoves.scissors) && activeGame[_value].playerTwoMove == RPSMoves.rock){player2 = true;}
            if((activeGame[_value].playerOneMove == RPSMoves.scissors) && activeGame[_value].playerTwoMove == RPSMoves.paper){player1 = true;}

            winnings = activeGame[_value].playerOneFunds + activeGame[_value].playerTwoFunds;
            activeGame[_value].playerOneFunds = 0;
            activeGame[_value].playerTwoFunds = 0;

            if(player1 == true){
                activeGame[_value].playerOne.transfer(winnings);
                LogAnnounceWinner(playerOne, winnings);
            }

            if(player2 == true){
                activeGame[_value].playerTwo.transfer(winnings);
                LogAnnounceWinner(playerTwo, winnings);    
            }


        } else {

            activeGame[_value].playerOne.transfer(activeGame[_value].playerOneFunds);
            activeGame[_value].playerTwo.transfer(activeGame[_value].playerTwoFunds);  
        }

        LogPlayer1Move(activeGame[_value].playerOneMove, _value);
        LogPlayer2Move(activeGame[_value].playerTwoMove, _value);
    }

}
