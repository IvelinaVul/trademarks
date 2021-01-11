//SPDX-License-Identifier: UNLICENESD
pragma solidity >=0.7.0;

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
    // 6) цел (за собствено ползване / за продажба / за свободно разпространение) -> измисли име
    Purpose private purpose;
    // 7) описание: някво описание
    string private description;
    //// 8) собственик(Object): Пешо Етеров
    address payable private owner;
    //// 9) оторизирани сайтове: sth.com...
    string[] private authorizedSites;
    // 10) официален сайт: trademark.com
    string private officialSite;
    
    //getter //setter
}

//за собствено ползване / за продажба / за свободно разпространение
enum Purpose { privateUsage, sale, freeDistribution }
