pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../contracts/B.sol";

contract A
{

  address[] public contracts2;
  event subcontract (address a);

  constructor() public {
    createB();
  }

  function createB() public
    {
        B contractB = new B();
        contractB.setValue(5);
        contracts2.push(address(contractB));
        emit subcontract(address(contractB));
    }

}
