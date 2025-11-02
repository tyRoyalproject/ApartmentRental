// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ApartmentRental {
    address payable public owner;
    address public currentTenant;
    uint public monthlyRent;
    bool public isRented;

    event RentPaid(address indexed tenant, uint amount);
    event ApartmentAvailable(address indexed owner, string message);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    modifier onlyTenant() {
        require(msg.sender == currentTenant, "You are not the tenant.");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        monthlyRent = 1 ether; // default rent
        isRented = false;
    }

    function rentApartment() public payable {
        require(!isRented, "Already rented.");
        require(msg.value == monthlyRent, "Incorrect rent amount.");
        
        currentTenant = msg.sender;
        isRented = true;

        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Payment failed.");

        emit RentPaid(msg.sender, msg.value);
    }

    function vacateApartment() public onlyTenant {
        isRented = false;
        currentTenant = address(0);
        emit ApartmentAvailable(owner, "Apartment is now available.");
    }

    function updateRent(uint newRent) public onlyOwner {
        monthlyRent = newRent;
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}