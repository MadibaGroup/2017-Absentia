
var A = artifacts.require("./A.sol");

module.exports = async (deployer, accounts) => {

    accounts = await web3.eth.getAccounts();
    await deployer.deploy(A,accounts[1],accounts[2],accounts[3],accounts[4]);
    AInstance = await A.deployed();
    console.log("A: I was deployed!!!!!");
    console.log(AInstance.address);

};
