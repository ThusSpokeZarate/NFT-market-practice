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
    
}