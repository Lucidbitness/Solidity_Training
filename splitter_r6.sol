pragma solidity 0.4.13;

//Revision 6

contract Splitter{
    address public owner;
    address public sender;
    mapping(address=>uint) balances;
    
    event LogSend(address sender, uint splitValue);
    event LogRecipients(address receiver1, uint rec1Value, address receiver2, uint rec2Value);
    event LogWithdrawal(address beneficiary, uint amount);
    
    function Splitter()
        {
            owner = msg.sender;
        }
        
    function untrustedSplit(address receiver1, address receiver2) 
        public 
        payable
        returns(bool success)
        {
            LogSend(msg.sender, msg.value);
            
            require(msg.sender != receiver1 && msg.sender != receiver2);
            require(owner != receiver1 && owner != receiver2);
            require(receiver1 != receiver2);
            
            balances[msg.sender] += msg.value%2;
            balances[receiver1] += msg.value/2;
            balances[receiver2] += msg.value/2;
            
            LogRecipients(receiver1, balances[receiver1], receiver2, balances[receiver2]);
            
            return true;
        }
        
    function untrustedWithdraw()
        external
        returns(uint)
        {
            uint sendValue = balances[msg.sender];
            balances[msg.sender] = 0;
            msg.sender.transfer(sendValue);//I chose send because it returns false if it fails. transfer doesnt return.
            LogWithdrawal(msg.sender, sendValue);
            return sendValue;
            
        }    
        
}