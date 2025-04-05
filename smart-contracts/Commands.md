


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

cast send 0x94354Ba79dac36fF4fD98A29a116734eE4376162 --rpc-url $BASE_SEPOLIA "createOrder(address conditionAddress, uint16 conditionId,  uint256 conditionAmount, uint32 destinationChainId, address tipToken, uint256 tipAmount) returns(bytes32)" 0x036cbd53842c5426634e7929541ec2318f3dcf7e 1 20000 84532 0x036cbd53842c5426634e7929541ec2318f3dcf7e 5 --private-key $PRIVATE_KEY