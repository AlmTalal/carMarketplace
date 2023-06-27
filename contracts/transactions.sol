pragma solidity >=0.4.22 <=0.8.19;

/* 
We should try to change all the string[] of motorIds and the strings of motorId 
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
        //soldCars is only modified after the buyer's confirming of the delivery and it contains the motorId
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
    string[] motorIds;
    //All the cars in the contract, the string will be the motorId
    mapping(string => Car) cars;
    //All the buyers in the contract
    mapping(address => Buyer) buyers;
    //All the sellers in the contract
    mapping(address => Seller) seller;
    //All the money that is waiting for the buyer confirming 
    //(address: buyer, string : motorId, uint: amount of money)
    mapping(address => mapping(string => uint256)) blockedMoney;

    //makes sure that the amount sent is correct
    modifier suficcientBalance(uint256 price){
        require(price == msg.value);
        _;
    }

    

}