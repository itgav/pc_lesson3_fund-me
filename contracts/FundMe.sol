// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0; // anything in the 8 range

// exact same as copy and pasting interface code in
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // pulls from npm
//import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; // stops value over flows --> automatic startic solidity v0.8, solidity will error

// contract to accept payment
contract FundMe {
    //using SafeMathChainlink for uint256; // don't need since using solidty v0.8+

    // can call the address to see the amount that's been funded
    mapping(address => uint256) public addressToAmountFunded;
    // need funders array so that we can zero out the mapping of each funder to their value
    // can not loop through a mapping so need to keep an array to know which map 'keys' to query and set their 'value' to zero
    address[] public funders;
    address public owner;

    constructor() { // immediately executed when contract is deployed
        owner = msg.sender; // When we deploy the smart contract it will set the deploying address as the owner
    }

    function fund() public payable { // payable is a modifier that's required for payment
        //uint256 minimumUSD = 5 * 10**18; // minimum funding of $0
        uint256 minimumUSD = 5 * 10**17; // set to 10e17 until figure out error with conversion rate
        require(getConversionRate(msg.value) >= minimumUSD, "Need to spend at least $5");

        // add sender to mapping, whatever the value was add that to the senders value in the mapping
        addressToAmountFunded[msg.sender] += msg.value; // msg.sender and msg.value are keywords in every contract call/transaction
        funders.push(msg.sender); // appends sender to the funders array
    }

    // aggv3interface allows us to call that contract from this contract
    function getVersion() public view returns (uint256) {
        // type chainlink aggregator interface, make variable for the ETH/USD Goerli chainlink address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version(); 
        // calling version function from the aggregator interface
    }

    // get price of Ethereum in USD, will return with 18 decimals
    function getPrice() public view returns (uint256) {

        /* commented out below so that I can use Java VM to test
        // type chainlink aggregator interface, make variable for the ETH/USD Goerli chainlink address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        // returning blanks for unused variables in tuple, calling 'latestRoundData' from interface
        (, int256 answer,,,) = priceFeed.latestRoundData();
        */

        int256 answer = 113170000000;

        // ETH/USD in 18 digit (WEI terms)
        return uint256(answer * 10e9); // need to type cast because variable in interface is of 'int'
    }

// 1120080000000000000000 // getPrice return
// 112008000000000000000 //getConversionRate return when input 10^18

    // !!! come back to, seems like overflow issue. Returning 1 less decimal than it should.
    // !!! try using int 256 for everything
    // !!! try safe math
    // Returns number in WEI terms, # returned is assuming to have 18 decimal places
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10e18;
        return ethAmountInUsd;
    }

    // modifier to be used for functions that you only want the owner to call
    modifier onlyOwner {
        require(msg.sender == owner); // before run function do this
        _; // '_' represents function do be done --> could also switch the order of these
    }

    // only let the contract owner/admin withdraw funds from the contract
    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance); // can call 'transfer' on any address to send ETH; 'this' keyword for contract currently in
        // for (start at 0th index; for each item; add (++) index to the funder index)
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // reset funders array to be of size zero
    }

}
