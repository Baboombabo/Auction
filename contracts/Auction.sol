// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

 abstract contract Auction {
  struct Product {
    string Brand;
    string SerialNumber;
  }

  enum AuctionState {STARTED, ENDED, CANCELLED}
  function bid() virtual payable external;
  function getMyBid(address bidder) virtual public view returns (uint256);
  function endAuction() virtual external;
  function cancelAuction() virtual external;
  function getProductInfo() virtual external  view returns (string memory, string memory);
  function withdraw() virtual external;
  function getHighestBid() virtual public view returns (uint256);

  event WithdrawnEvent(address withdrawer, uint256 amount, uint256 timestamp);
  event EndedEvent(string message, uint256 timestamp);
  event CancelledEvent(string message, uint256 timestamp);
  event BidEvent(address bidder, uint256 amount, uint256 timestamp);
 }