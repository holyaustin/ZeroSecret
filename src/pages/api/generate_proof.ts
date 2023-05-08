import { generateProof } from "@/lib/generateProof";
import type { NextApiRequest, NextApiResponse } from "next";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const body = req?.body;
  if (body === undefined) {
    return res.status(403).json({ error: "Request has no body" });
  }
  console.log(body);

  const input0 = parseInt(body.input0);
  const input1 = parseInt(body.input1);

  if (
    input0 === undefined ||
    Number.isNaN(input0) ||
    input1 === undefined ||
    Number.isNaN(input1)
  ) {
    return res.status(403).json({ error: "Invalid inputs" });
  }
  const proof = await generateProof(input0, input1);

  if (proof.proof === "") {
    return res.status(403).json({ error: "Proving failed" });
  }

  res.setHeader("Content-Type", "text/json");
  res.status(200).json(proof);
}
