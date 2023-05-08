pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template userId() {
    signal input userEmailAddress[2032];
    signal input userId;

    signal output isValid;

    component sha256Hash = Sha256(2032);
    for (var i = 0; i < 2032; i++) {
        sha256Hash.in[i] <== userEmailAddress[i];
    }

    component bits2num = Bits2Num(216);

    for (var i=0; i<216; i++) {
        bits2num.in[i] <== sha256Hash.out[255-i];
    }

    component isEqual = IsEqual();
    isEqual.in[0] <== userId;
    isEqual.in[1] <== bits2num.out;

    isValid <== isEqual.out;    
}

component main {public [userId]} = userId();
