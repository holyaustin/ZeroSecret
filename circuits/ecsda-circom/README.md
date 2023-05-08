

```bash
$ rm ./test/build
$ ./build_eth_addr.sh
Found Phase 1 ptau file
****COMPILING CIRCUIT****

template instances: 199

non-linear constraints: 247380
linear constraints: 0
public inputs: 4
public outputs: 1
private inputs: 0
private outputs: 0
wires: 246844
labels: 2642008

Written successfully: ./build/eth_addr/eth_addr.r1cs
Written successfully: ./build/eth_addr/eth_addr.sym
Written successfully: ./build/eth_addr/eth_addr_cpp/eth_addr.cpp and ./build/eth_addr/eth_addr_cpp/eth_addr.dat
Written successfully: ./build/eth_addr/eth_addr_cpp/main.cpp, circom.hpp, calcwit.hpp, calcwit.cpp, fr.hpp, fr.cpp, fr.asm and Makefile
Written successfully: ./build/eth_addr/eth_addr_js/eth_addr.wat
Written successfully: ./build/eth_addr/eth_addr_js/eth_addr.wasm
Everything went okay, circom safe
DONE (58s)
****GENERATING WITNESS FOR SAMPLE INPUT****
addr 978617770967819762654777740949918972567359649306
DONE (13s)
****GENERATING ZKEY 0****
[INFO]  snarkJS: Reading r1cs
[INFO]  snarkJS: Reading tauG1
[INFO]  snarkJS: Reading tauG2
[INFO]  snarkJS: Reading alphatauG1
[INFO]  snarkJS: Reading betatauG1
[INFO]  snarkJS: Circuit hash:
		ac85e369 552d9c9d 453cfb43 998810c9
		d00295a2 e4ff91be 90d0fe7d 46b5618d
		cd29079c 685d5ee4 341e6827 2b6c58cf
		166175f2 dac3cca1 3e22a34b 58249263
DONE (224s)
****CONTRIBUTE TO THE PHASE 2 CEREMONY****
Enter a random text. (Entropy): test
[INFO]  snarkJS: Circuit Hash:
		ac85e369 552d9c9d 453cfb43 998810c9
		d00295a2 e4ff91be 90d0fe7d 46b5618d
		cd29079c 685d5ee4 341e6827 2b6c58cf
		166175f2 dac3cca1 3e22a34b 58249263
[INFO]  snarkJS: Contribution Hash:
		2a17ecf6 95c59bce 5eb39005 542d8197
		548192e6 96f77b66 00c421d8 5c49253d
		8dc98f8a be1c02f5 57090518 705e36c5
		8e9a7763 7337e8fb ebbab4ac 86a19585
DONE (55s)
****GENERATING FINAL ZKEY****
[INFO]  snarkJS: Contribution Hash:
		ec51bd8b 359a9dab 3b9c664e 7ee18096
		5c85b8cf b3d6ba54 fe73336d 400ccc54
		04953c1a f5212d94 318b437a d60dc9aa
		7e76219f f3877f92 05a0bb6f 05a113d0
DONE (55s)
****VERIFYING FINAL ZKEY****
[INFO]  snarkJS: Reading r1cs
[INFO]  snarkJS: Reading tauG1
[INFO]  snarkJS: Reading tauG2
[INFO]  snarkJS: Reading alphatauG1
[INFO]  snarkJS: Reading betatauG1
[INFO]  snarkJS: Circuit hash:
		ac85e369 552d9c9d 453cfb43 998810c9
		d00295a2 e4ff91be 90d0fe7d 46b5618d
		cd29079c 685d5ee4 341e6827 2b6c58cf
		166175f2 dac3cca1 3e22a34b 58249263
[INFO]  snarkJS: Circuit Hash:
		ac85e369 552d9c9d 453cfb43 998810c9
		d00295a2 e4ff91be 90d0fe7d 46b5618d
		cd29079c 685d5ee4 341e6827 2b6c58cf
		166175f2 dac3cca1 3e22a34b 58249263
[INFO]  snarkJS: -------------------------
[INFO]  snarkJS: contribution #2 Final Beacon phase2:
		ec51bd8b 359a9dab 3b9c664e 7ee18096
		5c85b8cf b3d6ba54 fe73336d 400ccc54
		04953c1a f5212d94 318b437a d60dc9aa
		7e76219f f3877f92 05a0bb6f 05a113d0
[INFO]  snarkJS: Beacon generator: 0102030405060708090a0b0c0d0e0f101112231415161718221a1b1c1d1e1f
[INFO]  snarkJS: Beacon iterations Exp: 10
[INFO]  snarkJS: -------------------------
[INFO]  snarkJS: contribution #1 1st Contributor Name:
		2a17ecf6 95c59bce 5eb39005 542d8197
		548192e6 96f77b66 00c421d8 5c49253d
		8dc98f8a be1c02f5 57090518 705e36c5
		8e9a7763 7337e8fb ebbab4ac 86a19585
[INFO]  snarkJS: -------------------------
[INFO]  snarkJS: ZKey Ok!
DONE (244s)
****EXPORTING VKEY****
[INFO]  snarkJS: EXPORT VERIFICATION KEY STARTED
[INFO]  snarkJS: > Detected protocol: groth16
[INFO]  snarkJS: EXPORT VERIFICATION KEY FINISHED
DONE (2s)
****GENERATING PROOF FOR SAMPLE INPUT****
DONE (13s)
****VERIFYING PROOF FOR SAMPLE INPUT****
[INFO]  snarkJS: OK!
DONE (1s)
```

