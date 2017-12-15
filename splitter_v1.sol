pragma solidity 0.4.18;

contract Splitter{
    address public owner;
    address public sender;
    
    mapping(address=>uint256) balances;

    event LogSend(address _sender, uint256 _splitValue);
    event LogRecipients(address _receiver1, uint256 _rec1Value, address _receiver2, uint256 _rec2Value);
    event LogWithdrawal(address _beneficiary, uint256 _amount);
    
     modifier allowDeposits() { 
        require(stopDeposits == false); 
        _; 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    function Splitter()
        {
            sender = 0;
            owner = msg.sender;
        }
        
    function untrustedSplit(address _receiver1, address _receiver2) 
        external 
        payable
        allowDeposits
        returns(bool success)
        {
            
            require(msg.sender != _receiver1 && msg.sender != _receiver2);
            require(_receiver1 != 0 && _receiver2 != 0);
            require(_receiver1 != _receiver2);
            require(msg.value > 1 wei);
            

            balances[msg.sender] += msg.value%2;
            balances[_receiver1] += msg.value/2;
            balances[_receiver2] += msg.value/2;
            
            LogSend(msg.sender, msg.value);
            LogRecipients(_receiver1, balances[_receiver1], _receiver2, balances[_receiver2]);
            
            return true;
        }
        
    function untrustedWithdraw(uint256  _withdrawalAmount)
        external
        returns(uint256)
        {
            require(balances[msg.sender] >= balances[msg.sender] - _withdrawalAmount);

            balances[msg.sender] -= _withdrawalAmount;
            msg.sender.transfer(_withdrawalAmount);
            LogWithdrawal(msg.sender, _withdrawalAmount);
            return _withdrawalAmount;
            
        } 

    function kill()
        public
        payable
        onlyOwner
        {
            stopDeposits = true;
            selfdestruct(owner);
        }   
        
}