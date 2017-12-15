pragma solidity ^0.4.18;

contract Splitter{

    ///@variable contract owner
    address public owner;

    ///@variable used as part of the kill function
    bool public stopDeposits;

    ///@variable create storage for the split instance
    ///would have used memory but would have required transfer eth to be in the main function leading to possible denial of service attack
    struct SplitDetails{
        uint256 depositAmount;
        uint256 recipient1Value;
        uint256 recipient2Value;
        uint256 senderRemainder;
        address recipient1;
        address recipient2;
    }
    
    ///@mapping creating a descriptive mapping of all the possible senders
    mapping(address=>SplitDetails) splitterInstance;
    
    modifier allowDeposits() { 
        require(stopDeposits == false); 
        _; 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }
    
    event LogSplitterInitialization(address _splitInitializer, uint256 _splitValue);
    event LogRecipients(address _receiver1, uint256 _rec1Value, address _receiver2, uint256 _rec2Value);
    event LogWithdrawal(address _beneficiary, uint _amount);
    
    ///@notice contract instatiation
    function Splitter()
        {
            stopDeposits = false;
            owner = msg.sender;
        }

    /*//@notice not efficient but because there could be many instances of the struct the depositAmount will vary    
    ///@param depositor required to find the correct struct instance */ 
    function depositBalance(address _depositor)
        public
        constant
        returns (uint256 _splitAmount)
        {
            return (splitterInstance[_depositor].depositAmount);
        }

    /*//@notice not efficient but because there could be many instances of the struct the depositAmount will vary    
    ///@param depositor required to find the correct struct instance */ 
    function recipientOneBalance(address _depositor)
        public
        constant
        returns (uint256 _splitAmount)
        {
            return (splitterInstance[_depositor].recipient1Value);
        }

    /*//@notice not efficient but because there could be many instances of the struct the depositAmount will vary    
    ///@param depositor required to find the correct struct instance */ 
    function recipientTwoBalance(address _depositor)
        public
        constant
        returns (uint256 _splitAmount)
        {
            return (splitterInstance[_depositor].recipient2Value);
        }

    /*//@notice untrusted because its being called by anyone and provided almost any addresses
    ///@notice doesnt account for one sender sending multiple times to different recipients will over write struct data
    ///@notice if addresses are incorrect than the eth will be misplaced 
    ///@param receiver one address for one of the recipients 
    ///@param receiver two address for the second recipients */
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

            //removes the remainder from the division
            uint256 msgValueResult = msg.value - msg.value%2; 

            splitterInstance[msg.sender].depositAmount = msg.value;
            splitterInstance[msg.sender].recipient1 = _receiver1;
            splitterInstance[msg.sender].recipient2 = _receiver2;
            splitterInstance[msg.sender].recipient1Value += msgValueResult/2;
            splitterInstance[msg.sender].recipient2Value += msgValueResult/2;
            splitterInstance[msg.sender].senderRemainder += msgValueResult;

            LogSplitterInitialization(msg.sender, msg.value);
            LogRecipients(_receiver1, splitterInstance[msg.sender].recipient1Value, _receiver2, splitterInstance[msg.sender].recipient2Value);
            
            return true;
        }
    
    /*//@notice withdrawal function superior to straight transfer
    ///@param depositor is the address of the initial depositor I was having a hard time keeping it simpler
    ///@param withdrawal amount the amount the msg sender wants to withdraw usually in wei */
    function untrustedWithdraw(address _depositor, uint256 _withdrawalAmount)
        external
        returns(bool success)
        {
            // have to check both in the case the this is the second withdrawal call
            require(splitterInstance[_depositor].recipient1Value >= splitterInstance[_depositor].recipient1Value - _withdrawalAmount);
            require(splitterInstance[_depositor].recipient2Value >= splitterInstance[_depositor].recipient2Value - _withdrawalAmount);

            //both instances must be checked to provide the right withdrawal
            if(splitterInstance[_depositor].recipient1 == msg.sender){
                splitterInstance[_depositor].recipient1Value -= _withdrawalAmount;   
            } 

            if(splitterInstance[_depositor].recipient2 == msg.sender){
                splitterInstance[_depositor].recipient2Value -= _withdrawalAmount;   
            }

            //transfer the eth to the msg.sender
            msg.sender.transfer(_withdrawalAmount);
            LogWithdrawal(msg.sender, _withdrawalAmount);

            return true;
            
        } 
    
    ///@notice stops deposits from happening gives time for recipients to take their money out before it gets killed
    function denyDeposits()
        public
        onlyOwner
        returns (bool success)
        {
            stopDeposits = true;
        }

    ///@notice this allows the owner to steal
    ///the eth from everone with eth still in the contract 
    function kill()
        public
        payable
        onlyOwner
        {
            selfdestruct(owner);
        } 
        
}