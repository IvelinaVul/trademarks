//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

import "./Auction.sol";

contract Administration {
    struct Trademark {
        bool exists;
        string name;
        uint8 term;             //в години
        uint256 startDate;
        address owner;
        string category;        //продукт / услуги
        string country;
        string description;
        string  officialSite;
        Purpose purpose;
        string[] authorizedSites;
    }
    enum Purpose {
        privateUsage,       //за собствено ползване
        sale,               //за продажба
        freeDistribution    //за свободно разпространение
    }
    
    uint256 private priceByYear = 30000000000000000; //40$
    uint256 private priceForUpdate = 3000000000000000; //4$
    uint256 private priceForAuthorizedSites = 7000000000000000; //10$
    
    address private admin;
    string[] private trademarksNames;
    mapping (string => Trademark) private trademarks;
    mapping (string => Auction) private activeAuctions;
    mapping (string => bool) private reportedSites;
    
    constructor() {
        admin = msg.sender;
    }
    
    
    //*** PRICES INFORMATION ***//
        
    
    function getPriceByYear() external view returns (uint256) {
        return priceByYear;
    }
    
    function getPriceForUpdate() external view returns (uint256) {
        return priceForUpdate;
    }
    
    function getPriceForSiteAuthorization() external view returns (uint256) {
        return priceForAuthorizedSites;
    }
    
    
    //*** TRADEMARKS ***//
    
    
    modifier nameAvailable(string memory name) {
    	require(checkAvailableTrademarkName(name), "The name already exists!");
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
    
    modifier isOwnerTrademark(string memory trademarkName) {
        require(msg.sender == trademarks[trademarkName].owner, "Caller is not owner!");
        _;
    }
    
    modifier futureStartDateTrademark(string memory name) {
        require(block.timestamp <= trademarks[name].startDate, "Invalid start date!");
        _; 
    }
    
    modifier isSiteAlreadyAuthorized(string memory site,string memory trademarkName) {
        require(this.isSiteAuthorized(site,trademarkName) == false, "The site has been authorized!");
        _;
    }
    
    modifier isSiteAuthorizedForTrademark(string memory site, string memory trademarkName) {
        require(this.isSiteAuthorized(site,trademarkName), "The site hasn't been authorized!");
        _;
    }
    
    modifier isTrademarkRegistered(string memory trademarkName) {
        require(checkAvailableTrademarkName(trademarkName) == false, "The trademark is not registered!");
        _;
    }
    
    modifier notReportedSite(string memory site) {
        require(reportedSites[site] == false, "The site has been reported!");
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
        trademarksNames.push(_name);
    }
    
    function checkAvailableTrademarkName(string memory name) public view returns (bool) {
        if(trademarks[name].exists == false) {
            return true;
        }
        return block.timestamp > trademarks[name].startDate + trademarks[name].term * 365 * 24 * 60 * 60;
    }
    
    function isTrademarkInDate(string memory trademarkName) external view isTrademarkRegistered(trademarkName) returns(bool){
        return block.timestamp >= trademarks[trademarkName].startDate;
    }
    
    function daysUntilAvailableTrademarkName(string memory name) external view returns (uint256) {
        if(checkAvailableTrademarkName(name)) {
            return 0;
        }
        return (trademarks[name].startDate / 60 / 60 / 24 + trademarks[name].term * 365) - block.timestamp / 60 / 60 / 24;
    }
    
    function extendTerm(string memory trademarkName, uint8 newTerm) external payable isOwnerTrademark(trademarkName) enoughMoney(newTerm * priceByYear) {
        trademarks[trademarkName].term += newTerm;
    }
    
    function updateDescription(string memory trademarkName, string memory newDescription) external payable
                                isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate) {
        trademarks[trademarkName].description = newDescription;
    }
    
    function updateCategory(string memory trademarkName, string memory newCategory) external payable
                            isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate){
        trademarks[trademarkName].category = newCategory;
    }
    
    function updateOfficialSite(string memory trademarkName, string memory newSite) external payable
                                isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate){
        trademarks[trademarkName].officialSite = newSite;
    }
    
    function updateStartData(string memory trademarkName, uint256 newStartDate) external payable
                            isOwnerTrademark(trademarkName) enoughMoney(priceForUpdate) futureDate(newStartDate) futureStartDateTrademark(trademarkName) {
        trademarks[trademarkName].startDate = newStartDate;
    }
    
    function addAuthroizedSite(string memory authorizedSite,string memory trademarkName) external payable
                                enoughMoney(priceForAuthorizedSites) notReportedSite(authorizedSite) isSiteAlreadyAuthorized(authorizedSite, trademarkName) {
        if(msg.sender != trademarks[trademarkName].owner) {
            payable(trademarks[trademarkName].owner).transfer(4 * priceForAuthorizedSites / 5);
        }
        trademarks[trademarkName].authorizedSites.push(authorizedSite);
    }
    
    function isSiteAuthorized(string memory site,string memory trademarkName) public view isTrademarkRegistered(trademarkName) returns (bool){
       if(reportedSites[site]) {
            return false;
       }
       for(uint i = 0; i < trademarks[trademarkName].authorizedSites.length; ++i) {
           if(compareStrings(trademarks[trademarkName].authorizedSites[i],site)) {
               return true;
           }
       }
       return false;
    }
    
    function reportAuthroizedSite(string memory site, string memory trademarkName) external
                                    isOwnerTrademark(trademarkName) isSiteAuthorizedForTrademark(site, trademarkName) {
        reportedSites[site] = true;
    }
    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function giveUpOnPatent(string memory trademarkName) external isOwnerTrademark(trademarkName) futureStartDateTrademark(trademarkName) {
        payable(trademarks[trademarkName].owner).transfer(trademarks[trademarkName].term * priceByYear / 2);
        delete trademarks[trademarkName];
        clearPatents();
    }

    
    //*** AUCTIONS ***//
        
    
    modifier isNotActiveAuction(string memory trademarkName) {
    	require(address(activeAuctions[trademarkName])==address(0) || activeAuctions[trademarkName].isActive() == false, "There is no active auction with that name!");
        _;
    }
    
    modifier isActiveAuction(string memory trademarkName) {
    	require(address(activeAuctions[trademarkName])!=address(0) && activeAuctions[trademarkName].isActive(), "There is no active auction with that name!");
        _;
    }
        
    function createAuction(string memory trademarkName, uint128 initialPrice, uint128 minBidAmount) external
                            isOwnerTrademark(trademarkName) isNotActiveAuction(trademarkName) {
     	Trademark memory trademark = trademarks[trademarkName];
     	Auction auction = new Auction(trademark.name, trademark.owner, minBidAmount, initialPrice);
     	activeAuctions[trademarkName] = auction;
        auction.start();
    }    
        
    function activeAuctionForTrademark(string memory trademarkName) external view returns (bool) {
        return address(activeAuctions[trademarkName])!=address(0) && activeAuctions[trademarkName].isActive();
    }
    
    function getCurrentMinAllowedBidForTrademark(string memory trademarkName) external view isActiveAuction(trademarkName) returns (uint256) {
        return activeAuctions[trademarkName].getCurrentMinAllowedBid();
    }
    
    function participateInAuction(string memory trademarkName) external payable isActiveAuction(trademarkName) { 
        Auction auction = activeAuctions[trademarkName];
        auction.bid{value:msg.value}(msg.sender);
    }
        
    function closeAuction(string memory trademarkName) external isOwnerTrademark(trademarkName) isActiveAuction(trademarkName) {
        Auction auction = activeAuctions[trademarkName];
        auction.close();
        uint256 highestPrice=auction.getHighestPrice();
        uint256 fee = uint256(highestPrice * 5 / 100);

        address highestBidder=auction.getHighestBidder();
        Trademark memory trademark=trademarks[trademarkName];
       
        payable(trademark.owner).transfer(highestPrice - fee);
    	trademark.owner=highestBidder;
        delete activeAuctions[trademarkName];
    }
    
    
    //*** ADMIN FUNCTIONS ***//
    
    modifier isAdmin() {
        require(msg.sender == admin, "Caller is not admin!");
        _;
    }
    
    function setPriceByYear(uint256 newPriceByYear) external isAdmin {
        priceByYear = newPriceByYear;
    }
    
    function setPriceForUpdate(uint256 newPriceForUpdate) external isAdmin {
        priceForUpdate = newPriceForUpdate;
    }
    
    function setPriceForAuthorizedSites(uint256 newPriceForAuthorizedSites) external isAdmin {
        priceForAuthorizedSites = newPriceForAuthorizedSites;
    }
    
    function restoreReportedSites(string memory site) external isAdmin {
        reportedSites[site] = false;
    }
    
    function clearExpiredPatents() external isAdmin {
        clearPatents();
    }
    
    function clearPatents() private {
        string[] memory allTrademarksNames = new string[](trademarksNames.length);
        for(uint i = 0; i < trademarksNames.length; ++i) {
            allTrademarksNames[i] = trademarksNames[i];
        }
        delete trademarksNames;
        
        for(uint i = 0; i < allTrademarksNames.length; ++i) {
            if(checkAvailableTrademarkName(allTrademarksNames[i])) {
                delete trademarks[allTrademarksNames[i]];
            } else {
                trademarksNames.push(allTrademarksNames[i]);
            }
        }

        delete allTrademarksNames;
    }
}
