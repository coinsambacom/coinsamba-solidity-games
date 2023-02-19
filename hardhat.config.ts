import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    dashboard: {
      url: "http://localhost:24012/rpc",
      gasPrice: 50000000000,
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: "PNBRYI8K2HYUK81J887V5KYIXQFPQNT2X4",
      bsc: "PNBRYI8K2HYUK81J887V5KYIXQFPQNT2X4",
    },
  },
};

export default config;
