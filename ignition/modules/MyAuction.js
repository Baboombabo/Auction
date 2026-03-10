// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const {Brand, SerialNumber, Duration } = require('./product.json');

module.exports = buildModule("MyAuctionModule", (m) => {
  const brand = m.getParameter("_brand", Brand);
  const serialNumber = m.getParameter("_serial", SerialNumber);
  const duration = m.getParameter("_durationInMinutes", Duration);

  const myAuction = m.contract("MyAuction", [brand, serialNumber, duration]);

  return { myAuction };
});
