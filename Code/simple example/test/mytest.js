var B = artifacts.require("B");
var A = artifacts.require("A");


contract('Blah', function(accounts) {


    it('factory design', async() => {

        const AInstance = await A.deployed();
        let output = await AInstance.createB();
        let event1 = output.receipt.logs[0].args[0];
        const BInstance = await B.at(event1);
        output = await BInstance.setValue(31337);
        output = await BInstance.getValue();
        console.log("Result of setting B: ",output.toString());

    });
});
