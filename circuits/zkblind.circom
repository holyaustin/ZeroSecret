pragma circom 2.0.2;

include "./zkblind/zkblind.circom";

// for wy.dong96@gmail.com, @ is at index 9, 9 * 8 = 72
component main {public [userEthAddr, userEmailSuffix, userId]} = zkBlind(72);
