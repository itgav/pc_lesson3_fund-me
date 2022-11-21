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

    function fund() public payable { // payable is a modifier that's required for payment
        uint256 minimumUSD = 0; // minimum funding of $0
        require(getConversionRate(msg.value) >= minimumUSD, "Need to spend at least 1 wei");

        // add sender to mapping, whatever the value was add that to the senders value in the mapping
        addressToAmountFunded[msg.sender] += msg.value; // msg.sender and msg.value are keywords in every contract call/transaction

        // what the ETH -> USD conversion rate is
    }

    // aggv3interface allows us to call that contract from this contract
    function getVersion() public view returns (uint256) {
        // type chainlink aggregator interface, make variable for the ETH/USD Goerli chainlink address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version(); 
        // calling version function from the aggregator interface
    }

    function getPrice() public view returns (uint256) {
        // type chainlink aggregator interface, make variable for the ETH/USD Goerli chainlink address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        // returning blanks for unused variables in tuple, calling 'latestRoundData' from interface
        (, int256 answer,,,) = priceFeed.latestRoundData();
        // ETH/USD in 18 digit
        return uint256(answer * 10e10); // need to type cast because variable in interface is of 'int'
    }

    // Not really sure the point of this function. The 'getPrice() returns eth*10^8, gwei*10^-1, or wei*10^-10
    // I would think to make this useful you would automatically convert to either eth, gwei, or wei instead of having a manual input
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10e18;
        return ethAmountInUsd;
    }

}
