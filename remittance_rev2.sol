pragma solidity ^0.4.11;
//hash example, bytes16,bytes16 0xa9e27dcc1b9977d74860f3fe876ea2e6d89ce35c4629e9fc18f703203d78250f //"piz","za"
contract Remittance {
    
    address public owner;
        
    struct Transacton
        {
            uint256 funds;
            uint256 startTime;      //block number, block.blocktime creates errors
            uint256 withdrawalDeadline; //block number maximum before sender can reclaim ether
        }

    mapping (address => Transacton) transaction; //address is for the Ether transmitter
    mapping (bytes32 => address) hashA;

    event LogBlockNumber(uint256 _time);
    event LogDeadline(uint256 _time);
    event LogEtherWithdrawal(address _sender, uint256 _amount);
    event LogHashT(bytes32 _hashT);
    
    function Remittance()
            public
        {
            owner = msg.sender;
        }

    function setTransaction(bytes32 _hash, uint256 _getDeadline)
            external
            payable
        {
            require(msg.value != 0);//forgot to send money... in the mail?
            require(_hash != 0); //only possible if they didnt put one into the input field
            require(transaction[msg.sender].startTime + 1 <= _getDeadline); // gives a buffer of 20,000 blocks
            
            transaction[msg.sender].funds               = msg.value; //ether
            transaction[msg.sender].startTime           = block.number;
            transaction[msg.sender].withdrawalDeadline  = _getDeadline;

            hashA[_hash]                                = msg.sender;   

            LogBlockNumber(block.number);
            LogDeadline(transaction[msg.sender].withdrawalDeadline);
        }
 
    function etherTransfer(bytes16 _recA, bytes16 _recB) //"piz" = _recA "za"= _recB, recA&B cannot each be more than 16 char long, no extra spaces or zeros
            external
            payable
            returns(bool success)
        {
            require(_recA != 0);
            require(_recB != 0);
            bytes32 hashT = keccak256(_recA, _recB); // hash transfer separated for easy reading
            if(transaction[hashA[hashT]].withdrawalDeadline > block.number){require(msg.sender != hashA[hashT]);}
            msg.sender.transfer(transaction[hashA[hashT]].funds); 
            hashA[hashT] = 0x0;
            
            LogEtherWithdrawal(msg.sender, transaction[hashA[hashT]].funds);
            LogBlockNumber(block.number);
            LogHashT(hashT);
            
            return true;
        }
}