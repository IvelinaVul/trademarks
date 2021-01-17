//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

contract Administration {

    //Маги
    //Регистриране на нова търговска марка -> O(1) / const -> проверка дали си платил достатъчно
        //не за сега: ако си платил по-малко, да може да доплатиш разликата, не да плащаш цялата сума наново
    //Маги
    //Проверка дали дадено марка е свободна и от/до кога -> O(1) / const
        //дали?
        //от кога?
    //Маги
    //Редактиране на регистрацията на марката (собственик, дата, срок, описание, категория - отделни функции за потребител; заплащане)
    
    //Рали
    //проверка дали си собственик и дали датата е започнала
	    //Рали
    modifier isOwnerTrademark(string memory trademarkName) {
        require(msg.sender == namesTrademarks[trademarkName].getOwner(),"Not an owoner of the trademark!");
         _;
    }
    
    function stillNotStartDate(string memory trademarkName) public view returns(bool) {
        if(block.timestamp < namesTrademarks[trademarkName].getStartDate()) {
            return true;
        }
        return false;
    }
    //проверка дали си собственик и дали датата е започнала
    
    //Отказване от патента (преди датата на стартиране)
    function giveUpOnPatent(string memory trademarkName) external payable isOwnerTrademark(trademarkName){ //they pay to give up,right
        require(stillNotStartDate(trademarkName),"The start date has already come");
        namesTrademarks[trademarkName].setOwner(address(0));
    }

    //Рали
    //Проверка дали търговецът има права по линк на сайт
  //  function hasRights(address user, string memory trademarkName,string memory authorizedSites) external payable returns (bool) {
   //     for(uint i = 0; i< namesTrademarks[trademarkName].getAuthorizedSites(); ++i) {
  //          if()
  //      } will do it soon
  //  }
    //Рали
    //Добавяне на сайт за продажба
    function addAuthorizedSite(string memory trademarkName,string memory site) external payable isOwnerTrademark(trademarkName){
        trademarks[trademarkName].addAuthorizedSites(trademarkName);
       
    }
 

    mapping (string => Trademark) private trademarksNames;	        // To do Fixing
    string[] private names;  									    // To do Fixing
    Trademark[] private trademarks;
    uint256 private totalGains;
    
    //оправяйте се!!! -> O(lgn)
    mapping (string => Auction) activeAuctions;
    string[] private activeAuctionNames;  //trademarksWithActiveAuction
    address payable private owner;
      
    modifier isOwnerTrademark(string memory trademarkName) {
        require(msg.sender == trademarksNames[trademarkName].getOwner(), "Caller is not owner!");
        _;
    }
    
    modifier isActiveAuction(string memory trademarkName) {
    		require(activeAuctions[trademarkName].isActive(), "There is no active auction with that name!");
        _;
    }
    
    modifier isNotActiveAuction(string memory trademarkName) {
    		require(activeAuctions[trademarkName].isActive()  == false, "There is no active auction with that name!");
        _;
    }
  
    constructor() {
        owner = msg.sender;
        string memory magi = "magi";
        Trademark Trademark = new Trademark(magi, magi, magi, 1, 1, Purpose.sale, magi, owner, magi);
        trademarksNames[magi] = Trademark;
    }
  
    function createAuction(string memory trademarkName, uint128 initialPrice, uint128 minBidAmount, uint8 maxBids) public isOwnerTrademark(trademarkName) isNotActiveAuction(trademarkName) payable{
    	Trademark trademark = trademarksNames[trademarkName];
        activeAuctions[trademarkName] = new Auction(trademark, payable(trademark.getOwner()), maxBids, minBidAmount, initialPrice);
        activeAuctionNames.push(trademarkName);
    }
    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function deleteAuction(string memory trademarkName) private {
    	delete activeAuctions[trademarkName];
        string[] memory copyActiveAuctionNames = new string[](activeAuctionNames.length - 1);
        uint j = 0;
        for (uint i = 0; i < activeAuctionNames.length; i++) {
         		if (!compareStrings(activeAuctionNames[i], trademarkName)) {
            		copyActiveAuctionNames[j] = activeAuctionNames[i];
            		j++;
            }
        }
        
        delete activeAuctionNames;
        for (uint i = 0; i < copyActiveAuctionNames.length; i++) {
         		activeAuctionNames.push(copyActiveAuctionNames[i]);
        }
        delete copyActiveAuctionNames;
    }
    
    function closeAuction(string memory trademarkName) public isActiveAuction(trademarkName) isOwnerTrademark(trademarkName) {
        Auction auction = activeAuctions[trademarkName];
        auction.closeAuction();
        uint256 fee = auction.getFee();
        totalGains += fee;
        if (fee > 0) {
  				owner.transfer(fee);
        } 
        deleteAuction(trademarkName);
    }
    
    function participateInAuction(string memory trademarkName) external payable { 
        Auction auction = activeAuctions[trademarkName];
        auction.bid(msg.sender, msg.value);
        if(!auction.isActive()){
            closeAuction(trademarkName);
        }
    }   
}
contract Auction{
    
    Trademark private trademark;
    address private owner;
    
    uint8 private maxBids;									//	максимум наднавания за акциона
    uint8 private currentBids;								//	Броят на наддаванията в момента
    
    uint256 private minBidAmount;							//	Минимална сума за надване
    uint256 private initialPrice;							//	Стартова цена

    uint256 private highestPrice;							//	Цената в момента, която е най-висока
    address payable private highestBidder;		            //	Текущия адрес с най-висока цена
    uint256 private fee;
    
    constructor(Trademark  _trademark, address payable _owner, uint8  _maxBids, uint256  _minBidAmount, uint256  _initialPrice) {
        trademark = _trademark;
        owner = _owner;  
        maxBids = _maxBids;
        minBidAmount = _minBidAmount;
        initialPrice = _initialPrice;
        highestPrice = _initialPrice;
        highestBidder = _owner;
        fee = 0;
    }
    
    event StartAuction(string indexed trademarkName, address indexed owner, uint256 indexed highestPrice, uint256  minBidAmount);
    event AuctionResult(string indexed trademarkName, address indexed oldOwner, address indexed newOwner,uint256 soldFor);

    function isActive() public view returns(bool){
    		return currentBids < maxBids;
    }
    
   	function sellTrademark() private {
    		fee = uint256(highestPrice * 5 / 100);
    		payTo(payable(trademark.getOwner()), highestPrice - fee);
    		trademark.setOwner(highestBidder); 
    }
    
    function start() public {
    		emit StartAuction(trademark.getName(), owner, highestPrice, minBidAmount); 
    }
    
    function closeAuction() public {
    	if (owner == highestBidder) {
        	highestPrice = 0;
        }
        else {
           	sellTrademark();
        }    
        emit AuctionResult(trademark.getName(), owner, highestBidder, highestPrice);
    }
    
    function payTo(address payable toAddress, uint256 amount) public payable {
    	 toAddress.transfer(amount);	 
    }
    
    function bid(address payable bidder, uint256 bidAmount) public payable {
        if (minBidAmount <= (bidAmount - highestPrice)) {
           	payTo(highestBidder, highestPrice);
           	highestPrice = bidAmount;
           	highestBidder = bidder;
            currentBids++;
        }
        else {
        	payTo(bidder, bidAmount);
            //fix maybe with require?
        }
        
   	}
    
    function getMinBidAmount() external view returns(uint256){
    		return minBidAmount;
    }

    function getHighestPrice() external view returns(uint256){
    		return highestPrice;
    }
    
    function getFee() public view returns(uint256){
    	 return fee;
    }

     
   	// sendToAdministrator(oldOwner, currnetOwner, priceAmount);
    // Administration.changeOwner
    
    
    
    
    //Стартиране -> начална цена, начална дата, крайна дата -> event //стария собственик - проверка
    //Участие -> само се предлага сума, не се плаща
    //Обявяване на победител -> предложил най-висока цена
    //Смяна на собственика -> вика от administration превод на сумата на собственика и процент/такса за нас
}

