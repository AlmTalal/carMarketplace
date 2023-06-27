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


}