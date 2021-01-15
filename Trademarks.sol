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
    //Отказване от патента (преди датата на стартиране)
    //Рали
    //Проверка дали търговецът има права по линк на сайт
    //Рали
    //Добавяне на сайт за продажба

    mapping (string => Trademark) private namesTredmarks;
    string[] private names;
    Trademark[] private trademarks;
    uint256 private totalGains;
    
    //оправяйте се!!! -> O(lgn)
    mapping (string => Auction) activeAuctions;
    string[] private activeAuctionNames;
    
    
    constructor(){
        
    }
    
    //function participateInAuction(string name) external{
        //дали има активен търга
    //}
}

contract Auction{
    //event за кой е спечелил
    //търг, без да знаеш най-висока цена
    
    Trademark private trademark; //или само name
    //измисли си тип за дата
    uint256 private startDate;
    uint256  private endDate;
    
    uint256 private initialPrice;
    uint256 private highestPrice;
    address private highestBidder;
    
    //по-скоро без
    //mapping(address => uint256) private bets;
    //address[] private participants;
    
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
    address payable private owner;
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
