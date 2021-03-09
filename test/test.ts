import { ethers } from "hardhat";
import { Signer, Contract, BigNumber as BN } from "ethers";
import { expect } from "chai";

describe("Test Token Converting", function () {
  let owner: Signer, account1: Signer, account2: Signer, account3: Signer;
  let lttToken: Contract, controller: Contract;

  const decimal: BN = BN.from(10).pow(BN.from(18));

  beforeEach(async function () {
    [owner, account1, account2, account3] = await ethers.getSigners();

    const Controller = await ethers.getContractFactory("LottoController");
    controller = await Controller.deploy();

    // Deploy contracts
    const LottoToken = await ethers.getContractFactory("LottoToken");
    lttToken = await LottoToken.deploy(owner.getAddress(), controller.address);
    await lttToken.deployed();
  });

  it("Contracts deployed successfully", async function () {
    expect(await lttToken.name()).to.equal("LottoToken");
  });

  it("Purchase Token random amount succeed", async function () {
    let minBuyAmount: BN = await lttToken.MinBuyAmount();
    await lttToken
      .connect(account2)
      .BuyTicket({ value: minBuyAmount.toString() });
    const prevBalance = await lttToken.balanceOf(account2.getAddress());

    minBuyAmount = await lttToken.MinBuyAmount();
    await lttToken
      .connect(account2)
      .BuyTicket({ value: minBuyAmount.toString() });
    const nextBalance = await lttToken.balanceOf(account2.getAddress());

    expect(prevBalance.eq(nextBalance.sub(prevBalance))).not.be.true;
  });

  it("Exchange Token random amount succeed", async function () {
    let minBuyAmount: BN = await lttToken.MinBuyAmount();
    await lttToken
      .connect(account2)
      .BuyTicket({ value: minBuyAmount.toString() });
    const prevBalance = await lttToken.balanceOf(account2.getAddress());

    // First exchange
    let minExchangeAmount = await lttToken.MinExchangeAmount();
    await lttToken.connect(account2).ExchangeTicket();
    const nextBalance = await lttToken.balanceOf(account2.getAddress());

    // Second Exchange
    minExchangeAmount = await lttToken.MinExchangeAmount();
    await lttToken.connect(account2).ExchangeTicket();
    const curBalance = await lttToken.balanceOf(account2.getAddress());

    expect(curBalance.sub(nextBalance).eq(nextBalance.sub(prevBalance))).not.be
      .true;
  });

  it("Withdraw from non-owner revert", async function () {
    await expect(lttToken.connect(account2).withdraw(BN.from(100))).to.be
      .reverted;
  });
});
