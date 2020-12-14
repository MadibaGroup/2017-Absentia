
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


 contract B{

    uint256 public value;
    constructor() public
    {
        value = 0;
    }

    function setValue(uint256 a) public
    {
        value = a;
    }

    function getValue() public view returns(uint256)
    {
        return value;
    }
}
