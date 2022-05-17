// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    struct CharacterAttributes {
        string name;
        string class;
        uint256 strength;
        uint256 dexterity;
        uint256 intelligence;
        uint256 level;
    }

    CharacterAttributes[] characters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Name: ",
            getName(tokenId),
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Class: ",
            getClass(tokenId),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "STR: ",
            getSTR(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "DEX: ",
            getDEX(tokenId),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "INT: ",
            getINT(tokenId),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            getLevel(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getName(uint256 tokenId) public view returns (string memory) {
        return nftHolderAttributes[tokenId].name;
    }

    function getClass(uint256 tokenId) public view returns (string memory) {
        return nftHolderAttributes[tokenId].class;
    }

    function getSTR(uint256 tokenId) public view returns (string memory) {
        uint256 str = nftHolderAttributes[tokenId].strength;
        return str.toString();
    }

    function getDEX(uint256 tokenId) public view returns (string memory) {
        uint256 dex = nftHolderAttributes[tokenId].dexterity;
        return dex.toString();
    }

    function getINT(uint256 tokenId) public view returns (string memory) {
        uint256 intelligence = nftHolderAttributes[tokenId].intelligence;
        return intelligence.toString();
    }

    function getLevel(uint256 tokenId) public view returns (string memory) {
        uint256 level = nftHolderAttributes[tokenId].level;
        return level.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenId.increment();
        uint256 newItemId = _tokenId.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = CharacterAttributes({
            name: "Spidey",
            class: "Assassin",
            strength: 10 + random(40),
            dexterity: 10 + random(30),
            intelligence: 10 + random(20),
            level: 1
        });
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "Yout must own this NFT to train it!"
        );
        uint256 currentSTR = nftHolderAttributes[tokenId].strength;
        uint256 currentDEX = nftHolderAttributes[tokenId].dexterity;
        uint256 currentINT = nftHolderAttributes[tokenId].intelligence;
        uint256 currentLevel = nftHolderAttributes[tokenId].level;
        nftHolderAttributes[tokenId].strength = currentSTR + random(3);
        nftHolderAttributes[tokenId].dexterity = currentDEX + random(2);
        nftHolderAttributes[tokenId].intelligence = currentINT + random(1);
        nftHolderAttributes[tokenId].level = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function random(uint256 number) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % number;
    }
}
