pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import  "./ec.sol";

contract decrypt {

    uint256  pts = 115792089237316195423570985008687907852837564279074904382605163141518161494337;
    string[] public st ;

    //states
    enum Steps {Trustee1Pf_PartialDec,Trustee2Pf_PartialDec, FullDec,End }
    Steps public step;
    bool public isDone = false;
    uint256[]  alpha;

    // for table and subtraction values
    struct ciphertext {
        uint256[] c1;
        uint256[] c2;
    }

    struct DHProof_scalar{
        uint256 pf3; 
        uint256 pf4; 
    }

    struct multiplication{
        uint256[]  res11;
        uint256[]  res12;
        uint256[]  res21;
        uint256[]  res22;
    }

    struct DHtuple{
        uint256[]  c1;
        uint256[]  c2;
        uint256[]  c1k;
        uint256[]  c2k;
    }

     mapping(uint => ciphertext) encryptions; 
    // For DH proof
    mapping(uint => ciphertext) DHtuples_c1c2;
    mapping(uint => ciphertext) DHtuples_c1kc2k;
    mapping(uint => ciphertext) DHProof_pf1pf2; //for pf1 and pf2
    mapping(uint => DHProof_scalar) DHProof_scalars;
    mapping(uint => multiplication) multiplications;

    
    constructor(uint256[] memory inputVals) public
    {
        alpha = new uint256[](2);
        alpha[0]=55066263022277343669578718895168534326250603453777594175500187360389116729240;
        alpha[1]=32670510020758816978083085130507043184471273380659243275938904335757337482424;
        st =[ "Trustee1Pf_PartialDec","Trustee2Pf_PartialDec", "FullDec", "End"];
       
        step = Steps.Trustee1Pf_PartialDec; //can be separate function?
        uint256[] memory c1 = new uint256[](2);
        uint256[] memory c2 = new uint256[](2);
  
        c1[0] = inputVals[0];
        c1[1] = inputVals[1];
        c2[0] = inputVals[2];
        c2[1] = inputVals[3];
        ciphertext memory d =  ciphertext(c1,c2);
        DHtuples_c1c2[1] = d;

       
    }
    
    event State(string step);
    event StateAndResult(string step, bool result, uint256 res1, uint256 res2);
    event anEvent(bool a);
   

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function verifyMults(uint256[] memory c1, uint256[] memory c2, uint256[] memory c1k, uint256[] memory c2k, uint256 pf3, uint256 pf4, uint256[] memory res11,
    uint256[] memory res12, uint256[] memory res21, uint256[] memory res22) public returns(bool)
    {
        return ecmulVerify( c1, pf4, res11) && ecmulVerify( c1k,pf3, res12) && ecmulVerify( c2, pf4, res21) && ecmulVerify(c2k, pf3, res22);
    }


    function DHVerifyProof(uint256[] memory pf1, uint256[] memory pf2, uint256 pf3, uint256[] memory res11,
    uint256[] memory res12, uint256[] memory res21, uint256[] memory res22) public returns(bool)
    {
        bool res = false;
        uint256[] memory val1 = new uint256[](2);

        (val1[0], val1[1]) = ec.add(res12[0], res12[1], pf1[0], pf1[1]);
        bool res1 = (res11[0] == val1[0]) && (res11[1] == val1[1]);

        (val1[0], val1[1]) = ec.add(res22[0], res22[1], pf2[0], pf2[1]);
        bool res2 = (res21[0] == val1[0]) && (res21[1] == val1[1]);

        bytes32 hashval = calculateHash2(pf1, pf2);
        bool res3 = (bytes32(pf3) == hashval);
         res = res1 && res2 && res3;
    //    return verifyMults( c1, c2, c1k, c2k, pf3, pf4, res11, res12, res21, res22);
        return res;

    }

    function calculateHash2(uint256[] memory pf1, uint256[] memory pf2) public returns(bytes32)
    {
        return sha256(abi.encodePacked(uint2str(pf1[0]),uint2str(pf1[1]),uint2str(pf2[0]),uint2str(pf2[1])));
    }

    function ecmulVerify(uint256[] memory multiplicand, uint256 scalar, uint256[] memory product) internal  returns(bool verifies)
    {
        require(scalar != 0); // Rules out an ecrecover failure case
        uint256 x = multiplicand[0]; // x ordinate of multiplicand
        uint8 v = multiplicand[1] % 2 == 0 ? 27 : 28; // parity of y ordinate
        // https://ethresear.ch/t/you-can-kinda-abuse-ecrecover-to-do-ecmul-in-secp256k1-today/2384/9
        // Point corresponding to address ecrecover(0, v, x, s=scalar*x) is
        // (x⁻¹ mod GROUP_ORDER) * (scalar * x * multiplicand - 0 * g), i.e.
        // scalar*multiplicand. See https://crypto.stackexchange.com/a/18106
        bytes32 scalarTimesX = bytes32(mulmod(scalar, x, pts));
        address actual = ecrecover(bytes32(0), v, bytes32(x), scalarTimesX);
        // Explicit conversion to address takes bottom 160 bits
        address expected = address(uint256(keccak256(abi.encodePacked(product))));
        return (actual == expected);
    }

    function DHProve_Rand(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee1Pf_PartialDec || step == Steps.Trustee2Pf_PartialDec);
        bool res = false;

        uint256[] memory c1 = new uint256[](2);
        uint256[] memory c2 = new uint256[](2);
        uint256[] memory c3 = new uint256[](2);
        uint256[] memory c4 = new uint256[](2);
        c1[0] = input[0];
        c1[1] = input[1];
        c2[0] = input[2];
        c2[1] = input[3];
        ciphertext memory d =  ciphertext(c1,c2);
        DHtuples_c1kc2k[1] = d;

        c1[0] = input[4];
        c1[1] = input[5];
        c2[0] = input[6];
        c2[1] = input[7];
        d = ciphertext(c1,c2);
        DHProof_pf1pf2[1] = d;

        c1[0] = input[8];
        c1[1] = input[9];
        DHProof_scalar memory s = DHProof_scalar(c1[0], c1[1]);
        DHProof_scalars[1] = s;

        c1[0] = input[10];
        c1[1] = input[11];
        c2[0] = input[12];
        c2[1] = input[13];
        c3[0] = input[14];
        c3[1] = input[15];
        c4[0] = input[16];
        c4[1] = input[17];

        multiplication memory m = multiplication(c1, c2, c3, c4);
        multiplications[1] = m;

        d = DHtuples_c1c2[1];
        res = DHVerifyProof(DHProof_pf1pf2[1].c1, DHProof_pf1pf2[1].c2, s.pf3, m.res11, m.res12, m.res21, m.res22) &&verifyMults(alpha, d.c1, DHtuples_c1kc2k[1].c1, DHtuples_c1kc2k[1].c2, s.pf3,s.pf4, m.res11, m.res12, m.res21, m.res22);
        
        return res;

    }
    function DHProve_Trustee1Pf_PartialDec(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee1Pf_PartialDec);

        bool res = false;
        res = DHProve_Rand(input);
        
        if(res)
        step = Steps.Trustee2Pf_PartialDec;

        emit anEvent(res);
        return res;
    }

     function DHProve_Trustee2Pf_PartialDec(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee2Pf_PartialDec);
     
         bool res = false;
        res = DHProve_Rand(input);
        
        if(res)
        step = Steps.FullDec;
        emit anEvent(res);
        return res;
    }

    
    function FullDecryption(uint256[] memory input) public returns(string memory s, bool r, uint256 r1, uint256 r2)  // returns(bool r)
    {
        require( step == Steps.FullDec);
    
        bool res = false;
        bool find = false;
        uint256[] memory finalCiphertext = new uint256[](2);
        uint256[] memory res2 = new uint256[](2);
        (finalCiphertext[0], finalCiphertext[1]) = ec.add(input[0], input[1],  input[2], input[3]);
        (res2[0], res2[1]) = ec.add( input[4], input[5],  input[6], input[7]);
        uint256[] memory res3 = new uint256[](2);
        res3[0] = input[4];
        res3[1] = input[5];
        res = ecmulVerify(finalCiphertext,pts-1,res3); //multiplicand, uint256 scalar, uint256[] memory product
        if(res)
        step = Steps.End;
        isDone = true;
        // emit State(st[uint256(step)]);
       
        if(res2[0] == 0 && res2[1] == 0)
            find = true;
        emit StateAndResult(st[uint256(step)], find, res2[0],res2[1]);
        require( step == Steps.End);

        
        return (st[uint256(step)], find,res2[0], res2[1]);
        //return res;
    }

}