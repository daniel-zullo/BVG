// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TicketType.sol";

contract BVG {
    struct Ticket {
        uint blockNumber;
        uint startTimestamp;
        uint endTimestamp;
        TicketType ticketType;
        uint price;
    }

    // Members
    mapping(address => bool) public owners;
    mapping(TicketType => uint) public ticketPrices;
    mapping(address => Ticket[]) public users;
    bool internal buyLocked;
    bool internal withdrawLocked;

    // Events
    event LogOwner(string _msg, address _address);
    event LogTicketPrice(TicketType _type, uint _price);
    event LogTicket(uint _number, bytes32 _hash, Ticket _ticket);

    // Initializes the contract setting the initial owner and ticket prices
    constructor() {
        owners[msg.sender] = true;

        ticketPrices[TicketType.Single]  =   3000000000000000 wei;
        ticketPrices[TicketType.Daily]   =   8000000000000000 wei;
        ticketPrices[TicketType.Weekly]  =  40000000000000000 wei;
        ticketPrices[TicketType.Monthly] = 100000000000000000 wei;
        ticketPrices[TicketType.Yearly]  = 800000000000000000 wei;

        emit LogOwner("Initial owner", msg.sender);
    }

    // Restrict to owners
    modifier onlyOwners {
        require(owners[msg.sender] == true, "Only a BVG owner can call this function");
        _;
    }
    
    // Sets the price of a ticket
    function setTicketPrice(TicketType _type, uint _price) onlyOwners public {
        require(ticketPrices[_type] > 0 wei, "Price needs to be higher than zero");

        ticketPrices[_type] = _price * 1 wei;
        emit LogTicketPrice(_type, _price);
    }

    // Add an owner to the list of owners
    function addOwner(address _owner) onlyOwners public {
        owners[_owner] = true;
        emit LogOwner("Set owner", _owner);
    }

    // Gets the balance of the contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Prevent re-entrancy for withdrawal
    modifier withdrawNoReentrant() {
        require(!withdrawLocked, "Withdraw no re-entrancy");
        withdrawLocked = true;
        _;
        withdrawLocked = false;
    }

    // Withdraw the total balance to an owner
    function withdraw() onlyOwners withdrawNoReentrant public payable {
        require(address(this).balance > 0, "Contract balance needs to be higher than zero");
        address payable receiver = payable(msg.sender); 
        uint amount = address(this).balance;
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Failed to withdraw all ether to owner");
    }

    // Prevent re-entrancy to buy a ticket
    modifier buyNoReentrant() {
        require(!buyLocked, "No re-entrancy to buy a ticket");
        buyLocked = true;
        _;
        buyLocked = false;
    }

    // Buy a ticket and returns ticket number, ticket hash, and ticket information
    function buyTicket(TicketType _type) buyNoReentrant public payable returns (uint, bytes32, Ticket memory) {
        require(_type <= TicketType.Yearly, "Ticket type not supported");
        require(ticketPrices[_type] == msg.value, "The amount does not match the ticket price");

        uint ticketNumber = users[msg.sender].length;
        
        Ticket memory ticket;
        ticket.blockNumber = block.number;
        ticket.startTimestamp = block.timestamp;
        ticket.endTimestamp = block.timestamp + getTicketDuration(_type);
        ticket.ticketType = _type;
        ticket.price = ticketPrices[_type];

        bytes32 hash = getTicketHash(ticketNumber, ticket);
        users[msg.sender].push(ticket);

        emit LogTicket(ticketNumber, hash, ticket);

        return (ticketNumber, hash, ticket);
    }

    // Checks for tickets index out of bond
    modifier validTicketNumber(uint _ticketNumber) {
        require(_ticketNumber < users[msg.sender].length, "Tickets index out of bound");
        _;
    }

    // Checks if the user's ticket is expired
    function isTicketExpired(uint _ticketNumber) validTicketNumber(_ticketNumber) view public returns (bool) {
        Ticket memory ticket = users[msg.sender][_ticketNumber];
        return ticket.endTimestamp < block.timestamp;
    }
    
    // Gets the user's ticket
    function getUserTicket(uint _ticketNumber) validTicketNumber(_ticketNumber) view public returns (Ticket memory) {
        return users[msg.sender][_ticketNumber];
    }

    // Gets the user's all tickets
    function getUserAllTickets() view public returns (Ticket[] memory) {
        return users[msg.sender];
    }

    // Computes the ticket hash
    function getTicketHash(uint ticketNumber, Ticket memory _ticket) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            ticketNumber, _ticket.blockNumber, _ticket.startTimestamp, 
            _ticket.endTimestamp, _ticket.ticketType, _ticket.price));
    }

    // Computes the ticket duration
    function getTicketDuration(TicketType _type) internal pure returns (uint) {
        assert(_type <= TicketType.Yearly);

        uint hour = 60 * 60;
        uint day = 24 * hour;
        if (_type == TicketType.Single) {
            return 2 * hour;
        } else if (_type == TicketType.Daily) {
            return day;
        } else if (_type == TicketType.Weekly) {
            return 7 * day;
        } else if (_type == TicketType.Monthly) {
            return 31 * day;
        } else if (_type == TicketType.Yearly) {
            return 365 * day;
        }
        return 0;
    }
}
