
pragma circom 2.0.2;

include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../ecsda-circom/eth_addr_2.circom";
// include "constants.circom";
// include "../ecsda-circom/ecdsa.circom";

template zkBlind(k) {
    signal input userEmailAddress[2032];
    signal input privkey[k];
    signal input publickey;
    
    // signal input hash[256];
    
    signal output hashout[256];

    component sha256 = Sha256(2032);
    sha256.in <== userEmailAddress;
    hashout <== sha256.out;

    component privToAddr = PrivKeyToAddr(64, k);  // 4
    
    for (var i = 0; i < 4; i++) {
        privToAddr.privkey[i] <== privkey[i];
    }
    privToAddr.publickey <== publickey;

    // publickey === privToAddr.addr;

}

component main {public [userEmailAddress, privkey, publickey]} = zkBlind(4);


// template zkBlind() {
//     signal input userEmailAddress[8];
//     // signal input userEmailSuffix[2032];
    
//     // signal private input userSigR[4];
//     // signal private input userSigS[4];
//     // signal private input userEthAddressSha256Hash[4];
//     // signal private input userPubKey[2][4];

//     signal output userID[256];

//     component sha256Hash = Sha256(2032);

//     for (var i = 0; i < 2032; i++) {
//         sha256Hash.in[i] <== userEmailAddress[i];
//     }

//     for (var i = 0; i < 256; i++) {
//         userID[i] <== sha256Hash.out[i];
//     }
// }

// component main {public [userEmailAddress]} = zkBlind();  // 4