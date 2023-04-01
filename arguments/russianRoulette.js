const { ethers } = require("hardhat");

module.exports = [
  ethers.constants.WeiPerEther.mul(5).div(100), // 0.005
];
