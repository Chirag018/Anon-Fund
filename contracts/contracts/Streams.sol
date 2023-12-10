pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Stream is Ownable {
    struct FundingStreamInfo {
        uint256 cap;
        uint256 last;
    }
    mapping(address => FundingStreamInfo) public streamedFunding;
    // ToDo. Change to 30 days
    uint256 public frequency = 2592000; // 30 days

    event Withdraw(address indexed to, uint256 amount, string reason);
    event AddFunders(address indexed to, uint256 amount);
    event UpdateFunder(address indexed to, uint256 amount);

    constructor() {}

    struct FunderData {
        address FunderAddress;
        uint256 cap;
        uint256 unlockedAmount;
    }

    function allFundersData(
        address[] memory _funders
    ) public view returns (FunderData[] memory) {
        FunderData[] memory result = new FunderData[](_funders.length);
        for (uint256 i = 0; i < _funders.length; i++) {
            address streamerAddress = _funders[i];
            FundingStreamInfo storage funderStream = streamedFunding[
                streamerAddress
            ];
            result[i] = FunderData(
                streamerAddress,
                funderStream.cap,
                unlockedStreamerAmount(streamerAddress)
            );
        }
        return result;
    }

    function unlockedStreamerAmount(
        address _streamer
    ) public view returns (uint256) {
        FundingStreamInfo memory funderStream = streamedFunding[_streamer];
        if (funderStream.cap == 0) {
            return 0;
        }

        if (block.timestamp - funderStream.last > frequency) {
            return funderStream.cap;
        }

        return
            (funderStream.cap * (block.timestamp - funderStream.last)) /
            frequency;
    }

    function addFunderStream(address payable _streamer, uint256 _cap) public {
        streamedFunding[_streamer] = FundingStreamInfo(
            _cap,
            block.timestamp - frequency
        );
        emit AddFunders(_streamer, _cap);
    }

    function addBatch(
        address[] memory _streamers,
        uint256[] memory _caps
    ) public onlyOwner {
        require(_streamers.length == _caps.length, "Lengths are not equal");
        for (uint256 i = 0; i < _streamers.length; i++) {
            addFunderStream(payable(_streamers[i]), _caps[i]);
        }
    }

    function updateFunderStreamCap(
        address payable _streamer,
        uint256 _cap
    ) public onlyOwner {
        FundingStreamInfo memory funderStream = streamedFunding[_streamer];
        require(streamerStream.cap > 0, "No active stream for streamer");
        streamedFunding[_streamer].cap = _cap;
        emit UpdateFunder(_streamer, _cap);
    }

    function streamWithdraw(uint256 _amount, string memory _reason) public {
        require(
            address(this).balance >= _amount,
            "Not enough funds in the contract"
        );
        FundingStreamInfo storage streamerStream = streamedFunding[msg.sender];
        require(streamerStream.cap > 0, "No active stream for streamer");

        uint256 totalAmountCanWithdraw = unlockedStreamerAmount(msg.sender);
        require(totalAmountCanWithdraw >= _amount, "Not enough in the stream");

        uint256 cappedLast = block.timestamp - frequency;
        if (streamerStream.last < cappedLast) {
            streamerStream.last = cappedLast;
        }

        streamerStream.last =
           streamerStream.last +
            (((block.timestamp - streamerStream.last) * _amount) /
                totalAmountCanWithdraw);

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, _amount, _reason);
    }

    // to support receiving ETH by default
    receive() external payable {}

    fallback() external payable {}
}
