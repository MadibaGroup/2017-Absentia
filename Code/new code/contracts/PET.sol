pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import  "./ec.sol";
import "./decrypt.sol";
contract PET {
     
    uint256  pts = 115792089237316195423570985008687907852837564279074904382605163141518161494337;
    string[] public st ;

    decrypt finalDec;
    //states
    enum Steps {depositCiphertexts, subtract, Trustee1Pf_Rand, Trustee2Pf_Rand, decryptionStage,End }
    Steps public step;
    bool public isDone = false;
    uint256[]  alpha;

    uint256[] lastInput;
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

    
    constructor(uint256[] memory alice1, uint256[] memory cell) public
    {
        alpha = new uint256[](2);
        alpha[0]=55066263022277343669578718895168534326250603453777594175500187360389116729240;
        alpha[1]=32670510020758816978083085130507043184471273380659243275938904335757337482424;
        st =["depositCiphertexts", "subtract", "Trustee1Pf_Rand", "Trustee2Pf_Rand", "decryptionStage", "End"];

        loadCiphertexts(alice1,cell);
       
    }
    
    mapping(uint => ciphertext) encryptions; 
    // For DH proof
    mapping(uint => ciphertext) DHtuples_c1c2;
    mapping(uint => ciphertext) DHtuples_c1kc2k;
    mapping(uint => ciphertext) DHProof_pf1pf2; //for pf1 and pf2
    mapping(uint => DHProof_scalar) DHProof_scalars;
    mapping(uint => multiplication) multiplications;

    event decryptAddress(address b);
     // event State(Steps step);
    event State(string step);
    event StateAndResult(string step, bool result, uint256 res1, uint256 res2);
    event anEvent(bool a);
    event inVals(uint256 a1, uint256 a2, uint256 a3, uint256 a4);
    function getState() public returns( string memory)
    {   
        return st[uint256(step)];
    }
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


     function calculateHash(uint256[] memory G, uint256 v, uint256[] memory A) public returns(bytes32)
    {
        return sha256(abi.encodePacked(uint2str(G[0]),uint2str(G[1]),uint2str(v),uint2str(A[0]),uint2str(A[1])));
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


    function subElgamal(uint256[] memory x11, uint256[] memory x12, uint256[] memory x21, uint256[] memory x22, uint256[] memory multiplication) public returns(uint256[] memory c1,uint256[] memory c2, bool res)
    {
       
        uint256[] memory res1 = new uint256[](2);
        uint256[] memory res2 = new uint256[](2);

        // ciphertext memory e = encryptions[index];
        uint256[] memory val1 = new uint256[](2);
        uint256[] memory val2 = new uint256[](2);


        val1[0] = multiplication[0];
        val1[1] = multiplication[1];
        val2[0] = multiplication[2];
        val2[1] = multiplication[3];

        // (val1[0], val1[1]) = multiplyScalar( x21[0],  x21[1], pts-1);
        // (val2[0], val2[1]) = multiplyScalar( x22[0],  x22[1], pts-1);
        //   bool res = ecmulVerify(x21,pts-1,val1) && ecmulVerify(x22,pts-1,val2);
        bool res = ecmulVerify(x21,pts-1,val1) && ecmulVerify(x22,pts-1,val2);
        (res1[0], res1[1]) = ec.add(x11[0], x11[1],  val1[0], val1[1]);
        (res2[0], res2[1]) = ec.add(x12[0], x12[1], val2[0], val2[1]);

        return (res1,res2, res);
    } 

   
   
    function loadCiphertexts(uint256[] memory alice1, uint256[] memory cell) public 
    {
        require( step == Steps.depositCiphertexts);
   
        uint256[] memory c1 = new uint256[](2);
        c1[0]=alice1[0];
        c1[1]=alice1[1];
        uint256[] memory c2 = new uint256[](2);
        c2[0]=alice1[2];
        c2[1]=alice1[3];
        ciphertext memory c = ciphertext(c1,c2);
        encryptions[0] = c;

        c1[0]= cell[0];
        c1[1]= cell[1];
        c2[0]= cell[2];
        c2[1]= cell[3];
        c = ciphertext(c1,c2);
        encryptions[1] = c;
       
        step = Steps.subtract; 
        emit State(st[uint256(step)]);
    }


    function PET_subtract(uint256[] memory multiplication) public returns(bool)
    {
        require( step == Steps.subtract);
     
        bool res = false;
        ciphertext memory e = encryptions[0];
        uint256[] memory alice1 = e.c1;
        uint256[] memory alice2 = e.c2;

        e = encryptions[1]; 
        uint256[] memory cell1 = e.c1;
        uint256[] memory cell2 = e.c2;

        uint256[] memory subVal1 = new uint256[](2);
        uint256[] memory subVal2 = new uint256[](2);
        (subVal1,subVal2,res)= subElgamal(cell1,cell2,alice1,alice2,multiplication);
        ciphertext memory d =  ciphertext(subVal1,subVal2);
        DHtuples_c1c2[1] = d;

        if(res)
        step = Steps.Trustee1Pf_Rand;
        return res;
    }


    function DHProve_Rand(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee1Pf_Rand || step == Steps.Trustee2Pf_Rand);
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
        
        res = DHVerifyProof(DHProof_pf1pf2[1].c1, DHProof_pf1pf2[1].c2, s.pf3, m.res11, m.res12, m.res21, m.res22) &&verifyMults(d.c1, d.c2, DHtuples_c1kc2k[1].c1, DHtuples_c1kc2k[1].c2, s.pf3,s.pf4, m.res11, m.res12, m.res21, m.res22); 
        DHtuples_c1c2[1] = ciphertext(DHtuples_c1kc2k[1].c1, DHtuples_c1kc2k[1].c2);
   
        return res;

    }
    function DHProve_Trustee1Pf_Rand(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee1Pf_Rand );
        bool res = false;
        res = DHProve_Rand(input);
        
        if(res)
        step = Steps.Trustee2Pf_Rand;
        emit anEvent(res);
        return res;
    }

     
     function DHProve_Trustee2Pf_Rand(uint256[] memory input) public returns(bool)
    {
        require( step == Steps.Trustee2Pf_Rand );
        bool res = false;
        res = DHProve_Rand(input);
        if(res)
        step = Steps.decryptionStage;
        lastInput = new uint256[] (4);
        ciphertext memory e = DHtuples_c1c2[1];
        uint256[] memory c1 = e.c1;
        uint256[] memory c2 = e.c2;
        lastInput[0] = c1[0];
        lastInput[1] = c1[1];
        lastInput[2] = c2[0];
        lastInput[3] = c2[1];
        emit inVals(lastInput[0],lastInput[1],lastInput[2],lastInput[3]);
        // emit anEvent(res);
        return res;
    }

    
  
    function decryptionStage(uint256[] memory inputVals) public 
    {
        require( step == Steps.decryptionStage );
        
        decrypt finalDec = new decrypt(inputVals);
        step = Steps.End;

        emit decryptAddress(address(finalDec));
    }
   
}