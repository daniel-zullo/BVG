![BVG_Logo_07 2021 svg](https://user-images.githubusercontent.com/6088143/190875201-ff2937e8-1b5d-4d91-9adb-82d7bd56941b.png)


Solidity smart contract to simulate buying a transport ticket from BVG.

The smart contract provides funtionality to set and query owners of the contract, set prices of different kind of tickets, and buy and query tickets.

The initial owner and tickets prices are set when the contract is deployed, and both can be updated through the public interface.

There are different kind of tickets based on their duration:
- Single (2 hours)
- Daily (24 hours)
- Weekly (7 days)
- Monthly (31 days)
- Yearly (365 days)

Read functions: 
  - [x] owners: Checks whether an address is an owner or not
  - [x] ticketPrices: Gets a ticket price given a ticket type
  - [x] users: Gets the tickets from a user
  - [x] getBalance(): Gets the balance of the contract
  - [x] isTicketExpired(uint _ticketNumber): Checks if the user's ticket is expired given a ticket number
  - [x] getUserTicket(uint _ticketNumber): Gets the user's ticket information given a ticket number
  - [x] getUserAllTickets(): Gets a list of all user's tickets


Write functions:
  - [x] setTicketPrice(TicketType _type, uint _price): Sets the price of a ticket, only owners are allowed to perform this transaction
  - [x] addOwner(address _owner): Adds an owner to the list of owners, only owners are allowed to perform this transaction
  - [x] withdraw(): Withdraw the total balance to an owner, only owners are allowed to perform this transaction
  - [x] buyTicket(TicketType _type): Buys a ticket and returns ticket number, ticket hash, and ticket information, any user can perform this transaction



