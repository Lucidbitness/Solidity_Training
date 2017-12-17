pragma solidity 0.4.18;

contract Remittance {
    
    address private owner;
        
    struct RemittanceStruct
        {
            address recipient;
            address remitInitiator;
            uint256 funds;
            uint256 startTime;      
            uint256 withdrawalDeadline; 
        }

    mapping (bytes32 => RemittanceStruct) public remittanceStructs; //address is for the Ether transmitter
    bytes32[] public secretsArr;

    event LogEtherWithdrawal(address _withdrawalAddress, uint256 _amountWithdrawn);
    event LogNewDeposit(address _depositorAddress, uint256 _amountDeposited, uint256 _blockNumberDeadline);

    function Remittance()
            public
        {
            owner = msg.sender;
            secretsArr.push(123);
        }

    function getOwner()
        public
        view
        returns (address)
        {
            return owner;
        }

    ///@notice order matters ensure hashA here is hashA below
    function createNewRemittance(address _recipient, bytes32 _hashA, bytes32 _hashB, uint256 _getDeadline)   
            external                                                                
            payable
        {
            require(msg.value != 0);
            require((_hashA != 0)&&(_hashB != 0));
            require(_getDeadline > 5 && _getDeadline < 25);
            unusedSecrets(_hashA, _hashB);

            secretsArr.push(_hashA);
            secretsArr.push(_hashB);

            bytes32 memKey = keccak256(_hashA, _hashB);

            remittanceStructs[memKey].funds               = msg.value; 
            remittanceStructs[memKey].recipient           = _recipient;
            remittanceStructs[memKey].startTime           = block.number;
            remittanceStructs[memKey].remitInitiator      = msg.sender;
            remittanceStructs[memKey].withdrawalDeadline  = block.number + _getDeadline;

            LogNewDeposit(msg.sender, msg.value, remittanceStructs[memKey].withdrawalDeadline);
 
        }
 
    ///@notice make sure secretA is the same secret as hashA or doesnt work
    function etherTransfer(bytes32 _secretA, bytes32 _secretB)
            external
            payable
            returns(bool success)
        {
            require((_secretA != 0) && (_secretB != 0));
        
            //bytes32 hashKeyA = keccak256(_secretA); 
            //bytes32 hashKeyB = keccak256(_secretB); 
            bytes32 hashKey = keccak256(keccak256(_secretA), keccak256(_secretB)); 

            if(remittanceStructs[hashKey].withdrawalDeadline > block.number){
                if(msg.sender == remittanceStructs[hashKey].remitInitiator){
                    remittanceStructs[hashKey].remitInitiator.transfer(remittanceStructs[hashKey].funds);  
                }
            }
           
            remittanceStructs[hashKey].recipient.transfer(remittanceStructs[hashKey].funds); 
            
            LogEtherWithdrawal(msg.sender, remittanceStructs[hashKey].funds);
          
            return true;
        }
        
    function unusedSecrets(bytes32 _hashA, bytes32 _hashB)
        internal
        view
        returns (bool)
        { 
           
            for(uint256 i = 0; i<secretsArr.length; i++){
                require(secretsArr[i] != _hashA && secretsArr[i] != _hashB);
            }
        }
}
