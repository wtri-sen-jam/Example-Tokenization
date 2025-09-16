// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IPNFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    
    // Mapping from token ID to IP metadata
    mapping(uint256 => IPMetadata) public ipMetadata;
    
    struct IPMetadata {
        string ipType;        // "patent", "copyright", "trademark", etc.
        string title;
        string description;
        string creator;
        uint256 creationDate;
        string licenseTerms;
        bool isTransferable;
    }
    
    event IPNFTMinted(
        uint256 indexed tokenId, 
        address indexed owner, 
        string ipType, 
        string title
    );
    
    constructor(address initialOwner) 
        ERC721("IP NFT Collection", "IPNFT") 
        Ownable(initialOwner) 
    {}
    
    function mintIP(
        address to,
        string memory uri,
        string memory ipType,
        string memory title,
        string memory description,
        string memory creator,
        string memory licenseTerms,
        bool isTransferable
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        
        ipMetadata[tokenId] = IPMetadata({
            ipType: ipType,
            title: title,
            description: description,
            creator: creator,
            creationDate: block.timestamp,
            licenseTerms: licenseTerms,
            isTransferable: isTransferable
        });
        
        emit IPNFTMinted(tokenId, to, ipType, title);
        
        return tokenId;
    }
    
    function getIPMetadata(uint256 tokenId) public view returns (IPMetadata memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return ipMetadata[tokenId];
    }
    
    // Override transfer functions to respect isTransferable flag
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0)) and burning (to == address(0))
        if (from != address(0) && to != address(0)) {
            require(ipMetadata[tokenId].isTransferable, "This IP NFT is not transferable");
        }
        
        return super._update(to, tokenId, auth);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}