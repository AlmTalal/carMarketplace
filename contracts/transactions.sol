pragma solidity >=0.4.22 <=0.8.19;

/* 
We should try to change all the string[] of motorIDS and the strings of motorId 
to a uint type array or var. Maybe with a function that converts string to unique 
number with a key like hashing it would be possible. The thing is that i don't know if 
we should do it at the contract level or more like at consuming the contract and sending the 
data level.
*/


contract CarTransactions {
    //Emit when the seller puts a new car on sale 
    event CarAddedToSale(
        address  seller,
        uint256 price,
        string motorId,
        uint timestamp
    );

    //Emit when the user buys a car
    event CarBought(
        address buyer,
        address seller,
        uint256 price,
        string motorId
    );

    //Emit when the user confirms that the car was delivered
    event CarDelivered(
        uint timestamp
    );

    //Emit when the sellers withdraws money
    event Withdraw(uint256 amount, uint256 timestamp);

    struct Buyer{
        //BoughtCars is only modified after confirming the delivery and it contains the motorId
        string[] boughtCars;
        //spentMoney is for the total amount of money the user has spent, and is only modified after confirming the delivery
        uint256 spentMoney;
        //blockedMoney is for the amount of money that the user has not confirmed to pass to the seller, => 
        //and is only modified after confirming the delivery or after both, seller and buyer canceling the purchase
        uint256 blockedMoney;
    }

    struct Seller{
        //soldCars, it contains all the cars that has been sold or are being on sale of the seller
        string[] soldCars;
        //earnedMoney is for the total amount of money the user has earned, is only modified 
        //after the buyer's confirming of confirming the delivery
        uint256 earnedMoney;
        //blockedMoney is for the amount of money that the user has not recieved waiting for the seller confirmation, => 
        //and is only modified after confirming the delivery or after both, seller and buyer canceling the purchase
        uint256 blockedMoney;
        //The money that the user has in the contract 
        uint256 currentMoney;
    }

    struct Car{
        string motorId;
        uint256 price;
        bool sold;
        address seller;
        address buyer;
    }

    //the motor id of all the cars that are in the contract (either sold or not)
    string[] public  motorIDS;
    //All the cars in the contract, the string will be the motorId
    mapping(string => Car) public cars;
    //All the buyers in the contract
    mapping(address => Buyer) private  buyers;
    //All the sellers in the contract
    mapping(address => Seller) private sellers;
    //All the money that is waiting for the buyer confirming 
    //(address: buyer, string : motorId, uint: amount of money)
    mapping(address => mapping(string => uint256)) public blockedMoney;
    //All teh blocked money that the contract has
    uint256 public allBlockedMoney;

    //makes sure that the amount sent is correct
    modifier suficcientBalance(string memory motorId){
        require(cars[motorId].price == msg.value,"You did not passed the right amount of money");
        _;
    }

    modifier canWithdraw(uint256 amount){
        require(sellers[msg.sender].currentMoney >= amount, "You Are trying to withdraw more funds than you currently have");
        _;
    }

    function sellCar(string memory motorId, uint256 price) public{
        require(price > 0 ,"Please provide a price");
        //Adding to seller's sold cars
        sellers[msg.sender].soldCars.push(motorId);
        //Adding to the contract total cars 
        motorIDS.push(motorId);
        //Creating the cars struct 
        cars[motorId].motorId = motorId;
        cars[motorId].price = price;
        cars[motorId].seller = msg.sender;
        emit CarAddedToSale(msg.sender, price, motorId, block.timestamp);
    }

    function buyCar(string memory motorId) external payable suficcientBalance(motorId) {
        require(!cars[motorId].sold, "The car is sold");

        //modifying the car struct 
        cars[motorId].sold = true;
        cars[motorId].buyer = msg.sender;
        //Adding blockedMoney to the seller
        sellers[cars[motorId].seller].blockedMoney += msg.value;
        //Adding blockedMoney to the buyer 
        buyers[msg.sender].blockedMoney += msg.value;
        //Adding money to the contract total amount of blocked money
        blockedMoney[msg.sender][motorId] += msg.value;
        allBlockedMoney += msg.value;

        emit CarBought(msg.sender, cars[motorId].seller, msg.value, motorId);
    }

    function approveCarDelivery(string memory motorId) public {
        uint money = blockedMoney[msg.sender][motorId];
        //Seller struct
        Seller storage carSeller = sellers[cars[motorId].seller];
        carSeller.blockedMoney -= money; 
        carSeller.currentMoney += money;
        carSeller.earnedMoney += money;
        //buyer struct
        Buyer storage carBuyer = buyers[msg.sender];
        carBuyer.blockedMoney -= money;
        carBuyer.spentMoney += money;
        carBuyer.boughtCars.push(motorId);
        //decreasing the amount of money that blocked money has 
        allBlockedMoney -= money;
        delete blockedMoney[msg.sender][motorId];
        emit CarDelivered(block.timestamp);
    }

    //When the seller withdraw his money
    function withDraw(uint256 amount) external canWithdraw(amount){
        sellers[msg.sender].currentMoney -= amount;
        (bool sent,) = payable(msg.sender).call{value: amount}("");
        require(sent,"transcation Failed");

        emit Withdraw(amount, block.timestamp);
    }

    function getUserSoldCars() public view returns(string[] memory){
        return sellers[msg.sender].soldCars;
    }  
}