// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


import {AavePool} from "./interfaces/IAavePool.sol";
import {IHyperlaneMailbox} from "./interfaces/IHyperlane.sol";

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
    uint16 assetType;
    bool repay; 
}



contract LoanProtector {

    // State variables
    address public immutable owner;


    // Configuration 
    address private immutable usdcAddress;
    uint32 private immutable cctpChainId;

    address private immutable aavePoolAddress;
    address private immutable hyperlaneMailboxAddress;



    // Mappings 
    mapping(uint32 => address) private chainIdToAddress;

    mapping(bytes32 => OrderDetails) public orders; 

    mapping(bytes32 => OrderExecutionDetails) public orderExecutionDetails;


    // Events


    modifier OnlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

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

    function cancelOrder(
        bytes32 orderId
    ) external OnlyOwner {
        // Ensure the order ID is valid
        require(orders[orderId].tipAmount > 0, "Invalid order ID");

        // Transfer the tip amount back to the sender
        IERC20(orders[orderId].tipTokenAdress).transfer(msg.sender, orders[orderId].tipAmount);

        // Delete the order from the mapping
        delete orders[orderId];
    }

    function depositAsset(
        bytes32 orderId,
        address tokenAddress,
        uint256 tokenAmount,
        uint16 assetType,
        bool repay
    ) external {
        
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

    function cancelAssetDeposit(
        bytes32 orderId
    ) external OnlyOwner {
        // Ensure the order ID is valid
        require(orderExecutionDetails[orderId].tokenAmount > 0, "Invalid order ID");

        // Transfer the asset amount back to the sender
        IERC20(orderExecutionDetails[orderId].tokenAddress).transfer(msg.sender, orderExecutionDetails[orderId].tokenAmount);

        // Delete the order execution details from the mapping
        delete orderExecutionDetails[orderId];
    }

    function executeOrder(
        address conditionAddress,
        uint16 conditionId,
        uint256 conditionAmount
    ) external  {
    
        // Call Aave to Check the condition is met

    

        bytes32 orderId = generateKey(conditionAddress, conditionId, conditionAmount);
        OrderDetails memory order = orders[orderId];

        // Ensure the order ID is valid
        require(order.tipAmount > 0, "Invalid order ID");

        if (order.destinationChainId == block.chainid) {
            // Same Chain Execution
            sameChainOrderExecution(orderId);
        } else {
            // Call Hyperlane to send message to the destination chain
            
        }
        // Delete the order and order execution details from the mappings
        delete orders[orderId];
    
        IERC20(order.tipTokenAdress).transfer(msg.sender, order.tipAmount);
    }

    function sendMessageToDestinationChain(
        uint32 destinationChainId,
        bytes32 orderId
    ) internal {
        // Call Hyperlane to send the message to the destination chain
        IHyperlaneMailbox hyperlaneMailbox = IHyperlaneMailbox(hyperlaneMailboxAddress);
        bytes32 recipientAddress = addressToBytes32(chainIdToAddress[destinationChainId]);

        bytes memory messageBody = abi.encode(orderId);

        uint256 fee = hyperlaneMailbox.quoteDispatch(destinationChainId, recipientAddress, messageBody);

        hyperlaneMailbox.dispatch{value: fee}(destinationChainId, recipientAddress, messageBody);

    }


    function sameChainOrderExecution(
        bytes32 orderId
    ) internal {
        OrderExecutionDetails memory orderExecution = orderExecutionDetails[orderId];

        // Destructure the token based on the asset type



        // Approve call may change based on the asset type
        IERC20(orderExecution.tokenAddress).approve(aavePoolAddress, orderExecution.tokenAmount);

        // Call Aave to repay or supply the asset
        if (orderExecution.repay){
            // Call Aave to repay the asset
            AavePool(aavePoolAddress).repay(
                orderExecution.tokenAddress,
                orderExecution.tokenAmount,
                2,
                owner
            );

        }else{
            // Call Aave to supply the asset
            AavePool(aavePoolAddress).supply(
                orderExecution.tokenAddress,
                orderExecution.tokenAmount,
                owner,
                0
            );
        }
        
        // Delete the order and order execution details from the mappings
        delete orders[orderId];
    }

    







    function addExternalChainVault(uint32 chainId, address chainAddress) external OnlyOwner {
        chainIdToAddress[chainId] = chainAddress;
    }

    function removeExternalChainVault(uint32 chainId) external OnlyOwner {
        delete chainIdToAddress[chainId];
    }
    
    function getExternalChainVault(uint32 chainId) external view returns (address) {
        return chainIdToAddress[chainId];
    }


    function generateKey(
        address conditionAddress,
        uint16 conditionId,
        uint256 conditionAmount
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(conditionAddress, conditionId, conditionAmount));
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }


    function getOrderDetails(bytes32 orderId) external view returns (OrderDetails memory) {
        return orders[orderId];
    }


}
