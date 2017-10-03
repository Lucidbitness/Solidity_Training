pragma solidity ^0.4.11;

contract Remittance {
    
    address public owner;
        
    struct RemittanceStruct
        {
            uint256 funds;
            uint256 startTime;      //block number, block.blocktime creates errors
            uint256 withdrawalDeadline; //block number maximum before sender can reclaim ether
        }

    mapping (address => RemittanceStruct) remittanceStructs; //address is for the Ether transmitter
    mapping (bytes32 => address) hashOfBothSecrets;

    event LogEtherWithdrawal(address _withdrawalAddress, uint256 _amountWithdrawn);
    event LogNewDeposit(address _depositerAddress, uint256 _amountDeposited, uint256 _blockNumberDeadline);
    
    function Remittance()
            public
        {
            owner = msg.sender;
        }

    function createNewTransaction(bytes32 _hashA, bytes32 _hashB, uint256 _getDeadline)   // bobs hash of "pepperoni" = "0xc84351c4b73a2d32bd39955c427a58b366bac412bea9385dd9a3279a5ac3fe19" 
            external                                                                // carols hash of "pizza" = "0xcb86f5dc722a74d5f66bb7909e04d1fe1da8b4abcebb218e49e6bb3e8bc2c2a4"
            payable
        {
            require(msg.value != 0);//forgot to send money... in the mail?
            require(_hashA != 0); //only possible if they didnt put a hash into the input field
            require(remittanceStructs[msg.sender].startTime + 2 <= _getDeadline); // defines a minimum buffer of 2 blocks
            
            remittanceStructs[msg.sender].funds               = msg.value; //wei
            remittanceStructs[msg.sender].startTime           = block.number;
            remittanceStructs[msg.sender].withdrawalDeadline  = block.number+_getDeadline;

            hashOfBothSecrets[keccak256(_hashA, _hashB)] = msg.sender;
            
            LogNewDeposit(msg.sender, msg.value, remittanceStructs[msg.sender].withdrawalDeadline);
 
        }
 
    function etherTransfer(bytes32 _secretA, bytes32 _secretB)
            external
            payable
            returns(bool success)
        {
            require((_secretA != 0) && (_secretB != 0));
        
            bytes32 hashKeyA = keccak256(_secretA); // hash both plain english secrets, then has the combination
            bytes32 hashKeyB = keccak256(_secretB); // hash both plain english secrets, then has the combination
            bytes32 hashKey = keccak256(hashKeyA, hashKeyB); // hash both plain english secrets, then has the combination
            if(remittanceStructs[hashOfBothSecrets[hashKey]].withdrawalDeadline > block.number){require(msg.sender != hashOfBothSecrets[hashKey]);}
           
            msg.sender.transfer(remittanceStructs[hashOfBothSecrets[hashKey]].funds); 
            hashOfBothSecrets[hashKey] = 0x0; // reset the address
            
            LogEtherWithdrawal(msg.sender, remittanceStructs[hashOfBothSecrets[hashKey]].funds);
          
            return true;
        }
}
