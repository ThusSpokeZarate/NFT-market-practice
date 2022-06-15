pragma solidity ^0.8.0; //SPDX-License-Identifire: GPL-3.0

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MarketPlace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemsIds; // total number of items ever created
    Counters.Counter private _itemsSold; // total number of items Sold

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
    function createMarketItem(
        address nftContract,
        uint tokenId,
        uint256 price) public payable nonReentrant {
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
            false);
        
        }