//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

contract Auction{
    string private trademarkName;
    address private owner;
    
    uint256 private minBidAmount;							    //	Минимална сума за надване
    uint256 private initialPrice;							    //	Стартова цена

    uint256 private highestPrice;							    //	Цената в момента, която е най-висока
    address payable private highestBidder;		                //	Текущия адрес с най-висока цена
    bool private isActiveNow;
    
    modifier isAuctionActive() {
        require(isActiveNow, "Auction is not active!");
        _;
    }
    
    constructor(string memory  _trademarkName,address _owner, uint256  _minBidAmount, uint256  _initialPrice) {
        trademarkName = _trademarkName;
        minBidAmount = _minBidAmount;
        initialPrice = _initialPrice;
        highestPrice = _initialPrice;
        highestBidder = payable(_owner);
        owner=_owner;
        isActiveNow=false;
    }
    
    event StartAuction(string indexed trademarkName, address indexed owner, uint256 indexed highestPrice, uint256  minBidAmount);
    event AuctionResult(string indexed trademarkName, address indexed oldOwner, address indexed newOwner,uint256 soldFor);

    function isActive() public view returns(bool){
    	return isActiveNow;
    }
    
    function getHighestBidder() public view returns(address){
        return highestBidder;
    }
    
    function getMinBidAmount() external view returns(uint256){
    	return minBidAmount;
    }

    function getHighestPrice() external view returns(uint256){
    	return highestPrice;
    }
    
    function start() public  {
        isActiveNow=true;
    	emit StartAuction(trademarkName, owner, highestPrice, minBidAmount); 
    }
    
    
    function close() public {
        isActiveNow=false;
    	if (owner == highestBidder) {
        	highestPrice = 0;
        }
           
        emit AuctionResult(trademarkName, owner, highestBidder, highestPrice);
    }
    
    function bid(address payable bidder) public payable isAuctionActive {
        if (minBidAmount <= (msg.value - highestPrice)) {
            highestBidder.transfer(highestPrice);
           	highestPrice = msg.value;
           	highestBidder = bidder;
        }
        else {
            // fix maybe with require?
            payable(bidder).transfer(msg.value);
        }
    }
}
