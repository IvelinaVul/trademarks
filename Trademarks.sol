//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;
//for returning string[]
pragma experimental ABIEncoderV2;

contract Administration {
    struct Trademark{
        // 1) името: trademarks  ?? само име или и фрази
        string name;
        // 2) категория: продукт / услуги
        string category;
        // 3) държава: България/Други
        string country;
        // 4) начална дата на патента: 06.01.2012 -> повери типа
        uint256 startDate;
        // 5) срок на валидност - 10, 20, 30 год., завинаги
        uint8 term;
        // 6) цел (за собствено ползване / за продажба / за свободно разпространение)
        Purpose purpose;
        // 7) описание: някво описание
        string description;
        //// 8) собственик
        address owner;
        //// 9) оторизирани сайтове: sth.com...
        string[] authorizedSites;
        // 10) официален сайт: trademark.com
        string  officialSite;
    }
    mapping (string => Trademark) private trademarksNames;	        				// To do Fixing
    string[] private names;  									    // To do Fixing
    Trademark[] private trademarks;
    uint256 private totalGains;
    
    //оправяйте се!!! -> O(lgn)
    mapping (string => Auction) activeAuctions;
    string[] private activeAuctionNames;  //trademarksWithActiveAuction
    address payable private owner;
      
    modifier isOwnerTrademark(string memory trademarkName) {
        require(msg.sender == trademarksNames[trademarkName].owner, "Caller is not owner!");
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
        //comment..
        //owner = msg.sender;
        //string memory magi = "magi";
        //Trademark trade = new Trademark(magi, magi, magi, 1, 1, Purpose.sale, magi, owner, magi);
        //trademarksNames[magi] = trade;
    }
  
    function createAuction(string memory trademarkName, uint128 initialPrice, uint128 minBidAmount) public isOwnerTrademark(trademarkName) isNotActiveAuction(trademarkName) payable{
     	Trademark memory trademark = trademarksNames[trademarkName];
     	Auction auction = new Auction(trademark.name, payable(trademark.owner), minBidAmount, initialPrice);
     	activeAuctions[trademarkName] = auction;
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
        auction.close();
        uint256 highestPrice=auction.getHighestPrice();
        uint256 fee = uint256(highestPrice * 5 / 100);

        address highestBidder=auction.getHighestBidder();
        Trademark memory trademark=trademarksNames[trademarkName];
        
        totalGains += fee;
        if (fee > 0) {
  			owner.transfer(fee);
        }
       
    	payTo(payable(trademark.owner), highestPrice - fee);
    	trademark.owner=highestBidder;
        deleteAuction(trademarkName);
         
    }
     function payTo(address payable toAddress, uint256 amount) public payable {
    	 toAddress.transfer(amount);	 
    }

    
    function participateInAuction(string memory trademarkName) external payable { 
        Auction auction = activeAuctions[trademarkName];
        auction.bid(msg.sender, msg.value);
        if(!auction.isActive()){
            closeAuction(trademarkName);
        }
    } 
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
    //modifier isOwnerTrademark(string memory trademarkName) {
        //require(msg.sender == trademarksNames[trademarkName].getOwner(),"Not an owner of the trademark!");
        //_;
    //}
    
    function stillNotStartDate(string memory trademarkName) public view returns(bool) {
        if(block.timestamp < trademarksNames[trademarkName].startDate) {
            return true;
        }
        return false;
    }
    //проверка дали си собственик и дали датата е започнала
    
    //Отказване от патента (преди датата на стартиране)
   function giveUpOnPatent(string memory trademarkName) external payable isOwnerTrademark(trademarkName){ //they pay to give up,right
       require(stillNotStartDate(trademarkName),"The start date has already come");
       trademarksNames[trademarkName].owner=address(0);
       
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
}
contract Auction{
    string private trademarkName;
    address private owner;

    // uint8 private maxBids;									//	максимум наднавания за акциона
    // uint8 private currentBids;								//	Броят на наддаванията в момента
    
    uint256 private minBidAmount;							//	Минимална сума за надване
    uint256 private initialPrice;							//	Стартова цена

    uint256 private highestPrice;							//	Цената в момента, която е най-висока
    address payable private highestBidder;		            //	Текущия адрес с най-висока цена
    // uint256 private fee;
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
    
    function payTo(address payable toAddress, uint256 amount) public payable {
    	 toAddress.transfer(amount);	 
    }
    
    function bid(address payable bidder, uint256 bidAmount) public payable isAuctionActive {
       
        if (minBidAmount <= (bidAmount - highestPrice)) {
            payTo(highestBidder, highestPrice);
           	highestPrice = bidAmount;
           	highestBidder = bidder;
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
    
    //Стартиране -> начална цена, начална дата, крайна дата -> event //стария собственик - проверка
    //Участие -> само се предлага сума, не се плаща
    //Обявяване на победител -> предложил най-висока цена
    //Смяна на собственика -> вика от administration превод на сумата на собственика и процент/такса за нас
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