//Маги
contract Trademark{
    // 1) името: trademarks  ?? само име или и фрази
    string private name;
    // 2) категория: продукт / услуги
    string private category;
    // 3) държава: България/Други
    string private country;
    // 4) начална дата на патента: 06.01.2012 -> повери типа
    uint256 private startDate;
    // 5) срок на валидност - 10, 20, 30 год., завинаги
    uint8 private term;
    // 6) цел (за собствено ползване / за продажба / за свободно разпространение)
    Purpose private purpose;
    // 7) описание: някво описание
    string private description;
    //// 8) собственик
    address private owner;
    //// 9) оторизирани сайтове: sth.com...
    string[] private authorizedSites;
    // 10) официален сайт: trademark.com
    string private officialSite;
    
    constructor(string memory _name, string memory _category, string memory _country, uint256 _startDate, uint8 _term, Purpose _purpose, string memory _description, address _owner, string memory _officialSite) {
        name = _name;
        category = _category;
        country = _country;
        startDate = _startDate;
        term = _term;
        purpose = _purpose;
        description = _description;
        owner = _owner;
        officialSite = _officialSite;
    }
    
    function getName() public view returns(string memory){
        return name;
    }
    function getCategory() public view returns(string memory){
        return category;
    }
    function setCategory(string memory _category) public {
        category = _category;
    }
    function getCountry() public view returns(string memory){
        return country;
    }
    /*
    function setCountry(string memory _country) public {
        country = _country;
    }
    */
    function getStartDate() public view returns(uint256){
        return startDate;
    }
    /*
    function setStartDate(uint256 _startDate) public {
        startDate = _startDate;
    }
    */
    function getTerm() public view returns(uint8){
        return term;
    }
    function setTerm(uint8 _term) public {
        term = _term;
    }
    function getPurpose() public view returns(Purpose){
        return purpose;
    }
    function setPurpose(Purpose _purpose) public {
        purpose = _purpose;
    }
    function getDescription() public view returns(string memory){
        return description;
    }
    function getDescription(string memory _description) public {
        description = _description;
    }
    function getOwner() public view returns(address){
        return owner;
    }
    function setOwner(address _owner) public {
        owner = _owner;
    }
    function getAuthorizedSites() public view returns(string[] memory){
        return authorizedSites;
    }
    function addAuthorizedSites(string memory _site) public {
        authorizedSites.push(_site);
    }
    /*
    function checkSiteIfAuthorized(string memory _site) public view returns(bool){
        for(uint i = 0; i < authorizedSites.length; ++i ){
            if() { //compare strings ?!?! // authorizedSites[i] and _site
                return true;
            }
        }
        return false;
    }
    */
    function getOfficialSite() public view returns(string memory){
        return officialSite;
    }
    function setOfficialSite(string memory _officialSite) public {
        officialSite = _officialSite;
    }
}

//за собствено ползване / за продажба / за свободно разпространение
enum Purpose {
    //за собствено ползване
    privateUsage,
    //за продажба
    sale,
    //за свободно разпространение
    freeDistribution
}
