pragma solidity 0.4.13;

//Revision 3

contract Splitter{
    address public owner;
    address public sender;
    mapping(address=>uint) balances;
    
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
            
            assert(sender != owner);
            assert(sender != receiver1 && sender != receiver2);
            assert(owner != receiver1 && owner != receiver2);
            assert(receiver1 != receiver2);
            
            if(splitValue%2!=0){
                balances[msg.sender] += splitValue%2;
                splitValue -= splitValue%2;
                sender.transfer(balances[msg.sender]);//return the remainder if its an odd wei
            }
            
            balances[receiver1] += splitValue/2;
            balances[receiver2] += splitValue/2;
            
            return true;
        }
        
        
    function untrustedWithdraw()
        external
        returns(uint)
        {
            //left out asserts and requires as any other address that is not defined will be empty, ie owner/sender
            uint sendValue = balances[msg.sender];
            balances[msg.sender] = 0;
            if (!msg.sender.send(sendValue)) {
                balances[msg.sender] = sendValue; // reverting state because send failed
            }
           
            return sendValue;//this is a check to make sure I knew how much was sent.
        }    
        
  
}