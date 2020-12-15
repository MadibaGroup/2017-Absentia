pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract A 
{
    event depositAmount(uint256 a, address sender);

    
    uint256 counter = 0;

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
        // two people pay alice and bob load funds
        //counter ==2 move money from alice and bob to trustees account
    }

    function checkBalances() public
    {
        emit balanceVals( balances[alice], balances[bob], balances[trustee1], balances[trustee2]);
    }
    function loadFund() external payable //only alice and bob
    {
        require(msg.sender == alice || msg.sender == bob);
        balances[msg.sender] = msg.value;
        emit depositAmount(msg.value, msg.sender);
    }
    function loadCiphertexts() public
    {
        require(counter == 0);
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
       
    }
    function doSomething() public 
    {
        require(balances[alice] >= 10);
        require(balances[bob] >= 10);
        counter++;

        //swap money in balances
        if(counter == 2)
        {
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
        }
    }
 
    function withdraw( uint256 amount) payable external nonReentrant()  
    {
        //send to msg.sender check the amount
        require(counter==2 || counter ==0 || now > 30 days + create );
        require(balances[msg.sender]>= amount);
        
        if(msg.sender.send(amount)) 
        balances[msg.sender] = balances[msg.sender] - amount;  
    }

    function sendexcessfunds(uint256 amount) payable external nonReentrant() //withdraw , pass amount balance> amount+fee can be anytime
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
  
    

}

