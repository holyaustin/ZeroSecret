import { useState } from "react";
import { Stack, Text, Grid, Input, Space, Button } from "@mantine/core";
import axios, { AxiosRequestConfig } from "axios";
import { notifications } from "@mantine/notifications";
import { executeTransaction } from "@/lib/executeTransaction";

export default function Home() {
  const [input0, setInput0] = useState("");
  const [input1, setInput1] = useState("");

  const handleGenerateProofSendTransaction = async (e: any) => {
    e.preventDefault();

    // We will send an HTTP request with our inputs to our next.js backend to
    // request a proof to be generated.
    const data = {
      input0,
      input1,
    };
    const config: AxiosRequestConfig = {
      headers: {
        "Content-Type": "application/json",
      },
    };

    // Send the HTTP request
    try {
      const res = await axios.post("/api/generate_proof", data, config);
      notifications.show({
        message: "Proof generated successfully! Submitting transaction...",
        color: "green",
      });

      // Split out the proof and public signals from the response data
      const { proof, publicSignals } = res.data;

      // Write the transaction
      const txResult = await executeTransaction(proof, publicSignals);
      const txHash = txResult.transactionHash;

      notifications.show({
        message: `Transaction succeeded! Tx Hash: ${txHash}`,
        color: "green",
        autoClose: false,
      });
    } catch (err: any) {
      const statusCode = err?.response?.status;
      const errorMsg = err?.response?.data?.error;
      notifications.show({
        message: `Error ${statusCode}: ${errorMsg}`,
        color: "red",
      });
    }
  };

  return (
    <>
      <Stack justify="center" align="center" w="100vw" h="100vh" spacing={0}>
        <Stack align="center" spacing={0}>
          <Grid align="center" justify="center" mih="80vh">
            <Grid.Col sm={8} md={6} lg={4}>
              <Text>
                {
                  "Input two numbers between 0 and 5, inclusive. The two numbers must \
                not be equal. We'll generate a ZK proof locally in the browser, and \
                only the proof will be sent to the blockchain so that no one \
                watching the blockchain will know the two numbers."
                }
              </Text>
              <Space h={20} />
              <form onSubmit={handleGenerateProofSendTransaction}>
                <Stack spacing="sm">
                  <Input.Wrapper label="Input 0">
                    <Input
                      placeholder="Number between 0 and 5"
                      value={input0}
                      onChange={(e) => setInput0(e.currentTarget.value)}
                    />
                  </Input.Wrapper>
                  <Input.Wrapper label="Input 1">
                    <Input
                      placeholder="Number between 0 and 5"
                      value={input1}
                      onChange={(e) => setInput1(e.currentTarget.value)}
                    />
                  </Input.Wrapper>
                  <Button type="submit">
                    Generate Proof & Send Transaction
                  </Button>
                </Stack>
              </form>
            </Grid.Col>
          </Grid>
        </Stack>
      </Stack>
    </>
  );
}
