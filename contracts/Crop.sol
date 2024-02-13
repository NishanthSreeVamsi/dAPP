// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CropMarket {
    address public owner;

    // Struct to represent a crop
    struct Crop {
        uint256 id;
        address farmer;
        string name;
        uint256 pricePerUnit; // Price per unit of the crop
        uint256 quantity; // Total quantity of the crop available
    }

    // Mapping to store crops deployed by each farmer
    mapping(address => uint256[]) public farmerCrops;

    // Array to store all crops
    Crop[] public crops;

    // Event to emit when a crop is added to the market
    event CropAdded(uint256 id, address farmer, string name, uint256 pricePerUnit, uint256 quantity);

    // Event to emit when a crop is purchased
    event CropPurchased(uint256 id, address consumer, uint256 quantity, uint256 totalPrice);

    // Modifier to ensure only the contract owner can perform certain actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function for the farmer to add a crop to the market
    function addCrop(string memory _name, uint256 _pricePerUnit, uint256 _quantity) external {
        uint256 id = crops.length;
        crops.push(Crop(id, msg.sender, _name, _pricePerUnit, _quantity));
        farmerCrops[msg.sender].push(id); // Add the crop to the list of crops for the farmer
        emit CropAdded(id, msg.sender, _name, _pricePerUnit, _quantity);
    }

    // Function for the consumer to purchase a crop
    function buyCrop(uint256 _id, uint256 _quantity) external payable {
        Crop storage crop = crops[_id];
        require(crop.quantity >= _quantity, "Insufficient quantity available");
        uint256 totalPrice = crop.pricePerUnit * _quantity; // Calculate total price
        require(msg.value >= totalPrice, "Insufficient funds");

        crop.quantity -= _quantity; // Reduce the quantity of available crop
        payable(crop.farmer).transfer(totalPrice); // Transfer funds to the farmer

        emit CropPurchased(_id, msg.sender, _quantity, totalPrice);
    }

    // Function to get the details of a crop
    function getCrop(uint256 _id) external view returns (uint256, address, string memory, uint256, uint256) {
        Crop memory crop = crops[_id];
        return (crop.id, crop.farmer, crop.name, crop.pricePerUnit, crop.quantity);
    }

    // Function to get the total number of crops in the market
    function getTotalCrops() external view returns (uint256) {
        return crops.length;
    }

    // Function for a farmer to withdraw their funds for their crops
    function withdrawFunds() external {
        uint256 totalAmount = 0;
        uint256[] storage farmerCropIds = farmerCrops[msg.sender];
        for (uint256 i = 0; i < farmerCropIds.length; i++) {
            uint256 cropId = farmerCropIds[i];
            Crop storage crop = crops[cropId];
            uint256 soldQuantity = crop.quantity < crop.quantity ? crop.quantity : crop.quantity; // Calculate the sold quantity
            totalAmount += crop.pricePerUnit * soldQuantity;
            crop.quantity -= soldQuantity; // Mark the sold quantity as unavailable
        }
        require(totalAmount > 0, "No funds to withdraw");

        payable(msg.sender).transfer(totalAmount);
    }

    // Function to withdraw contract balance
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
