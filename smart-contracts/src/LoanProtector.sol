// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


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

struct OrderExecutionDetails{
    address tokenAddress;
    uint256 tokenAmount;
    uint8 assetType;
    bool repay; 
}





contract LoanProtector {

    // State variables
    address public owner;

    mapping(uint32 => address) private chainIdToAddress;

    mapping(bytes32 => OrderDetails) public orders; 

    mapping(bytes32 => OrderExecutionDetails) public orderExecutionDetails;


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
    ) external OnlyOwner returns (bytes32) {


        // Ensure the condition amount is greater than zero
        require(conditionAmount > 0, "Condition amount must be greater than zero");
        // Ensure the tip amount is greater than zero
        require(tipAmount > 0, "Tip amount must be greater than zero");
        // Ensure the destination chain ID is valid
        require(chainIdToAddress[destinationChainId] != address(0), "Invalid destination chain ID");

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

        
        // Transfer the tip amount from the sender to the contract
        IERC20(tipTokenAdress).transferFrom(msg.sender, address(this), tipAmount);

        return orderId;
    }


    function depositAsset(
        bytes32 orderId,
        address tokenAddress,
        uint256 tokenAmount,
        uint8 assetType,
        bool repay
    ) external OnlyOwner {
        // Ensure the order ID is valid
        require(orders[orderId].tipAmount > 0, "Invalid order ID");

        // Create the order execution details
        OrderExecutionDetails memory newOrderExecution = OrderExecutionDetails({
            tokenAddress: tokenAddress,
            tokenAmount: tokenAmount,
            assetType: assetType,
            repay: repay
        });

        // Store the order execution details in the mapping
        orderExecutionDetails[orderId] = newOrderExecution;


        // Transfer the asset from the sender to the contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);

    }

    function addChainId(uint32 chainId, address chainAddress) external OnlyOwner {
        chainIdToAddress[chainId] = chainAddress;
    }

    function removeChainId(uint32 chainId) external OnlyOwner {
        delete chainIdToAddress[chainId];
    }
    
    function getChainAddress(uint32 chainId) external view returns (address) {
        return chainIdToAddress[chainId];
    }


    function generateKey(
        address conditionAddress,
        uint16 conditionId,
        uint256 conditionAmount
    ) public pure returns (bytes32) {
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
