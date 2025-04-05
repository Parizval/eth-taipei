// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VaultFactory {

    event VaultUpdated(address indexed vaultAddress, address indexed owner);
    event CrossChainTransfer(address indexed vaultAddress, address indexed token, uint256 amount);

    error InvalidVault();
    error VaultAlreadyExists(address vaultAddress);

    address public immutable owner;

    constructor(        
    ) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    mapping(address => address) public vaults;

    mapping(uint32 => uint16) public worldChainId;

    function addVault(address _vault) external {
        
        vaults[msg.sender] = _vault;

        emit VaultUpdated(msg.sender, _vault);

    }

    function emitCrossChainTransfer(address _owner, address _token, uint256 _amount) external {
        address vault = vaults[_owner];

        if (vault != msg.sender) {
            revert InvalidVault();
        }

        emit CrossChainTransfer(vault, _token, _amount);
    }

    function setWormholeChainId(uint32 _chainId, uint16 _worldChainId) external onlyOwner {
        worldChainId[_chainId] = _worldChainId;
    }

    function getWormholeChainId(uint32 _chainId) external view returns (uint16) {
        return worldChainId[_chainId];
    }

    function getVaultAddress(address _owner) external view returns (address) {
        return vaults[_owner];
    }
}
