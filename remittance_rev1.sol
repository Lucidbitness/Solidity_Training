pragma solidity 0.4.15;

contract Remittance {
    
    address public owner;
    uint public sentMoney;
    uint256 startTime;
    bytes32 bobSec = 0xcb86f5dc722a74d5f66bb7909e04d1fe1da8b4abcebb218e49e6bb3e8bc2c2a4; //pizza
    bytes32 carolSec =  0x60f3a82a167820585bf5628d0001a89f5844cbd672908df7a76f7f5c9d5b634d;//burgers
 
    event LogTime(uint256 _time);
    event LogEtherWithdrawal(address _sender, uint256 _amount);
    
    function Remittance()
            payable
        {
            owner = msg.sender;
            sentMoney = msg.value;
            startTime = block.timestamp;
            LogTime(now);
        }
 
    function moneyTransfer(bytes32 _bobSecret, bytes32 _carolSecret) //"pizza", "burgers"
            external
            payable
            returns(bool success)
        {
            require(bobSec == keccak256(_bobSecret) && carolSec == keccak256(_carolSecret));
            if(now<startTime + 10 days){require(msg.sender != owner);}
            msg.sender.transfer(sentMoney); 
            LogEtherWithdrawal(msg.sender, sentMoney);
            return true;
        }
}