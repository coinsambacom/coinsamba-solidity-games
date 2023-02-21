import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("RussianRoulette", function () {
  async function deployFixture() {
    const accounts = await ethers.getSigners();

    const RussianRouletteFactory = await ethers.getContractFactory(
      "RussianRoulette"
    );
    const RussianRoulette = await RussianRouletteFactory.connect(
      accounts[10]
    ).deploy();

    return { RussianRoulette, accounts };
  }

  describe("Owner", function () {
    it("Should change entry price", async function () {
      const { RussianRoulette } = await loadFixture(deployFixture);

      const newEntryPrice = ethers.BigNumber.from(ethers.constants.WeiPerEther);

      const entryPriceBefore = await RussianRoulette.nextEntryPrice();

      await RussianRoulette.setNextEntryPrice(newEntryPrice);

      const entryPriceAfter = await RussianRoulette.nextEntryPrice();

      expect(entryPriceBefore.eq(entryPriceAfter)).to.equal(false);

      expect(entryPriceAfter).to.equal(newEntryPrice);
    });
  });

  describe("Play", function () {
    it("Should work perfectly", async function () {
      const { RussianRoulette, accounts } = await loadFixture(deployFixture);

      const currentRoomIndex = await RussianRoulette.currentRoom();
      const currentRoomDetails = await RussianRoulette.getRoom(
        currentRoomIndex
      );

      const entryPrice = currentRoomDetails[1];

      const referrer = accounts[10];

      const referrerBalanceBefore = await referrer.getBalance();

      for (let player = 1; player <= 6; player++) {
        const acc = accounts[player - 1];

        if (player == 6) {
          await expect(
            RussianRoulette.connect(acc).enter(referrer.address, {
              value: entryPrice,
            })
          )
            .to.emit(RussianRoulette, "PlayerJoined")
            .to.emit(RussianRoulette, "Victim");
        } else {
          await expect(
            RussianRoulette.connect(acc).enter(referrer.address, {
              value: entryPrice,
            })
          ).to.emit(RussianRoulette, "PlayerJoined");
        }
      }

      const referrerBalanceAfter = await referrer.getBalance();

      expect(referrerBalanceAfter.gt(referrerBalanceBefore)).to.equal(true);
      expect(referrerBalanceAfter).to.equal(
        referrerBalanceBefore.add(entryPrice.div(100).mul(6))
      );
    });
  });
});
