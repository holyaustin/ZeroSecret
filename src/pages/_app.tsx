import "@rainbow-me/rainbowkit/styles.css";
import "@/styles/globals.css";
import type { AppProps } from "next/app";

import { getDefaultWallets, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import { Chain, goerli } from "wagmi/chains";
import { publicProvider } from "wagmi/providers/public";
import { Layout } from "@/components/Layout";

const MantleChain: Chain = {
  id: 5001,
  name: "Mantle",
  network: "mantle",
  nativeCurrency: {
    symbol: "BIT",
    decimals: 18,
    name: "BIT",
  },
  rpcUrls: {
    default: {
      http: ["https://rpc.testnet.mantle.xyz/"],
    },
    public: {
      http: ["https://rpc.testnet.mantle.xyz/"],
    },
  },
  testnet: true,
};

const { chains, provider } = configureChains(
  [goerli, MantleChain],
  [publicProvider()]
);

const { connectors } = getDefaultWallets({
  appName: "My RainbowKit App",
  projectId: "YOUR_PROJECT_ID",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});

export default function App({ Component, pageProps }: AppProps) {
  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </RainbowKitProvider>
    </WagmiConfig>
  );
}
