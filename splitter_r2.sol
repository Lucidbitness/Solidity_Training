pragma solidity 0.4.13;

//ASSUMPTIONS and Comments
//1)Gas is not being accounted for int he perfect split if the value
//2)added more information for others to see untrusted risks
//3)used pull methods to help with DoS and separated outgoing functions

contract Splitter{
    address public owner;
    address public sender;
    address public reciever1;
    uint256 public amount1 = 0;
    address public reciever2;
    uint256 public amount2 = 0;
    uint256 public amountToSplit=0;
    uint256 public value=0;
    
    function Splitter()
        {
            owner = msg.sender;
        }
        
    modifier logic {
        require(reciever1!=owner && reciever2!=owner);
        require(sender!=reciever1 && sender!=reciever2);
        require(reciever1!=reciever2);
            
        assert(reciever1!=0 && reciever2!=0); 
        _;
    }
  
    function untrustedSplit()
        public
        payable
        returns(bool success)
        {
            amountToSplit=msg.value;
            sender=msg.sender;
            
            require(msg.sender!=owner);
            require(amountToSplit>0);
            require(amountToSplit%2==0);
            
            
            value = amountToSplit/2;
            
            amount1 += value;
            amountToSplit -= value;
            
            amount2 += value;
            amountToSplit -= value;
            
            return true;
        }  
        
        function untrustedAddress1(address _reciever1)
                returns(bool success)
                {
                    reciever1 = _reciever1;
                    return true;
                }
                
        function untrustedAddress2(address _reciever2)
                returns(bool success)
                {
                    reciever2 = _reciever2;
                    return true;
                }
    
    function untrustedWithdrawOne() // creates wet code, but reduces the chances of DoS in the case of transfer failure. 
        logic
        external
        returns(uint)
        
        {
            require(msg.sender == reciever1);
            uint refund = amount1;
            amount1 = 0;
            if (!msg.sender.send(refund)) {
                amount1 = refund; // reverting state because send failed
            }
    
            return refund;
        }
        
    function untrustedWithdrawTwo() // creates wet code, but reduces the chances of DoS in the case of transfer failure. 
        logic
        external
        returns(uint)
        {
            require(msg.sender == reciever2);
            uint refund = amount2;
            amount2 = 0;
            if (!msg.sender.send(refund)) {
                amount1 = refund; // reverting state because send failed
            }
            
            return refund;
        }
  
}