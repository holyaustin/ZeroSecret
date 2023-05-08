pragma circom 2.0.2;

include "../ecsda-circom/ecdsa.circom";
include "../ecsda-circom/eth_addr_2.circom";
include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../email-suffix/email-suffix.circom";

template zkBlind(emailSuffixStartingIndex) {
    signal input userId;
    signal input userEmailAddress[2032];
    signal input userEmailSuffix[16]; // 127 bits

    signal input userEthAddr;

    signal input userSigR[4];
    signal input userSigS[4];
    signal input userEthAddressSha256Hash[4];
    signal input userPubKey[2][4];

    signal output isValid;

    // Constraint 1: User ID is SHA-256 of the user email address

    component sha256Hash = Sha256(2032);
    for (var i = 0; i < 2032; i++) {
        sha256Hash.in[i] <== userEmailAddress[i];
    }

    component bits2num = Bits2Num(216);

    for (var i=0; i<216; i++) {
        bits2num.in[i] <== sha256Hash.out[255-i];
    }

    component isUserIdEqual = IsEqual();
    isUserIdEqual.in[0] <== userId;
    isUserIdEqual.in[1] <== bits2num.out;


    // Constraint 2: User email address is the sender in the email


    // Constraint 3: User email address suffix is the suffix of the user email address
    component emailSuffixCheck = emailSuffix(emailSuffixStartingIndex);
    for (var i = 0; i < 2032; i++) {
        emailSuffixCheck.userEmailAddress[i] <== userEmailAddress[i];
    }
    for (var i = 0; i < 16; i++) {
        emailSuffixCheck.userEmailSuffix[i] <== userEmailSuffix[i];
    }

    // Constraint 4: User signature of the ETH address in the email is valid
    component ecdsaVerifyNoPubkeyCheck = ECDSAVerifyNoPubkeyCheck(64, 4);

    for (var i = 0; i < 4; i++) {
        ecdsaVerifyNoPubkeyCheck.r[i] <== userSigR[i];
        ecdsaVerifyNoPubkeyCheck.s[i] <== userSigS[i];
        ecdsaVerifyNoPubkeyCheck.msghash[i] <== userEthAddressSha256Hash[i];
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 4; j++) {
            ecdsaVerifyNoPubkeyCheck.pubkey[i][j] <== userPubKey[i][j];
        }
    }

    // Enforce that the signature is valid
    ecdsaVerifyNoPubkeyCheck.result === 1;

    // Constraint 5: User ETH address and signature is the only email body

    // Constraint 6: User email's dkim signature is valid

    // output if all the constraints are met
    signal isValid1 <== isUserIdEqual.out * ecdsaVerifyNoPubkeyCheck.result;
    isValid <== isValid1 * emailSuffixCheck.isValid;
}
