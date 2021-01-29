//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

import "./Auction.sol";

contract Administration {
    struct Trademark {
        bool exists;
        string name;
        uint8 term;                 //в години
        uint256 startDate;
        address owner;
        string category;            //продукт / услуги
        string country;
        string description;
        string  officialSite;
        Purpose purpose;            //цел: за собствено ползване / за продажба / за свободно разпространение
        string[] authorizedSites;
    }
    enum Purpose {
        privateUsage,          //за собствено ползване
        sale,                  //за продажба
        freeDistribution       //за свободно разпространение
    }
    
    uint256 constant private priceByYear = 30000000000000000; //40$
    uint256 constant private priceForUpdate = 3000000000000000; //4$
    uint constant private priceForGiveUp = 11000000000000000; //15$
    
    address payable private owner;
    
    mapping (string => Trademark) private trademarks;
    mapping (string => Auction) activeAuctions;
    
    constructor() {
        owner = msg.sender;
    }
        
    function getPriceByYear() external pure returns (uint256) {
        return priceByYear;
    }
    
    function getPriceForUpdate() external pure returns (uint256) {
        return priceForUpdate;
    }
    
    modifier isOwnerTrademark(string memory trademarkName) {
        require(msg.sender == trademarks[trademarkName].owner, "Caller is not owner!");
        _;
    }
    
    modifier nameAvailable(string memory name) {
    	require(checkAvailableTrademarkName(name), "The name already exists!");
        _;
    }
    
    modifier isTrademarkRegistered(string memory trademarkName) {
        require(checkAvailableTrademarkName(trademarkName) == false, "The trademark is not registered!");
        _;
    }
    
    modifier futureDate(uint256 date) {
        require(block.timestamp <= date, "Invalid date!");
        _;
    }
    
    modifier enoughMoney(uint256 amount) {
        require(msg.value >= amount, "Not enough money!"); 
        _; 
    }
    
    function registerNewTrademark(string memory _name, string memory _category, string memory _country, uint256 _startDate, uint8 _term, Purpose _purpose,
                                    string memory _description, string memory _officialSite)
                                    external payable nameAvailable(_name) futureDate(_startDate) enoughMoney(_term * priceByYear) {
                                        
        Trademark memory newTrademark;
        newTrademark.exists = true;
        newTrademark.name = _name;
        newTrademark.category = _category;
        newTrademark.country = _country;
        newTrademark.startDate = _startDate;
        newTrademark.term = _term;
        newTrademark.purpose = _purpose;
        newTrademark.description = _description;
        newTrademark.owner = msg.sender;
        newTrademark.officialSite = _officialSite;
        
        trademarks[_name] = newTrademark;
        
        owner.transfer(msg.value);
    }
    
    modifier futureStartDateTrademark(string memory name) {
        require(block.timestamp <= trademarks[name].startDate, "Not enough money!");
        _; 
    }
    
    function checkAvailableTrademarkName(string memory name) public view returns (bool) {
        if(trademarks[name].exists == false) {
            return true;
        }
        return block.timestamp > trademarks[name].startDate + trademarks[name].term * 365 * 24 * 60 * 60;
    }
    
    function extendTerm(string memory trademarkName, uint8 newTerm) external payable isOwnerTrademark(trademarkName) enoughMoney(newTerm * priceByYear) {
        trademarks[trademarkName].term += newTerm;
        owner.transfer(msg.value);
    }
    
    function updateData(string memory trademarkName, uint256 newStartDate) external payable
                            isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate) futureDate(newStartDate) futureStartDateTrademark(trademarkName) {
        trademarks[trademarkName].startDate = newStartDate;
        owner.transfer(msg.value);
    }
    
    function updateDescription(string memory trademarkName, string memory newDescription) external payable
                                isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate) {
        trademarks[trademarkName].description = newDescription;
        owner.transfer(msg.value);
    }
    
    function updateCategory(string memory trademarkName, string memory newCategory) external payable
                            isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate){
        trademarks[trademarkName].category = newCategory;
        owner.transfer(msg.value);
    }
    
    function updateOfficialSite(string memory trademarkName, string memory newSite) external payable
                                isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate){
        trademarks[trademarkName].officialSite = newSite;
        owner.transfer(msg.value);
    }
    
    function daysUntilAvailableTrademarkName(string memory name) external view returns (uint256) {
        if(checkAvailableTrademarkName(name)) {
            return 0;
        }
        return (trademarks[name].startDate / 60 / 60 / 24 + trademarks[name].term * 365) - block.timestamp / 60 / 60 / 24;
    }
        
    function isTrademarkInDate(string memory trademarkName) public view isTrademarkRegistered(trademarkName) returns(bool){
        if(block.timestamp < trademarks[trademarkName].startDate) {
            return false;
        }
        return true;
    }
        
    modifier isOwnerAdministration() {
        require(msg.sender == owner, "Caller is not owner!");
        _;
    }
    
    //TODO: 50% refund
    function giveUpOnPatent(string memory trademarkName) external payable
                            isOwnerTrademark(trademarkName) futureDate(trademarks[trademarkName].startDate) enoughMoney(priceForGiveUp) {
        owner.transfer(msg.value);
        delete trademarks[trademarkName];
    }

    function isSiteAuthorized(string memory site,string memory trademarkName) public view isTrademarkRegistered(trademarkName) returns (bool){
       for(uint i = 0; i < trademarks[trademarkName].authorizedSites.length; ++i) {
           if(compareStrings(trademarks[trademarkName].authorizedSites[i],site)) {
               return true;
           }
       }
       return false;
    }

    modifier isSiteAlreadyAuthorized(string memory site,string memory trademarkName) {
        require(this.isSiteAuthorized(site,trademarkName)==false, "The site has been authorized!");
        _;
    }

    function addAuthroizedSite(string memory authorizedSite,string memory trademarkName) external payable
                                isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate) isSiteAlreadyAuthorized(authorizedSite,trademarkName){
        trademarks[trademarkName].authorizedSites.push(authorizedSite);
        owner.transfer(msg.value);
    }
    
    //*** AUCTIONS ***//
        
    modifier isActiveAuction(string memory trademarkName) {
    	require(address(activeAuctions[trademarkName])!=address(0) && activeAuctions[trademarkName].isActive(), "There is no active auction with that name!");
        _;
    }
    
    modifier isNotActiveAuction(string memory trademarkName) {
    	require(address(activeAuctions[trademarkName])==address(0) || activeAuctions[trademarkName].isActive()  == false, "There is no active auction with that name!");
        _;
    }
  
    function createAuction(string memory trademarkName, uint128 initialPrice, uint128 minBidAmount) external isOwnerTrademark(trademarkName) isNotActiveAuction(trademarkName) {
     	Trademark memory trademark = trademarks[trademarkName];
     	Auction auction = new Auction(trademark.name, trademark.owner, minBidAmount, initialPrice);
     	activeAuctions[trademarkName] = auction;
        auction.start();
    }
    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function deleteAuction(string memory trademarkName) private {
    	delete activeAuctions[trademarkName];
    }
    
    function closeAuction(string memory trademarkName) external isActiveAuction(trademarkName) isOwnerTrademark(trademarkName) {
        Auction auction = activeAuctions[trademarkName];
        auction.close();
        uint256 highestPrice=auction.getHighestPrice();
        uint256 fee = uint256(highestPrice * 5 / 100);

        address highestBidder=auction.getHighestBidder();
        Trademark memory trademark=trademarks[trademarkName];
        
        if (fee > 0) {
  			owner.transfer(fee);
        }
       
        payable(trademark.owner).transfer(highestPrice - fee);
    	trademark.owner=highestBidder;
        deleteAuction(trademarkName);
    }
    
    function participateInAuction(string memory trademarkName) external payable isActiveAuction(trademarkName) { 
        Auction auction = activeAuctions[trademarkName];
        auction.bid{value:msg.value}(msg.sender);
    } 
}
