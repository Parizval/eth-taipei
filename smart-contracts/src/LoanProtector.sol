// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Protocols To Be Integrated
// 1. Aave
// 2. Hyperlane
// 3. Wormhole
// 4. Circle CCTP
// 5. Uniswap

struct OrderDetails{
    uint32 destinationChainId;



    // Order Tip Details 
    address tipTokenAdress;
    uint256 tipAmount;
}




contract LoanProtector {

    // State variables
    address public owner;

    mapping(bytes32 => OrderDetails) public orders; 



    receive() external payable {
        // Function to receive Ether. msg.data must be empty
    }
 


    function createOrder(
        address conditionAddress,
        uint16 conditionId,
        uint256 conditionAmount,

        uint32 destinationChainId,
        address tipTokenAdress,
        uint256 tipAmount
    ) external OnlyOwner{



        // Generate a unique order ID
        bytes32 orderId = generateKey(conditionAddress, conditionId, conditionAmount);

        // Create the order details
        OrderDetails memory newOrder = OrderDetails({
            destinationChainId: destinationChainId,
            tipTokenAdress: tipTokenAdress,
            tipAmount: tipAmount
        });

        // Store the order in the mapping
        orders[orderId] = newOrder;
    }



    function generateKey(
        address conditionAddress,
        uint16 conditionId,
        uint256 conditionAmount
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(conditionAddress, conditionId, conditionAmount));
    }


    modifier OnlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }


    function getOrderDetails(bytes32 orderId) external view returns (OrderDetails memory) {
        return orders[orderId];
    }


}
