pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/multiplexer.circom";


template emailSuffix(emailSuffixStartingIndex) {
    signal input userEmailAddress[2032];
    signal input userEmailSuffix[16]; // 127 bits

    signal output isValid;

    signal userEmailSuffixBitsArray[2032];

    component num2Bits[16];

    // Convert each userEmailSuffix element to bits
    for (var i = 0; i < 16; i++) {
        num2Bits[i] = Num2Bits(127);
        num2Bits[i].in <== userEmailSuffix[i];
    }

    // Initialize userEmailSuffixBitsArray with 0s
    for (var i = 0; i < 2032; i++) {
        if (i < emailSuffixStartingIndex) {
          userEmailSuffixBitsArray[i] <== userEmailAddress[i];
          // log("i < emailSuffixStartingIndex", userEmailSuffixBitsArray[i]);

        } else {
          var x = (i - emailSuffixStartingIndex) \ 127;
          var y = (i - emailSuffixStartingIndex) % 127;
          userEmailSuffixBitsArray[i] <== num2Bits[x].out[y];
          // log("i >= emailSuffixStartingIndex", x, y, userEmailSuffixBitsArray[i]);
        }
    }

    component isEqual[2032];
    // compare
    for (var i = 0; i < 2032; i++) {
        isEqual[i] = IsEqual();
        isEqual[i].in[0] <== userEmailSuffixBitsArray[i];
        isEqual[i].in[1] <== userEmailAddress[i];
        // log("compare", userEmailSuffixBitsArray[i], userEmailAddress[i]);
    }

    signal isValidArray[2033];
    isValidArray[0] <== 1;
    for (var i = 1; i < 2033; i++) {
        isValidArray[i] <== isEqual[i-1].out * isValidArray[i-1];
    }

    // Output the result
    isValid <== isValidArray[2032]; 
}
