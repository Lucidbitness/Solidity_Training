pragma solidity ^0.4.11;
//hash example, bytes32 0xcb86f5dc722a74d5f66bb7909e04d1fe1da8b4abcebb218e49e6bb3e8bc2c2a4; //pizza
//hash example, bytes32 0x60f3a82a167820585bf5628d0001a89f5844cbd672908df7a76f7f5c9d5b634d; //burgers
contract Remittance {
    
    address public owner;
    uint256 startTime;
        
    struct Transacton
        {
            uint256 funds;
            bytes32 hash;           //32 characters long, max
            uint256 startTime;      //block number, block.blocktime creates errors
            uint256 withdrawalDeadline; //block number maximum before sender can reclaim ether
        }

    mapping (address => Transacton) transaction; //address is for the Ether transmitter
    mapping (bytes32 => address) hash;

    event LogTime(uint256 _time);
    event LogDeadline(uint256 _time);
    event LogEtherWithdrawal(address _sender, uint256 _amount);
    
    function Remittance()
            public
        {
            owner = msg.sender;
        }

    function setTransaction(bytes32 _hash, uint256 _getDeadline)
            internal
        {
            require(msg.value != 0);//forgot to send money... in the mail?
            require(_hash != 0); //only possible if they didnt put one into the input field
            require(transaction[msg.sender].withdrawalDeadline > 20000 + _getDeadline); // gives a buffer of 20,000 blocks
            transaction[msg.sender].funds               = msg.value; //ether
            transaction[msg.sender].hash                = _hash;//one hash cannot be more than 32 long
            transaction[msg.sender].startTime           = block.number;
            transaction[msg.sender].withdrawalDeadline  = _getDeadline;

            hash[_hash]                                 = msg.sender;   

            LogTime(block.number);
            LogDeadline(transaction[msg.sender].withdrawalDeadline);
        }
 
    function etherTransfer(bytes16 _recA, bytes16 _recB) //"piz" = _recA "za"= _recB, recA&B cannot each be more than 16 char long, no extra spaces or zeros
            external
            payable
            returns(bool success)
        {
            require((_recA && _recB) != 0);
            bytes32 hashT = keccak256(_recA, _recB); // hash transfer
            if(block.number < transaction[hash[hashT]].withdrawalDeadline){require(msg.sender != transaction[hash[hashT]]);}
            msg.sender.transfer(transaction[hash[hashT]].funds); 
            LogEtherWithdrawal(msg.sender, transaction[hash[hashT]].funds));
            return true;
        }
}