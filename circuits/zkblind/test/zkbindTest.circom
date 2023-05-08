pragma circom 2.0.2;

include "../zkblind.circom";

component main {public [userEthAddr, userEmailSuffix, userId]} = zkBlind(56);
