pragma circom 2.0.2;

include "../email-suffix.circom";

component main {public [userEmailSuffix]} = emailSuffix(56);
