// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "lib/wormhole-solidity-sdk/src/WormholeRelayerSDK.sol";

import {AavePool} from "./interfaces/IAavePool.sol";
import {IHyperlaneMailbox} from "./interfaces/IHyperlane.sol";
import {IFactory} from "./interfaces/IFactory.sol";

// Protocols To Be Integrated
// 1. Aave (Condition Check done and asset supply/replay should work)
// 2. Hyperlane (Testing Remaining)
// 3. Wormhole (Testing Remaining)
// 4. Circle CCTP (Code needs to be added for bridging USDC)

struct OrderDetails {
    uint32 destinationChainId;
    // Order Tip Details
    address tipToken;
    uint256 tipAmount;
}

struct OrderExecutionDetails {
    address token;
    uint256 amount;
    uint16 assetType;
    bool repay;
}

contract Vault is TokenSender, TokenReceiver {
    uint256 constant GAS_LIMIT = 250_000;

    // State variables
    address private immutable owner;
    address private immutable factoryAddress;

    // External Protocol Configurations
    address private immutable aavePoolAddress;
    address private immutable hyperlaneMailboxAddress;

    address private immutable usdcAddress;
    address private immutable tokenMessenger;
    uint32 private immutable cctpChainId;
    uint32 private immutable cctpValue;

    // Mappings
    mapping(uint32 => address) private chainIdToAddress;

    mapping(bytes32 => OrderDetails) public orders;

    mapping(bytes32 => OrderExecutionDetails) public orderExecutionDetails;

    // Events

    // Errors
    error ConditionInvalid(uint256 sentValue, uint256 currentValue);
    error ConditionAmountIsZero();

    error InvalidOrderId();
    error InvalidConditionId();
    error InvalidConidtionId();

    error SenderNotMailbox();
    error NotOwner(address sender, address owner);

    error InvalidDestinationChainId();
    error InvalidSender();
    error TipAmountIsZero();

    error InsufficientCrossChainDeposit(uint256 cost, uint256 balance);

    constructor(
        address _owner,
        address _aavePoolAddress,
        address _hyperlaneMailboxAddress,
        address _usdcAddress,
        address _tokenMessenger,
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole,
        uint32 _cctpChainId,
        uint32 _cctpValue
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {
        owner = _owner;
        aavePoolAddress = _aavePoolAddress;
        hyperlaneMailboxAddress = _hyperlaneMailboxAddress;

        usdcAddress = _usdcAddress;
        tokenMessenger = _tokenMessenger;
        cctpChainId = _cctpChainId;
        cctpValue = _cctpValue;
    }

    modifier OnlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender, owner);
        }
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
        address tipToken,
        uint256 tipAmount
    ) external OnlyOwner returns (bytes32) {
        // Ensure the condition amount is greater than zero
        if (conditionAmount == 0) {
            revert ConditionAmountIsZero();
        }
        // Ensure the tip amount is greater than zero
        if (tipAmount == 0) {
            revert TipAmountIsZero();
        }
        // Ensure the destination chain ID is valid
        if (destinationChainId == 0) {
            revert InvalidDestinationChainId();
        }
        // Generate a unique order ID
        bytes32 orderId = generateKey(conditionAddress, conditionId, conditionAmount);

        // Create the order details
        OrderDetails memory newOrder =
            OrderDetails({destinationChainId: destinationChainId, tipToken: tipToken, tipAmount: tipAmount});

        // Store the order in the mapping
        orders[orderId] = newOrder;

        // Transfer the tip amount from the sender to the contract
        IERC20(tipToken).transferFrom(msg.sender, address(this), tipAmount);

        return orderId;
    }

    function cancelOrder(bytes32 orderId) external OnlyOwner {
        // Ensure the order ID is valid
        if (orders[orderId].tipAmount == 0) {
            revert InvalidOrderId();
        }
        // Transfer the tip amount back to the sender
        IERC20(orders[orderId].tipToken).transfer(msg.sender, orders[orderId].tipAmount);

        // Delete the order from the mapping
        delete orders[orderId];
    }

    function depositAsset(bytes32 orderId, address _token, uint256 _amount, uint16 assetType, bool repay) external {
        // Create the order execution details
        OrderExecutionDetails memory newOrderExecution =
            OrderExecutionDetails({token: _token, amount: _amount, assetType: assetType, repay: repay});

        // Store the order execution details in the mapping
        orderExecutionDetails[orderId] = newOrderExecution;

        // Transfer the asset from the sender to the contract
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    function cancelAssetDeposit(bytes32 orderId) external OnlyOwner {
        // Ensure the order ID is valid
        if (orderExecutionDetails[orderId].amount == 0) {
            revert InvalidOrderId();
        }
        // Transfer the asset amount back to the sender
        IERC20(orderExecutionDetails[orderId].token).transfer(msg.sender, orderExecutionDetails[orderId].amount);

        // Delete the order execution details from the mapping
        delete orderExecutionDetails[orderId];
    }

    function executeOrder(address conditionAddress, uint16 conditionId, uint256 conditionAmount) external {
        if (conditionAmount > 3) {
            revert InvalidConditionId();
        }

        bytes32 orderId = generateKey(conditionAddress, conditionId, conditionAmount);
        OrderDetails memory order = orders[orderId];

        // Ensure the order ID is valid
        if (orders[orderId].tipAmount == 0) {
            revert InvalidOrderId();
        }

        // Call Aave to Check the condition is met
        (uint256 totalCollateralBase, uint256 totalDebtBase,,, uint256 ltv, uint256 healthFactor) =
            AavePool(aavePoolAddress).getUserAccountData(owner);

        // Check if the condition is met
        if (conditionId == 0 && totalCollateralBase > conditionAmount) {
            revert ConditionInvalid(conditionAmount, totalCollateralBase);
        } else if (conditionId == 1 && conditionAmount > totalDebtBase) {
            revert ConditionInvalid(conditionAmount, totalDebtBase);
        } else if (conditionId == 2 && ltv > conditionAmount) {
            revert ConditionInvalid(conditionAmount, ltv);
        } else if (conditionId == 3 && healthFactor > conditionAmount) {
            revert ConditionInvalid(conditionAmount, healthFactor);
        }

        if (order.destinationChainId == block.chainid) {
            // Same Chain Execution
            sameChainOrderExecution(orderId);
        } else {
            // Call Hyperlane to send message to the destination chain
            sendMessageToDestinationChain(order.destinationChainId, orderId);
        }
        // Delete the order and order execution details from the mappings
        delete orders[orderId];

        IERC20(order.tipToken).transfer(msg.sender, order.tipAmount);
    }

    function sameChainOrderExecution(bytes32 orderId) internal {
        OrderExecutionDetails memory orderExecution = orderExecutionDetails[orderId];

        // Destructure the token based on the asset type

        // Approve call may change based on the asset type
        IERC20(orderExecution.token).approve(aavePoolAddress, orderExecution.amount);

        // Call Aave to repay or supply the asset
        if (orderExecution.repay) {
            // Call Aave to repay the asset
            AavePool(aavePoolAddress).repay(orderExecution.token, orderExecution.amount, 2, owner);
        } else {
            // Call Aave to supply the asset
            AavePool(aavePoolAddress).supply(orderExecution.token, orderExecution.amount, owner, 0);
        }

        // Delete the order and order execution details from the mappings
        delete orders[orderId];
    }

    function sendMessageToDestinationChain(uint32 destinationChainId, bytes32 orderId) internal {
        // Call Hyperlane to send the message to the destination chain
        IHyperlaneMailbox hyperlaneMailbox = IHyperlaneMailbox(hyperlaneMailboxAddress);
        bytes32 recipientAddress = addressToBytes32(chainIdToAddress[destinationChainId]);

        bytes memory messageBody = abi.encode(orderId);

        uint256 fee = hyperlaneMailbox.quoteDispatch(destinationChainId, recipientAddress, messageBody);

        hyperlaneMailbox.dispatch{value: fee * 2}(destinationChainId, recipientAddress, messageBody);
    }

    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable {
        // Ensure the function is called by Hyperlane
        if (msg.sender != hyperlaneMailboxAddress) {
            revert SenderNotMailbox();
        }

        address originAddress = chainIdToAddress[_origin];

        // Check if the message is from valid sender
        if (_sender != addressToBytes32(originAddress)) {
            revert InvalidSender();
        }
        // Decode the message to get the order ID
        bytes32 orderId = abi.decode(_message, (bytes32));

        OrderExecutionDetails memory orderExecution = orderExecutionDetails[orderId];
        if (orderExecution.amount == 0) {
            revert InvalidOrderId();
        }

        bridgeFunds(orderExecution.token, orderExecution.amount, _origin, originAddress, orderExecution.repay);
    }

    function quoteCrossChainDeposit(uint16 targetChain) public view returns (uint256 cost) {
        uint256 deliveryCost;
        (deliveryCost,) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, 0, GAS_LIMIT);

        cost = deliveryCost + wormhole.messageFee();
    }

    function bridgeFunds(address token, uint256 tokenAmount, uint32 destinationChain, address reciever, bool repay)
        internal
    {
        // Bridge using wormhole or cctp
        if (token == usdcAddress && destinationChain == cctpChainId) {
            IERC20(token).approve(tokenMessenger, tokenAmount);
            // Call CCTP to bridge the USDC

            // Call Factory contract to emit the cross chain transfer event
            IFactory(factoryAddress).emitCrossChainTransfer(owner, usdcAddress, tokenAmount);
        } else {
            // Call Wormhole to bridge the asset
            uint16 wormholeChainId = IFactory(factoryAddress).getWormholeChainId(destinationChain);

            uint256 cost = quoteCrossChainDeposit(wormholeChainId);

            if (address(this).balance < cost) {
                revert InsufficientCrossChainDeposit(cost, address(this).balance);
            }

            bytes memory payload = abi.encode(repay);

            sendTokenWithPayloadToEvm(wormholeChainId, reciever, payload, 0, GAS_LIMIT, token, tokenAmount);
        }
    }

    function receivePayloadAndTokens(
        bytes memory payload,
        TokenReceived[] memory receivedTokens,
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32 // deliveryHash
    ) internal override onlyWormholeRelayer isRegisteredSender(sourceChain, sourceAddress) {
        require(receivedTokens.length == 1, "Expected 1 token transfer");

        // Decode the recipient address from the payload
        bool repay = abi.decode(payload, (bool));

        IERC20(receivedTokens[0].tokenAddress).approve(aavePoolAddress, receivedTokens[0].amount);
        // Call Aave to repay or supply the asset
        if (repay) {
            // Call Aave to repay the asset
            AavePool(aavePoolAddress).repay(receivedTokens[0].tokenAddress, receivedTokens[0].amount, 2, address(this));
        } else {
            // Call Aave to supply the asset
            AavePool(aavePoolAddress).supply(receivedTokens[0].tokenAddress, receivedTokens[0].amount, address(this), 0);
        }
    }

    function HandleUsdc(uint256 amount, bool repay) external {}

    function withdrawNativeToken(uint256 _amount) external OnlyOwner {
        payable(owner).transfer(_amount);
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

    function generateKey(address conditionAddress, uint16 conditionId, uint256 conditionAmount)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(conditionAddress, conditionId, conditionAmount));
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function getOrderDetails(bytes32 orderId) external view returns (OrderDetails memory) {
        return orders[orderId];
    }
}
