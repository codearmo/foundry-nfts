//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvg;
    string private s_happySvg;

    enum Mood {
        HAPPY,
        SAD
    }
    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadSvg,
        string memory happySvg
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvg = sadSvg;
        s_happySvg = happySvg;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter = s_tokenCounter + 1;
    }

    function flipMood(uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[s_tokenCounter] == Mood.HAPPY) {
            imageURI = s_happySvg;
        } else {
            imageURI = s_sadSvg;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '", "description"; "An NFT that reflects the owners mood.", "attributes": [{"trait_type": "moodiness" , "value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
