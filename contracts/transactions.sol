pragma solidity >=0.4.22 <=0.8.19;

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
        //We should try to change this to a uint type array, maybe with a function that converts string to unique number with a key
        //like hashing it would be possible
        string[] boughtCars;
        //spentMoney is for the total amount of money the user has spent, and is only modified after confirming the delivery
        uint256 spentMoney;
        //blockedMoney is for the amount of money that the user has not confirmed to pass to the seller, => 
        //and is only modified after confirming the delivery or after both, seller and buyer canceling the purchase
        uint256 blockedMoney;
    }

    struct Seller{
        //soldCars is only modified after the buyer's confirming of the delivery and it contains the motorId
        //We should try to change this to a uint type array, maybe with a function that converts string to unique number with a key
        //like hashing it would be possible
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
        //We should try to change this to a uint type array, maybe with a function that converts string to unique number with a key
        //like hashing it would be possible
        string motorId;
        uint256 price;
        bool sold;
        address seller;
        address buyer;
    }
}