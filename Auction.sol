//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

contract Auction{
    bool private isActiveNow;
    uint256 private minBidAmount;				//	минимална сума за надване
    uint256 private initialPrice;				//	стартова цена
    uint256 private highestPrice;               //  най-високата цена към момента
    
    address private owner;
    address payable private highestBidder;      //  текущия адрес с най-висока цена
    
    string private trademarkName;
    
    constructor(string memory _trademarkName,address _owner, uint256  _minBidAmount, uint256  _initialPrice) {
        trademarkName = _trademarkName;
        minBidAmount = _minBidAmount;
        initialPrice = _initialPrice;
        highestPrice = _initialPrice;
        highestBidder = payable(_owner);
        owner = _owner;
        isActiveNow = false;
    }
    
    event StartAuction(string indexed trademarkName, address indexed owner, uint256 indexed highestPrice, uint256  minBidAmount);
    event AuctionResult(string indexed trademarkName, address indexed oldOwner, address indexed newOwner,uint256 soldFor);
    
    modifier isAuctionActive() {
        require(isActiveNow, "Auction is not active!");
        _;
    }
    
    function isActive() external view returns (bool) {
    	return isActiveNow;
    }
    
    function getHighestPrice() external view returns (uint256) {
    	return highestPrice;
    }
    
    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }
    
    function getCurrentMinAllowedBid() external view returns (uint256) {
        return highestPrice + minBidAmount;
    }
    
    function start() external {
        isActiveNow = true;
    	emit StartAuction(trademarkName, owner, highestPrice, minBidAmount); 
    }
    
    function bid(address payable bidder) external payable isAuctionActive {
        if (minBidAmount <= (msg.value - highestPrice)) {                   // Successful bid
            if (owner != highestBidder) {
                highestBidder.transfer(highestPrice);                       // Returns the money of last bidder
            }
            highestPrice = msg.value;
            highestBidder = bidder;
        }
        else {                                                              // Unsuccessful bid then returns the money to the bidder
            payable(bidder).transfer(msg.value);
        }
    }
    
    function close() external {
        isActiveNow = false;
    	if (owner == highestBidder) {
            highestPrice = 0;
        }
           
        emit AuctionResult(trademarkName, owner, highestBidder, highestPrice);
    }
}
