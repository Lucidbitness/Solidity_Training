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

    mapping (bytes32 => RemittanceStruct) public remittanceStructs;
    mapping (bytes32 => bool) public usedSecrets;

    event LogTransferRemittance(address _localRemittanceStore, bytes32 _hashkey, uint256 _remittanceAmount);
    event LogTransferRefund(address _remittanceInitiator, uint256 _remittanceAmount);
    event LogNewRemittance(address _depositorAddress, uint256 _amountDeposited,bytes32 memKey, uint256 _blockNumberDeadline);

    function Remittance()
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

    ///@notice order matters ensure hashA here is hashA below
    function createNewRemittance(address _recipient, bytes32 _hashA, bytes32 _hashB, uint256 _getDeadline)   
            external                                                                
            payable
        {
            require(msg.value != 0);
            require((_hashA != 0)&&(_hashB != 0));
            require(_getDeadline > 5 && _getDeadline < 25);
            require(usedSecrets[_hashA] == false && usedSecrets[_hashB] == false);

            usedSecrets[_hashA] = true;
            usedSecrets[_hashB] = true;

            bytes32 memKey = keccak256(_hashA, _hashB);

            remittanceStructs[memKey].funds               = msg.value; 
            remittanceStructs[memKey].recipient           = _recipient;
            remittanceStructs[memKey].startTime           = block.number;
            remittanceStructs[memKey].remitInitiator      = msg.sender;
            remittanceStructs[memKey].withdrawalDeadline  = block.number + _getDeadline;

            LogNewRemittance(msg.sender, remittanceStructs[memKey].funds, memKey, remittanceStructs[memKey].withdrawalDeadline);
 
        }
 
    ///@notice make sure secretA is the same secret as hashA or doesnt work
    function untrustedRemittanceTransfer(bytes32 _secretA, bytes32 _secretB)
            external
            payable
            returns(bool success)
        {
            require(_secretA != 0 && _secretB != 0);
            bytes32 memKey = getRemittanceHash(_secretA, _secretB);
            uint256 amount = remittanceStructs[memKey].funds;
            remittanceStructs[memKey].funds = 0;
            remittanceStructs[memKey].recipient.transfer(amount); 
            
            LogTransferRemittance(msg.sender, getRemittanceHash(_secretA, _secretB), remittanceStructs[memKey].funds);
          
            return true;
        }

    ///@notice make sure secretA is the same secret as hashA or doesnt work
    function untrustedRemittanceRefund(bytes32 _secretA, bytes32 _secretB)
            external
            payable
            returns(bool success)
        {
            bytes32 memKey = getRemittanceHash(_secretA, _secretB);
            require(_secretA != 0 && _secretB != 0);
            require(deadlinePassed(memKey)); 
            
            uint256 amount = remittanceStructs[memKey].funds;
            remittanceStructs[memKey].funds = 0;
              
            remittanceStructs[memKey].remitInitiator.transfer(amount); 
            
            LogTransferRefund(msg.sender, remittanceStructs[memKey].funds);
          
            return true;
        }

    function getRemittanceHash(bytes32 _secretA, bytes32 _secretB)
        internal
        pure
        returns (bytes32)
        {
            bytes32 hashKeyA = keccak256(_secretA); 
            bytes32 hashKeyB = keccak256(_secretB);
            bytes32 memKey = keccak256(hashKeyA, hashKeyB);
            return memKey;
        }

    function deadlinePassed(bytes32 _hashKey)
        internal
        view
        returns (bool)
        {
            return(remittanceStructs[_hashKey].withdrawalDeadline > block.number);
        }
}