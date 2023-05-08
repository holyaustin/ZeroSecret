//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.11;

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );

        /*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }

    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return r the sum of two points of G1
    function addition(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-add-failed");
    }

    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(
        G1Point memory p,
        uint s
    ) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-mul-failed");
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(
        G1Point[] memory p1,
        G2Point[] memory p2
    ) internal view returns (bool) {
        require(p1.length == p2.length, "pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(
                sub(gas(), 2000),
                8,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out,
                0x20
            )
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [
                4252822878758300859123897981450591353533073413197771768651442665752259397132,
                6375614351688725206403948262868962793625744043794305715222011528459656738731
            ],
            [
                21847035105528745403288232691147584728191162732299865338377159692350059136679,
                10505242626370262277552901082094356697409835680220590971873171140371331206856
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                6948654939492683560804555618404613475600253001324378290042784721854738775022,
                6144200986087086333492941767981342890488107658160033620578758892584583446325
            ],
            [
                16969220149536693788396881338379632954866782950385059690201389983655797802043,
                6299625403086402802150059521607678356385047196775467519882548071790544498029
            ]
        );
        vk.IC = new Pairing.G1Point[](27);

        vk.IC[0] = Pairing.G1Point(
            4094504221554130127956734244302982930590281821161648626368426491681410192593,
            9149641287324105373274649418738842497216563665446393307169901284081716826909
        );

        vk.IC[1] = Pairing.G1Point(
            13434294938572997814183613865989148787137367027725721831926073815176957645581,
            4450044957793232538040646310547806271217276269724089334316987601347150920701
        );

        vk.IC[2] = Pairing.G1Point(
            13427791861092700602148023516650974352406356788153857953102090410112324793998,
            19050920707233116504511489007901035839516429248011832393143695978525720901866
        );

        vk.IC[3] = Pairing.G1Point(
            5132371171035574623272841017885362370350413526933436238305683580217117276711,
            11700116656113516479848820872352497331946708770744463511364070942319124648499
        );

        vk.IC[4] = Pairing.G1Point(
            3764784510057828791184213458050927040064273655380477819862154694563813927367,
            1196164985138526546907182550862667007278453202581899969537187308087287584460
        );

        vk.IC[5] = Pairing.G1Point(
            13591646382018870933440168760300403536057314197872931536190379301388550350123,
            20139392594351684096561259222958071518407367516649084213199272807534606549706
        );

        vk.IC[6] = Pairing.G1Point(
            11877473473896809908093685738571838511304159361779839992640507417450694992411,
            21056509648243464506008048761378409804832064422137286150279475084163190288341
        );

        vk.IC[7] = Pairing.G1Point(
            11498738275458250522037753477987641089103154881389740968955664895833688003484,
            7960184452548892896207148042729763181585438605067936905240945388235449688704
        );

        vk.IC[8] = Pairing.G1Point(
            5835969581127765315086371182724144365038372081149934377032576486465557370100,
            9843394833083084629907685080102464017060101717280534477309489345895081085693
        );

        vk.IC[9] = Pairing.G1Point(
            2545843186599421779747369180971172274923884326385859364349614891286894878982,
            20085239514191409826711618289770338410397215031070410303976951064861049943450
        );

        vk.IC[10] = Pairing.G1Point(
            6039541409287302144458282137058624768453457557494491137049426087339981354874,
            4769057083964731489086816779435234253353747555964585658236963396479304330253
        );

        vk.IC[11] = Pairing.G1Point(
            2012700951215069894818243605814699904157210423451521734819941711842813646476,
            16566351144769741233928363366432105745200309249273376451704070082175531738428
        );

        vk.IC[12] = Pairing.G1Point(
            14285259287060632054501545055752590552298070825630374420523948468027910474823,
            16222651747826130476938096175875394169788155051429322318226732440913306889522
        );

        vk.IC[13] = Pairing.G1Point(
            3923895579516609204169196428932006945228703688755705809424437300461555967252,
            122048071798292184308184053490966590334039298511357808825212602613305031294
        );

        vk.IC[14] = Pairing.G1Point(
            6772892497258061907480501657274325287654092108287888082768323999334142357927,
            14816675373353257472132700061210741340682820833215876315586409228032202270655
        );

        vk.IC[15] = Pairing.G1Point(
            134193424824906258022881763217875604230542487336321755355726784160610585455,
            5540152781812454900941259641645750003871876617970796911423478610788028780016
        );

        vk.IC[16] = Pairing.G1Point(
            4668803408347981240665803105035679359955671348294760657857140249953652696636,
            16392738523485193270969375889168183408947707411919817935852730598570635551556
        );

        vk.IC[17] = Pairing.G1Point(
            8521838652989526549686461517253168420865565822244572214834239713874701935256,
            18477964695576624922576703546406619868014217707919202529869777610805266649170
        );

        vk.IC[18] = Pairing.G1Point(
            18562163329271204351299560562999523379123673787349540924416466730784747855949,
            14356986650018009851922066556024680477394683107966675632530632411579434276746
        );

        vk.IC[19] = Pairing.G1Point(
            12627628228845153995785855605866379250938887096987810604713010361826366512835,
            10516316214289919887076913987074906501910936619922403499842677783773700296249
        );

        vk.IC[20] = Pairing.G1Point(
            18947499315642291427249847946234419927875753741661332746610131917506576909282,
            16212228149990551739634751581421404016304133713970265038629031721647383589729
        );

        vk.IC[21] = Pairing.G1Point(
            4000105264719018462442857326029329953629738316937576563004020471827404951225,
            1378368657863039495845037554835609382853115362207460083898239233367035340717
        );

        vk.IC[22] = Pairing.G1Point(
            16067612567985246410907273859484711549047482202002091833721559460817986403508,
            12608008566190614352269145023655011472065552905852739742938066838390957976426
        );

        vk.IC[23] = Pairing.G1Point(
            11325077781962838813607725882098659108212570224731473677062173459887150277417,
            47087555578194777391284535760293830885278566342208528340720139593759126121
        );

        vk.IC[24] = Pairing.G1Point(
            19060112401630537624022237410828485928751487156468802624954192632798185833643,
            2422145139760667774132058206046062684880311547510004394798849967921511219698
        );

        vk.IC[25] = Pairing.G1Point(
            803043484776312237446286980025996258470807067802484949247229748355489101007,
            17614127872536405861441877664442016183856272689718293124267722467960371735258
        );

        vk.IC[26] = Pairing.G1Point(
            17021337272535374248664776320348475362158807572136061561774073547964151851302,
            2196442572761782967820582315726388592617090422522218667765159379466450479835
        );
    }

    function verify(
        uint[] memory input,
        Proof memory proof
    ) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(
                input[i] < snark_scalar_field,
                "verifier-gte-snark-scalar-field"
            );
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.IC[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[26] memory input
    ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}

// contract() {
//     addPerson(userEthAddress: string, userEmailSuffix: string, userId: string, proofA: string[2], proofB: ... ) {

//         encodedUserEthAddress = encodeUserEthAddress(userEthAddress)
//         encodedUserEmailSuffixArray = encodeUserEmailSuffix(userEmailSuffix)
//         encodedUserId = encodeUserId(userId)
// ``
//         publicArray = [
//             "1",
//             ...encodedUserId,
//             ...encodedUserEmailSuffixArray,
//             ...encodedUserEthAddress,
//         ]

//         (a, b, c, input) = convertToHex(
//             publicArray,
//             proofA,
//             proofB,
//             proofC
//         )

//         isValid = verifyProof(a, b, c, input)

//         require(isValid == true)

//         // add person to the white list

//     }
// }
