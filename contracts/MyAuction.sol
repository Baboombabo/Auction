// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Auction.sol";

contract MyAuction is Auction {
    Product public myProduct; //Product Info Record
    address payable public owner; //the owner of the auction
    address public highestBidder; //the address of the highest bidder
    uint    public highestBid; // the amount of the highest bid
    uint    public auctionStarted; // the timestamp od auction starting time
    uint    public auctionEnded; // the timestamp of auction ending/cancelling time
    AuctionState public STATE; // the current state of the auction

    mapping(address => uint) bids; //Table to store all bidding amount (address(key) => amount(value)
    address [] public bidders; // Address of all bidders )

    constructor(string memory _brand, string memory _serial, uint _durationInMinutes) {
        myProduct = Product(_brand, _serial); // Create a new Product record and store all information
        auctionStarted = block.timestamp; // The auction has started right after the auction has been successful deployed
        auctionEnded = auctionStarted + _durationInMinutes * 1 minutes; // The projected ending time of the contract
        owner = payable(msg.sender); // store the owner address
        STATE = AuctionState.STARTED; // The auction has started right after the deployment of this contract
    }

    modifier notAnOwner {
        require(msg.sender != owner, "Owner can not participate in auction");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function getProductInfo() override external view returns (string memory, string memory) {
        return (myProduct.Brand, myProduct.SerialNumber);
    }

    function bid() override notAnOwner payable external {
        require(msg.value + bids [msg.sender] > highestBid, "Can not make a bid, please make a higher bid");
        require(msg.sender != highestBidder, "You are already the highest bidder");
        highestBidder = msg.sender;
        if(bids[msg.sender] == 0) {
            bids[msg.sender] = msg.value;
            bidders.push(msg.sender);
        } else {
            bids[msg.sender] += msg.value;
        }
        highestBid = bids[msg.sender];
        emit BidEvent(msg.sender, bids[msg.sender], block.timestamp);
    }

    function getMyBid(address bidder) override public view returns (uint256) {
        return bids[bidder];
    }
    function endAuction() override onlyOwner external {
        require(STATE == AuctionState.STARTED, "only ongoing auction can be ended");
        STATE = AuctionState.ENDED;
        emit EndedEvent("This auction is over", block.timestamp);
    }
    function cancelAuction() override onlyOwner external {
        require(STATE == AuctionState.STARTED, "only ongoing auction can be canceled");
        STATE = AuctionState.CANCELLED;
        emit CancelledEvent("This auction is cancelLed", block.timestamp);
    }
    function withdraw() override external {
        // There are 3 possible cases
        uint amount;
        if(msg.sender == highestBidder) { // case 1:highest bidder
            require(STATE == AuctionState.CANCELLED, "You can not make a withdraw");
            amount = highestBid; 
        } else if (msg.sender == owner) { // case 2: owner
            require(STATE == AuctionState.ENDED, "Owner can not withdraw");
            amount = highestBid;
            highestBid = 0;
        } else { // case 3: non-winner or non-owner
            require(STATE != AuctionState.STARTED, "You can not withdraw at a moment");
            amount = bids[msg.sender];
            bids[msg.sender] = 0;
        }
        payable(msg.sender).transfer(amount);
        emit WithdrawnEvent(msg.sender, amount, block.timestamp);
    }
    function getHighestBid() override public view returns (uint256) {}
}