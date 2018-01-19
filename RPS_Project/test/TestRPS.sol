pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RPS_v5.sol";

contract TestRPS {

  function testCreateGame() {
    RockPaperScissors rps = new RockPaperScissors();
    
    //address player1 = "0x1123456789000000000000000000000000000000";
    //address player2 = "0x2123456789000000000000000000000000000000";
    bytes32 hashPlayerOneMove = keccak256(bytes32(1));
    //
    

    rps.createGame.value(0.1 ether)(hashPlayerOneMove, 5);
    bytes32 gameID = keccak256(this, hashPlayerOneMove);
    address playerOne;
    address playerTwo;
    address winner;
    bytes32 playerOneMove;
    uint8 playerTwoMove;      
    uint256 betAmount;
    uint256 gameDuration;

    (playerOne, playerTwo, winner, playerOneMove, playerTwoMove, betAmount, gameDuration) = rps.activeGames(gameID);

    Assert.equal(playerOne, this, "Should be the owner address");
    Assert.equal(playerOneMove, hashPlayerOneMove, "Should be player one move hash");
    Assert.equal(betAmount, 0.1 ether, "Should be 0.1 Ethereum");
    Assert.equal(gameDuration, 5, "Should be number five");
  }
}
