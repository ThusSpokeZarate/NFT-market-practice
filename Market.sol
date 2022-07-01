pragma solidity ^0.8.0; //SPDX-License-Identifire: GPL-3.0

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MarketPlace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; // total number of items ever created
    Counters.Counter private _itemSold; // total number of items Sold

    address payable owner; //onwer of the contract
    // users must pay one time fee for initial listing
    uint256 listingPrice = 0.03 ether;

    constructor() {
        owner = payable(msg.sender);
    }
    
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    // access struct with mapping
    // access MarketItem by passing and integerId
    mapping(uint256 => MarketItem) private idMarketItem;

    //declare event to log sell activity
    //events do not use semi colon but commas
    event MarketItemCreation (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller, 
        address payable owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function setListingPrice(uint _price) public returns (uint256) {
        listingPrice = _price;
        return listingPrice;
    }

    // TO DO: create function that manages MarketItem
    function createMarketItem(address nftContract, uint tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be above zero");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        
    
        //using struct from line 21
        _itemIds.increment(); //add 1 to the total of items ever created
        uint256 itemId = _itemIds.current();

        idMarketItem[itemId] = MarketItem (
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable (address(0)), // no owner yet so set as non address
            price,
            false);
        
        // transfering ownership of the NFT to the contract itself until someone wants to buy.
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // log this transaction
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
            );
        
        }

        function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
            uint price = idMarketItem[itemId].price;
            uint tokenId = idMarketItem[itemId].tokenId;

            require(msg.value == price, "stop trying to pay the wrong price!");

            //transfer the seller the purchase value
            idMarketItem[itemId].seller.transfer(msg.value);

            //transfer the ownership from the contract itself to the buyer
            IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

            idMarketItem[itemId].owner == payable(msg.sender); // marke the buyer as the new owner
            idMarketItem[itemId].sold == true; // marke the item as truly sold
            _itemSold.increment(); // increase count of item sold by 1
            payable (owner).transfer(listingPrice); // pay the owner of the contract the listing price

        

        }
        // total number of items sold on our market place
        function fetchMarketItems() public view returns (MarketItem[] memory){
            //get total number of items created
            uint totalItemCount = _itemIds.current();

            //total unsold items = total items minus total sold items
            uint unsoldItemCount = _itemIds.current() - _itemSold.current();

            uint currentIndex = 0;

            //Instantiate an array of MarketItem[]
            MarketItem[] memory items = new MarketItem[](unsoldItemCount);

            //loop through all items created
            for(uint i = 0; i < itemCount; i++) {
                //check if owner field is empty to see if item has never been sold
                if(idMarketItem[i+1].owner == address(0)){
                    // yes item has been sold
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentItems] = currentItem;
                    currentIndex += 1;

                }
            }
            return items; //return array of all items never sold
        }

        /// @nonce fetch the list of NFTs bought by the user
            function fetchMyNFTs() public view returns (MarketItem [] memory) {
                // get total items created
                uint totalItemCount = _itemIds.current();

                uint itemCount = 0;
                uint currentIndex = 0;

                for (uint i=0; i < totalItemCount; i++) {
                    // get items owned by this user
                   if  (idMarketItem[i+1].owner == msg.sender) {
                       itemCount += 1; // total length of array
                   }
                }

            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i = 0; i < totalItemCount; i++) {
                if (idMarketItem[i+1].owner == msg.sender) {
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
            return items;

            
            }

            /// @notice fetch the list of NFT's created by the user
        function fetchItemsCreated() public view returns (MarketItem[] memory) {
            // get total number of items ever created
            uint totalItemCount = _itemIds.current();

            uint itemCount = 0;
            uint currentIndex = 0; 

            for (uint i=0; i< totalItemCount; i++){
                // get only the item that this user has bought/ is the owner 
                if (idMarketItem[i+1].seller == msg.sender) {
                    itemCount += 1; // total length of the array
                }

            }
            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i = 0; i < totalItemCount; i++){
                if (idMarketItem[i+1].seller == msg.sender){
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;

            }
        }
        return items;
    }
}