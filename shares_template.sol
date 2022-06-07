//SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.10;

*/
contract ZenconNFT is ERC721 {

    struct DocumentNFT {
        
        bool active;
        uint256 studentId;
    }

    IERC20 public token; 
    uint256 public nftCounter; 
    mapping(uint256 => DocumentNFT) public documentNFTs; 

    event CreateNFT(address indexed sender, uint256 amount, uint256 nftId);
    event ClaimNFT(address indexed sender, uint256 amount, uint256 claimTime, uint256 nftId);

    constructor(address _token)
    ERC721("NFT", "DocumentNFT") { 
        token = IERC20(_token);
        nftCounter = 0;
    }

    receive() external payable {
        // Previene salida de dinero
        revert("Native deposit not supported");
    }

    function createDocumentNFT(string memory fileData) external returns (bool) {
        nftCounter++;
        documentNFTs[nftCounter] = DocumentNFT(true, fileData); 
        _safeMint(msg.sender, nftCounter); 
        return true;
    }
    function claimDocumentNFT(uint256 memory nftId) public returns (bool) {
        require(ownerOf(nftId) == msg.sender, "cannot claim an NFT that you do not own");

        DocumentNFT storage nft = documentNFTs[nftId];
        require(nft.active, "cannot claim the same NFT twice");
        nft.active = false; 

        bool success = token.transfer(msg.sender, nft.studentId);
        require(success == true, "Transfer failed");

        emit ClaimNFT(msg.sender, nft.studentId, uint32(block.timestamp), nftId);
        return true;
    }
}
