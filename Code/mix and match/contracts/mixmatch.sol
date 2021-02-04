pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./PET.sol";
import  "./ec.sol";
// import "./finalDecryption.sol";
contract mixmatch 
{
    // string[] public st ;
    // mapping(address => PET) pets;
    PET pet_row1col1; 
    PET pet_row2col1;
    PET pet_row3col1;
    PET pet_row4col1;
    PET pet_row1col2;
    PET pet_row2col2;
    PET pet_row3col2;
    PET pet_row4col2;
    PET finaldec;
    // finalDecryption finalResult;

    uint256 count = 1;
    uint256 outputcount = 0;
    event subcontract (address a);
    event resultRow (uint256 row);
    event rowAddresses(address p1, address p2);
    event finalOutput(uint256 c11, uint256 c12, uint256 c13, uint256 c14);
    event finalAddress(address b);

    // funds
    event balanceVals(uint256 a1, uint256 a2, uint256 a3, uint256 a4);
    mapping(address => uint256) public balances;
    address payable alice;
    address payable bob;
    address payable trustee1;
    address payable trustee2;

    uint256 create; 

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;
    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function withdraw( uint256 amount) payable external nonReentrant() // accidentally moved money once someone starts incrementing counter it is  lockedd 
    {
        //send to msg.sender check the amount
       // require(step == Steps.End || step == Steps.depositCiphertexts || now > 30 days + create );
        require(count == 9 || count == 1 || now > 30 days + create );
        require(balances[msg.sender]>= amount);
        
        if(msg.sender.send(amount)) // send vs transfer one of them exception reentrancy call: unlimited gas reentrancy guard
        balances[msg.sender] = balances[msg.sender] - amount;  // all money,
    }

    function sendexcessfunds(uint256 amount) payable external nonReentrant() //withdraw access, pass amount balance> amount+fee can be anytime
    {
        require(balances[msg.sender] >= amount+10 );
        require(msg.sender == alice || msg.sender == bob);
        if(msg.sender == alice)
        {
            msg.sender.send(amount);
            balances[msg.sender] = balances[msg.sender] -amount;
        }
        if(msg.sender == bob)
        {
            msg.sender.send(amount);
            balances[msg.sender] = balances[msg.sender] - amount;
        }
    }
   

    struct ciphertext {
        uint256[] c1;
        uint256[] c2;
    }
    mapping(uint256 => ciphertext) encryptions; 

    constructor(address payable _alice, address payable _bob, address payable _trustee1, address payable _trustee2) public
    {
        alice= _alice;
        bob = _bob;
        trustee1 = _trustee1;
        trustee2 = _trustee2;

        balances[alice] = alice.balance;
        balances[bob] = bob.balance;
        balances[trustee1] = trustee1.balance; 
        balances[trustee2] = trustee2.balance;
         
        create = now;
        _status =_NOT_ENTERED;
        
    }

    function checkBalances() public
    {
        emit balanceVals( balances[alice], balances[bob], balances[trustee1], balances[trustee2]);
    }
    function loadFund() external payable //only alice and bob
    {
        require( count ==1);
        require(msg.sender == alice || msg.sender == bob);
        balances[msg.sender] = msg.value;
        // emit depositAmount(msg.value, msg.sender);
    }

    function loadOutputs(uint256[] memory output, uint256 startIndex) public 
    {
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        require(count ==1 && outputcount<2 ); //but it will be called twice
        uint256[] memory c1 = new uint256[](2);
        c1[0]=output[0];
        c1[1]=output[1];

        uint256[] memory c2 = new uint256[](2);
        c2[0]=output[2];
        c2[1]=output[3];
        ciphertext memory c = ciphertext(c1,c2);
        encryptions[startIndex] = c;

        c1[0]=output[4];
        c1[1]=output[5];
        c2[0]=output[6];
        c2[1]=output[7];
        c = ciphertext(c1,c2);
        startIndex++;
        encryptions[startIndex] = c;
        outputcount++;
        if(outputcount==2)
            count ++;
}

    
    function createRow1() public 
    {
        require(count == 2);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        pet_row1col1 = new PET();
        pet_row1col2 = new PET();   
        count++;
        emit rowAddresses(address(pet_row1col1),address(pet_row1col2));
    }
    function createRow2() public 
    {
        require(count == 3);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        pet_row2col1 = new PET();
        pet_row2col2 = new PET(); 
        count++;  
        emit rowAddresses(address(pet_row2col1),address(pet_row2col2));
    }

    function createRow3() public 
    {
        require(count == 4);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        pet_row3col1 = new PET();
        pet_row3col2 = new PET(); 
        count++;  
        emit rowAddresses(address(pet_row3col1),address(pet_row3col2));
    }

    function createRow4() public 
    {
        require(count == 5);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        pet_row4col1 = new PET();
        pet_row4col2 = new PET(); 
        count++;  
        emit rowAddresses(address(pet_row4col1),address(pet_row4col2));
    }
 
     function matchingRow(bool[] memory aliceCol, bool[] memory bobCol) public  returns(uint256)
    {
        require(count == 6);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        uint256 row = 1234;
        for (uint i=0; i<4; i++) 
        {
            if(aliceCol[i] && bobCol[i])
            {
                row = i+1;
                break;
            }
        }
        count++;
        emit resultRow(row);
        return row;
    }
    function matchingValue(uint256 index) public
    {
        require(count == 7);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        ciphertext memory e = encryptions[index];
        uint256[] memory c1 = e.c1;
        uint256[] memory c2 = e.c2;
        count++;
        emit finalOutput(c1[0], c1[1], c2[0], c2[1]);
    }
    function createFinalDecryption() public
    {
        require(count == 8);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        // finalResult = new finalDecryption();
        finaldec = new PET();
        count++;
        if(trustee1.send(10))
        {
            balances[trustee1] = 10;
            balances[alice] = balances[alice] -10;
        }
        
        if(trustee2.send(10))
        {
            balances[trustee2] = 10;
            balances[bob] = balances[bob] -10;
        } 
        emit finalAddress(address(finaldec));
    }

} 
