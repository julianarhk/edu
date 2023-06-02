// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract EduCollectNFT is ERC721, ERC721URIStorage {
    address public admin;

    struct Badge {
        uint256 id;
        string name;
        string description;
        string imageUrl;
    }

    Badge[] public badges;
    mapping(uint256 => address) private badgeOwners;

    constructor() ERC721("EduCollectNFT", "EDUC") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }

    function mintBadge(
        address recipient,
        string memory name,
        string memory description,
        string memory imageUrl,
        string memory badgeURI
    ) external onlyAdmin returns (uint256) {
        uint256 badgeId = badges.length;
        Badge memory newBadge = Badge(badgeId, name, description, imageUrl);
        badges.push(newBadge);

        _mint(recipient, badgeId);
        _setTokenURI(badgeId, badgeURI);
        badgeOwners[badgeId] = recipient;

        return badgeId;
    }

    function getBadgeOwner(uint256 badgeId) external view returns (address) {
        return badgeOwners[badgeId];
    }

    function getBadgeMetadata(
        uint256 badgeId
    )
        external
        view
        returns (
            string memory name,
            string memory description,
            string memory imageUrl
        )
    {
        require(_exists(badgeId), "Badge does not exist");
        Badge memory badge = badges[badgeId];
        return (badge.name, badge.description, badge.imageUrl);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
