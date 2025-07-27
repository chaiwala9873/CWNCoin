// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 🔐 Verified Security from OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

contract CWNCoin is ERC20, Ownable {

    // 🔐 Transfer lock & cooldown
    bool public transfersEnabled = true;
    bool public transferDelayEnabled = true;
    uint256 public transferCooldown = 30; // 30 seconds cooldown

    mapping(address => uint256) private _lastTransfer;

    constructor() ERC20("Chai Wala Niku", "CWN") {
        _mint(msg.sender, 100_000_000 * 10 ** decimals()); // 100 Million Tokens to Owner
    }

    // 🔐 Hook to delay transfers if enabled
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(transfersEnabled, "Transfers are currently disabled");

        if (transferDelayEnabled && from != address(0)) {
            require(block.timestamp - _lastTransfer[from] >= transferCooldown, "Wait before next transfer");
            _lastTransfer[from] = block.timestamp;
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    // 🔐 Enable/Disable all transfers (by owner)
    function enableTransfers(bool status) external onlyOwner {
        transfersEnabled = status;
    }

    // 🔐 Enable/Disable delay
    function enableTransferDelay(bool status) external onlyOwner {
        transferDelayEnabled = status;
    }

    // 🔐 Set custom cooldown in seconds
    function setTransferCooldown(uint256 seconds_) external onlyOwner {
        require(seconds_ <= 3600, "Max 1 hour cooldown");
        transferCooldown = seconds_;
    }

    // 🔥 Public burn function
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
