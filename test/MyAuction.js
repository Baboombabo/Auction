const { expect } = require("chai");
const { ethers } = require("hardhat");
const product = require("../ignition/modules/product.json");

describe("MyAuction", function () {
  let MyAuction; // contract factory
  let auction; // contract proxy object
  let owner; // contract (auction) owner address
  let bidders; // bidding participants
  const sampleBidAmount = [1,1.2, 1.5, 1.9, 2.1];
  const sampleBidAmountWei = sampleBidAmount.map(amount => ethers.parseEther(amount.toString())); // (Weis)

  beforeEach(async () => {
    MyAuction = await ethers.getContractFactory("MyAuction"); // create contract factory
    // create contract proxy object (all cnstructor's arguments must be used)
    auction = await MyAuction.deploy(product.Brand, product.SerialNumber, product.Duration);
    // get All dummy accounts from the HardHat ethereum simulator
    [owner, ...bidders] = await ethers.getSigners();
  });

  it("should return the information of the product", async () => {
    const [returnedBrand, returnedSerialNumber] = await auction.getProductInfo();
    expect(returnedBrand).to.equal(product.Brand);
    expect(returnedSerialNumber).to.equal(product.SerialNumber);
  });

  // test of bid function
  it("should make a bid", async () => {
    // simulate bidding sequence from predefined amounts
    for (let i = 0; i < sampleBidAmountWei.length; i++) {
      const ct = await auction.connect(bidders[i]);
      const tx = await ct.bid({value: sampleBidAmountWei[i]});
      const receipt = await tx.wait();

      expect(receipt.status).to.equal(1);
      const hBidAmount = await ct.highestBid();
      expect(hBidAmount).to.equal(sampleBidAmountWei[i]);
      
      const bidAmount = await auction.getMyBid(bidders[i]);
      expect(bidAmount).to.equal(sampleBidAmountWei[i]);
    }
  });

    const delay = sec => new Promise(resolve => setTimeout(resolve, sec * 1000)); // delay function sec: seconds
  const AS = {"STARTED": 0, "ENDED": 1, "CANCELLED": 2};
  // test of end auction function
  it("should end the auction", async () => {
    for (let i = 0; i < sampleBidAmountWei.length; i++) {
      const ct = await auction.connect(bidders[i]);
      const tx = await ct.bid({value: sampleBidAmountWei[i]});
      const receipt = await tx.wait();
    }
    const ct = await auction.connect(owner);
    const state1 = await ct.STATE();
    expect(state1).to.equal(AS.STARTED);
    const tx = await ct.endAuction();
    await tx.wait(); // Wait for transaction to be mined (stored on blockchain)
    const state2 = await ct.STATE();
    expect(state2).to.equal(AS.ENDED);
  });

  // test of cancel auction function
  it("should cancel the auction", async () => {
     it("should end the auction", async () => {
    for (let i = 0; i < sampleBidAmountWei.length; i++) {
      const ct = await auction.connect(bidders[i]);
      const tx = await ct.bid({value: sampleBidAmountWei[i]});
      const receipt = await tx.wait();
    }
    const ct = await auction.connect(owner);
    const state1 = await ct.STATE();
    expect(state1).to.equal(AS.STARTED);
    const tx = await ct.cancelAuction();
    await tx.wait(); // Wait for transaction to be mined (stored on blockchain)
    const state2 = await ct.STATE();
    expect(state2).to.equal(AS.CANCELLED);
  });
  });

  // test of withdraw function
  it("should make withdrawals", async () => {
    expect.fail();
  });
});
