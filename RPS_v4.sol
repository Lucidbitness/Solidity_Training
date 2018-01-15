pragma solidity 0.4.18;

contract RockPaperScissors {
    
    address private owner;
    
    enum RPSMoves{
        NC, Rock, Paper, Scissors
    }

    struct RPSGame
        {
            address playerOne;
            address playerTwo;
            uint256 playerOneFunds;
            uint256 playerTwoFunds;
            bytes32 playerOneMove;      
            RPSMoves playerTwoMove;
        }

    mapping(bytes32 => RPSGame) public activeGame;
    mapping(address => bytes32) public playerGameHash;
    mapping(address => uint256) public funds;


    event LogGameCreated(address playerOne, address playerTwo, uint256 betAmount);
    event LogPlayerTwoSetMove(RPSMoves playerTwoMove);
    event LogGameResults(bytes32 playerOneMove, RPSMoves playerTwoMove, address);
    event LogQuitGame(address quitPlayer, uint256 funds);
    
    modifier onlyOwner() { 
        require(msg.sender == owner); 
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

    function createGame(bytes32 playerOneMove, address secondPlayer)
        public
        payable

        {   
            require(msg.value > 0.1 ether);
            require(secondPlayer != 0);

            bytes32 gameHash = keccak256(msg.sender, secondPlayer);

            activeGame[gameHash].playerOne = msg.sender;
            activeGame[gameHash].playerOneMove = playerOneMove;
            activeGame[gameHash].playerOneFunds = msg.value;
            activeGame[gameHash].playerTwo = secondPlayer;

            playerGameHash[msg.sender] = gameHash;


            LogGameCreated(msg.sender, secondPlayer, msg.value);
        }

    
    ///@notice once player two sets their move the UI can determine the winner
    function secondPlayerSetMove(RPSMoves playerTwoMove, address firstPlayer)
        public
        payable
        {
            bytes32 gameHash = keccak256(firstPlayer, msg.sender);
            require(msg.sender != activeGame[gameHash].playerOne);
            require(msg.value == activeGame[gameHash].playerOneFunds);
            require(activeGame[gameHash].playerOne == firstPlayer);

            activeGame[gameHash].playerTwoMove = playerTwoMove;
            activeGame[gameHash].playerTwoFunds = msg.value;

            playerGameHash[msg.sender] = gameHash;
        }

    ///@notice UI determines the outcome win or tie and resets game for that hash  
    function finalizeGame(address winner, address firstPlayer, address secondPlayer)
        public
        onlyOwner
        {
            require(firstPlayer != 0 && secondPlayer != 0);

            bytes32 gameHash = keccak256(firstPlayer, secondPlayer);
            if(winner != 0){
                funds[winner] += activeGame[gameHash].playerOneFunds + activeGame[gameHash].playerTwoFunds;
            } else {
                funds[firstPlayer] += activeGame[gameHash].playerOneFunds;
                funds[secondPlayer] += activeGame[gameHash].playerTwoFunds;
            }

            LogGameResults(activeGame[gameHash].playerOneMove, activeGame[gameHash].playerTwoMove, winner);
            
            activeGame[gameHash].playerOneFunds = 0;
            activeGame[gameHash].playerOneMove = bytes32(0);
            activeGame[gameHash].playerTwoFunds = 0;
            activeGame[gameHash].playerTwoMove = RPSMoves(0);

            playerGameHash[firstPlayer] = bytes32(0);
            playerGameHash[secondPlayer] = bytes32(0);
        }

    function quitGame()
        external
        {
            uint256 amount;
            bytes32 gameHash = playerGameHash[msg.sender];
            if(msg.sender == activeGame[gameHash].playerOne){

                amount = activeGame[gameHash].playerOneFunds;
                activeGame[gameHash].playerOneFunds = 0;
                activeGame[gameHash].playerOneMove = bytes32(0);
                funds[msg.sender] += amount;
            }

            if(msg.sender == activeGame[gameHash].playerTwo){

                amount = activeGame[gameHash].playerTwoFunds;
                activeGame[gameHash].playerTwoFunds = 0;
                activeGame[gameHash].playerTwoMove = RPSMoves(0);
                funds[msg.sender] += amount;
            }

            LogQuitGame(msg.sender, amount);

        }


    ///@notice allows participants to withdraw funds win quit or tie
    function withdrawFunds()
        external
        returns(bool withdrawSuccess)
        {
            require(funds[msg.sender] > 0.2 ether);

            uint256 amount = funds[msg.sender];
            funds[msg.sender] = 0;
            msg.sender.transfer(amount);
            return(true);
        }

}