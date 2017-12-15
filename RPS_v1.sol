pragma solidity 0.4.18;

contract Remittance {
    
    address private owner;
        
    struct RemittanceStruct
        {
            uint256 funds;
            uint256 startTime;      
            uint256 withdrawalDeadline; 
        }

    mapping (address => RemittanceStruct) public remittanceStructs; //address is for the Ether transmitter
    mapping (bytes32 => address) internal hashOfBothSecrets;

    event LogEtherWithdrawal(address _withdrawalAddress, uint256 _amountWithdrawn);
    event LogNewDeposit(address _depositorAddress, uint256 _amountDeposited, uint256 _blockNumberDeadline);
    event TESTINGLogHASH(bytes32 _hash);

    function Remittance()
            public
        {
            owner = msg.sender;
        }

    function getOwner()
        public
        returns (address)
        {
            return owner;
        }

    ///@notice order matters ensure hashA here is hashA below
    function createNewRemittance(bytes32 _hashA, bytes32 _hashB, uint256 _getDeadline)   
            external                                                                
            payable
        {
            require(msg.value != 0);
            require((_hashA != 0)&&(_hashB != 0));
            require(_getDeadline > 5 && _getDeadline < 25);
            
            remittanceStructs[msg.sender].funds               = msg.value; 
            remittanceStructs[msg.sender].startTime           = block.number;
            remittanceStructs[msg.sender].withdrawalDeadline  = block.number+_getDeadline;

            hashOfBothSecrets[keccak256(_hashA, _hashB)] = msg.sender;

            TESTINGLogHASH(keccak256(_hashA, _hashB));
            LogNewDeposit(msg.sender, msg.value, remittanceStructs[msg.sender].withdrawalDeadline);
 
        }
 
    ///@notice make sure secretA is the same secret as hashA or doesnt work
    function etherTransfer(bytes32 _secretA, bytes32 _secretB)
            external
            payable
            returns(bool success)
        {
            require((_secretA != 0) && (_secretB != 0));
        
            bytes32 hashKeyA = keccak256(_secretA); 
            bytes32 hashKeyB = keccak256(_secretB); 
            bytes32 hashKey = keccak256(hashKeyA, hashKeyB); 

            TESTINGLogHASH(hashKey);

            if(remittanceStructs[hashOfBothSecrets[hashKey]].withdrawalDeadline > block.number){
                require(msg.sender != hashOfBothSecrets[hashKey]);
            }
           
            msg.sender.transfer(remittanceStructs[hashOfBothSecrets[hashKey]].funds); 
            hashOfBothSecrets[hashKey] = 0; 
            
            LogEtherWithdrawal(msg.sender, remittanceStructs[hashOfBothSecrets[hashKey]].funds);
          
            return true;
        }
}
