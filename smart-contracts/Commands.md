
## Deploy Aave Mock 

forge script script/DeployAaveMock.s.sol:AaveMockScript --rpc-url $BASE_SEPOLIA --private-key $PRIVATE_KEY --broadcast


## Deploy Vault Factory

forge script script/DeployFactory.s.sol:DeployFactory --rpc-url $BASE_SEPOLIA --private-key $PRIVATE_KEY --broadcast

## Deploy Vault

forge script script/DeployVault.s.sol:DeployVault --rpc-url $BASE_SEPOLIA --private-key $PRIVATE_KEY --broadcast

## Add Vault 

cast send 0x94354Ba79dac36fF4fD98A29a116734eE4376162 --rpc-url $BASE_SEPOLIA "addVault(address _vault)" 0xDbCA0f7E1f3d98D98ec6cBBafD5Be0Fc4b34fF15 --private-key $PRIVATE_KEY

## Set wormhole chain


### Base Sepolia 
cast send 0x94354Ba79dac36fF4fD98A29a116734eE4376162 --rpc-url $BASE_SEPOLIA "setWormholeChainId(uint32 _chainId, uint16 _worldChainId)" 84532 10004 --private-key $PRIVATE_KEY

### Avlanche Fuji 

cast send 0x94354Ba79dac36fF4fD98A29a116734eE4376162 --rpc-url $BASE_SEPOLIA "setWormholeChainId(uint32 _chainId, uint16 _worldChainId)" 43113 6 --private-key $PRIVATE_KEY



## Set Aave Pool Parameters 

cast send 0x39D034F2E2bAB2Ac193A318f745A2F906DFe3C9b --rpc-url $BASE_SEPOLIA "setUserData(uint256 _totalCollateralBase, uint256 _totalDebtBase, uint256 _availableBorrowsBase, uint256 _currentLiquidationThreshold, uint256 _ltv, uint256 _healthFactor)" 10000 10000 10000 10000 10000 10000 --private-key $PRIVATE_KEY


## USDC Approve Call

cast send 0x036cbd53842c5426634e7929541ec2318f3dcf7e --rpc-url $BASE_SEPOLIA "approve(address spender, uint256 value)" 0x94354Ba79dac36fF4fD98A29a116734eE4376162 100 --private-key $PRIVATE_KEY

## Create Order 

cast send 0x4A7401B340f4851c96E444D711B54eb60820c69a --rpc-url $BASE_SEPOLIA "createOrder(address conditionAddress, uint16 conditionId, uint256 conditionAmount, uint32 destinationChainId, address tipToken, uint256 tipAmount)" 0x0000000000000000000000000000000000000000  0 100000  84532 0x036cbd53842c5426634e7929541ec2318f3dcf7e 10 --private-key $PRIVATE_KEY

## Deposit Asset

cast send 0x4A7401B340f4851c96E444D711B54eb60820c69a --rpc-url $BASE_SEPOLIA "depositAsset(bytes32 orderId, address _token, uint256 tokenAmount, uint16 assetType, bool repay)" 0x9f5bc6827f636a1cc964d426ba2e819a7aaa1f47eaf156927d1e532def3d5da1 0x036cbd53842c5426634e7929541ec2318f3dcf7e 100 0 false --private-key $PRIVATE_KEY

## Configure Wormhole ChainId 

cast send 0x39D034F2E2bAB2Ac193A318f745A2F906DFe3C9b --rpc-url $FUJI "setWormholeChainId(uint32 _chainId, uint16 _worldChainId)" 84532 10004 --private-key $PRIVATE_KEY

## Add cross-chain vault 

cast send 0x1e6171d2aF98b429F87A6E982494C69c8e1A0D5E --rpc-url $FUJI "addExternalChainVault(uint32 chainId, address chainAddress)" 84532 0x4A7401B340f4851c96E444D711B54eb60820c69a --private-key $PRIVATE_KEY

cast send 0x0BA24Ef197e61Dd4E3ABEA3B9aEc04e3C7DBc6Ff --rpc-url $BASE_SEPOLIA "addExternalChainVault(uint32 chainId, address chainAddress)" 43113 0x1e6171d2aF98b429F87A6E982494C69c8e1A0D5E --private-key $PRIVATE_KEY



### FUJI USDC approval 

cast send 0x5425890298aed601595a70AB815c96711a31Bc65 --rpc-url $FUJI "approve(address spender, uint256 value)" 0x1e6171d2aF98b429F87A6E982494C69c8e1A0D5E 1000000 --private-key $PRIVATE_KEY