pragma solidity 0.4.13;

//Revision 5

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
            uint splitValue = msg.value;
            sender = msg.sender;
            LogSend(msg.sender, msg.value);
            
            //assert(sender != owner);
            assert(sender != receiver1 && sender != receiver2);
            assert(owner != receiver1 && owner != receiver2);
            assert(receiver1 != receiver2);
            
            if(splitValue%2!=0){
                balances[msg.sender] += splitValue%2;
                splitValue -= splitValue%2;
            }
            
            balances[receiver1] += splitValue/2;
            balances[receiver2] += splitValue/2;
            
            LogRecipients(receiver1, balances[receiver1], receiver2, balances[receiver2]);
            
            return true;
        }
        
    function untrustedWithdraw()
        external
        returns(uint)
        {
            
            uint sendValue = balances[msg.sender];
            balances[msg.sender] = 0;
            msg.sender.send(sendValue);//I chose send because it returns false if it fails. transfer doesnt return.
            
            if(!msg.sender.send(sendValue)){
                balances[msg.sender] = sendValue; // reverting state because send failed
                return 0;             
            } else {
                LogWithdrawal(msg.sender, sendValue);
                return sendValue;
            }
        }    
        
}