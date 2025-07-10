// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IPlasticToken {
    function burnFrom(address account, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
}

contract PlasticNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public admin;
    IPlasticToken public plasticToken;

    mapping(address => uint256) public readyForRetirement;

    event MintedNFT(address indexed to, uint256 tokenId, uint256 amount);
    event TokenRetired(address indexed owner, uint256 amount, uint256 tokenId);

    constructor(address plasticTokenAddress) ERC721("Plastic Credit Certificate NFT", "PLSTCNFT") {
        admin = msg.sender;
        plasticToken = IPlasticToken(plasticTokenAddress);
    }

   function burnFTAndMintNFT(uint256 amount) external {
    address sender = msg.sender;

    require(plasticToken.allowance(sender, address(this)) >= amount, "Not approved to burn");

    // Burn token dari wallet si pemanggil
    plasticToken.burnFrom(sender, amount);

    // Simpan total offset milik user
    readyForRetirement[sender] += amount;

    // Mint NFT ke sender
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    _mint(sender, tokenId);

    emit MintedNFT(sender, tokenId, amount);
    emit TokenRetired(sender, amount, tokenId);
}

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("https://example.com/api/token/", uint2str(tokenId)));
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) { length++; j /= 10; }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) { bstr[--k] = bytes1(uint8(48 + j % 10)); j /= 10; }
        return string(bstr);
    }
}
