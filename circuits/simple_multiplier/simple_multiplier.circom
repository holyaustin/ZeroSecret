pragma circom 2.1.3;

include "../../node_modules/circomlib/circuits/comparators.circom";

template SimpleMultiplier() {
    // Private input signals
    signal input in[2];

    // Output signal (public)
    signal output out;

    // Create a constraint here saying that our two input signals cannot
    // equal each other.
    component isz = IsZero();
    isz.in <== in[0] - in[1];

    // The IsZero component returns 1 if the input is 0, or 0 otherwise.
    isz.out === 0;

    // Define the greater than and less than components that we'll define 
    // inside the for loop below.
    component gte[2];
    component lte[2];
    
    // We loop through the two signals to compare them.
    for (var i = 0; i < 2; i++) {
        // Both the LessEqThan and GreaterEqThan components take number of 
        // bits as an input. In this case, we want to ensure our inputs are 
        // [0,5], which requires 3 bits (101).
        lte[i] = LessEqThan(3);

        // We put our circuit's input signal as the input signal to the 
        // LessEqThan component and compare it against 5.
        lte[i].in[0] <== in[i];
        lte[i].in[1] <== 5;

        // The LessEqThan component outputs a 1 if the evaluation is true, 
        // 0 otherwise, so we create this equality constraint.
        lte[i].out === 1;

        // We do the same with GreaterEqThan, and also require 3 bits since
        // the range of inputs is still [0,5].
        gte[i] = GreaterEqThan(3);

        // Compare our input with 0 
        gte[i].in[0] <== in[i];
        gte[i].in[1] <== 0;

        // The GreaterEqThan component outputs a 1 if the evaluation is true, 
        // 0 otherwise, so we create this equality constraint.
        gte[i].out === 1;
    }

    // Write a * b into c and then constrain c to be equal to a * b.
    out <== in[0] * in[1];
}

component main = SimpleMultiplier();