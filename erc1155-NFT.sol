// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract NonTransferableERC1155 is ERC1155, Ownable, ERC1155Supply {
    mapping(uint256 => string) public tokenURIs;
    mapping(address => bool) private _approvedTransfer;

    event ApprovalForTransfer(address indexed approvedAddress, bool approval);

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setTokenURI(uint256 id, string memory URI) public onlyOwner {
        tokenURIs[id] = URI;
    }

    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        string memory _tokenURI = tokenURIs[id];
        return bytes(_tokenURI).length > 0 ? _tokenURI : super.uri(id);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data,
        string memory URI
    ) public onlyOwner {
        _mint(account, id, amount, data);
        tokenURIs[id] = URI;
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        string[] memory URIs
    ) public onlyOwner {
        require(ids.length == URIs.length, "Mismatch in Length");
        _mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++) {
            tokenURIs[ids[i]] = URIs[i];
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function approveTransfer(
        address approvedAddress,
        bool approval
    ) public onlyOwner {
        _approvedTransfer[approvedAddress] = approval;
        emit ApprovalForTransfer(approvedAddress, approval);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {
        address sender = _msgSender();
        require(
            from == address(0) ||
                _approvedTransfer[sender] ||
                sender == owner(),
            "ERC1155: transfer caller is not approved or owner"
        );
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        address sender = _msgSender();
        require(
            from == address(0) ||
                _approvedTransfer[sender] ||
                sender == owner(),
            "ERC1155: transfer caller is not approved or owner"
        );
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }
}
