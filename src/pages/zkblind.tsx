import {
  Image,
  Button,
  Paper,
  Grid,
  Center,
  Modal,
  Group,
  TextInput,
} from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import React, { useState, useEffect } from "react";
import { useAccount, useSigner, useNetwork } from "wagmi";
import { ethers } from "ethers";
import { createStyles } from "@mantine/core";
import Link from "next/link";

import { getContractInfo } from "@/utils/contracts";

const useStyles = createStyles((theme) => ({
  post: {
    display: "block",
    lineHeight: 1,
    padding: "8px 12px",
    borderRadius: theme.radius.sm,
    textDecoration: "none",
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[0]
        : theme.colors.gray[7],
    fontSize: theme.fontSizes.lg,
    fontWeight: 500,
    backgroundColor:
      theme.colorScheme === "dark"
        ? theme.colors.dark[6]
        : theme.colors.blue[0],

    [theme.fn.smallerThan("sm")]: {
      borderRadius: 0,
      padding: theme.spacing.md,
    },
  },
  error: {
    display: "block",
    lineHeight: 1,
    padding: "8px 12px",
    borderRadius: theme.radius.sm,
    textDecoration: "none",
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[0]
        : theme.colors.gray[7],
    fontSize: theme.fontSizes.lg,
    fontWeight: 600,
    backgroundColor:
      theme.colorScheme === "dark"
        ? theme.colors.dark[6]
        : theme.colors.blue[0],

    [theme.fn.smallerThan("sm")]: {
      borderRadius: 0,
      padding: theme.spacing.md,
    },
  },
}));

type ZkBlindMessage = {
  id: number;
  message: string;
  suffix: string;
  userId: number;
};

export default function Zkblind() {
  const { classes } = useStyles();
  const [opened, { open, close }] = useDisclosure(false);
  const { chain } = useNetwork();
  const { contractAddress, abi } = getContractInfo(chain?.id);

  const { address } = useAccount();
  const { data: signer } = useSigner();

  const [messages, setMessages] = useState<ZkBlindMessage[]>([]);

  const [isAllowed, setAllowed] = useState<boolean>(false);

  const [message, setMessage] = useState<string>("");
  const [suffix, setSuffix] = useState<string>("");
  const [userId, setUserId] = useState<number>(0);

  const loadFromLocalStorage = () => {
    const savedObj = localStorage.getItem("myObject");
    if (savedObj) {
      setMessages(JSON.parse(savedObj));
    }
  };

  useEffect(() => {
    async function checkUser() {
      if (address && signer) {
        //console.log("contractAddress :", contractAddress, abi);
        const contract = new ethers.Contract(contractAddress, abi, signer);
        let isWhiteListed = await contract.verifyUser(address);
        let data = await contract.whitelistedList(address);

        loadFromLocalStorage();

        setSuffix(ethers.utils.parseBytes32String(data.emailSuffix));
        setUserId(ethers.BigNumber.from(data.userId).toNumber());

        setAllowed(isWhiteListed);
      }
    }

    checkUser();
  }, [signer, contractAddress, abi, address, isAllowed]);

  function postNewMessage() {
    let len = messages.length + 1;
    setMessages([
      ...messages,
      { id: len, message: message, userId: userId, suffix: suffix },
    ]);
    localStorage.setItem(
      "myObject",
      JSON.stringify([
        ...messages,
        { id: len, message: message, userId: userId, suffix: suffix },
      ])
    );
  }

  return (
    <>
      {isAllowed ? (
        <>
          <Modal opened={opened} onClose={close} withCloseButton={true}>
            <TextInput
              placeholder="Your Message"
              size="md"
              radius="md"
              value={message}
              onChange={(event) => setMessage(event.currentTarget.value)}
            />
            <Button mt={10} onClick={() => postNewMessage()}>
              Post
            </Button>
          </Modal>
          <Grid columns={24}>
            <Grid.Col span={6}>
              <Image
                height={250}
                fit="contain"
                src="/Zkblind.png"
                alt="ZkBlind"
              />
              <Center>
                <Group position="center">
                  <Button mt={10} onClick={open}>
                    Message
                  </Button>
                </Group>
              </Center>
            </Grid.Col>
            <Grid.Col span={16}>
              {messages?.map((message: ZkBlindMessage) => (
                <>
                  <Paper
                    key={message.id}
                    mt={10}
                    shadow="sm"
                    p="md"
                    className={classes.post}
                    withBorder
                  >
                    {message.message}
                    <Group key={message.id} position="right">
                      {message.suffix} id: {message.userId}
                    </Group>
                  </Paper>
                </>
              ))}
            </Grid.Col>
          </Grid>
        </>
      ) : (
        <Paper mt={10} shadow="sm" p="md" className={classes.error} withBorder>
          <Image height={250} fit="contain" src="/welcome.png" alt="ZkBlind" />
          <Center>
            Please, <Link href="/whitelist"> Register </Link>
          </Center>
        </Paper>
      )}
    </>
  );
}
