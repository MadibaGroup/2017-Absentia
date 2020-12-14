var B = artifacts.require("./B.sol");
var A = artifacts.require("./A.sol");

module.exports = async (deployer, accounts) => {

    await deployer.deploy(A);
    AInstance = await A.deployed();
    console.log("A: I was deployed!!!!!");
    console.log(AInstance.address);

};
