pragma circom 2.0.2;

include "../../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../eth_addr_2.circom";

component main {public [privkey, publickey]} = PrivKeyToAddr(64, 4);  // 4