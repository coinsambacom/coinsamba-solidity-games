import { ethers } from "hardhat";

async function main() {
  const RussianRouletteFactory = await ethers.getContractFactory(
    "RussianRoulette"
  );
  const RussianRoulette = await RussianRouletteFactory.deploy();

  await RussianRoulette.deployed();

  console.log(`RussianRoulette deployed to ${RussianRoulette.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
