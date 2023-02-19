// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RussianRoulette is Ownable {
    using SafeMath for uint256;

    uint256 public entryPrice = 0.1 ether;

    uint256 public room;
    address[] private players;

    event PlayerJoined(address indexed player, uint256 indexed room);
    event Victim(address indexed victim, uint256 indexed room);

    function enter(address referrer) external payable {
        require(players.length < 6);
        require(msg.value == entryPrice);

        // referrer will receive 1 percent of entry price
        uint256 referrerCut = entryPrice.div(100);
        referrer.transfer(referrerCut);

        players.push(msg.sender);

        emit PlayerJoined(msg.sender, room);

        if (players.length == 6) {
            executeRoom();
        }
    }

    function executeRoom() private {
        require(players.length == 6);

        uint256 victimSeat = random();

        distributeFunds(victimSeat);

        room = room + 1;

        players = new address[](0);
    }

    function distributeFunds(uint256 victimSeat_) private {
        uint256 balanceToDistribute = address(this).balance.div(5);

        address victim = players[victimSeat_];

        for (uint i = 0; i < 6; i++) {
            if (i != victimSeat_) {
                payable(players[i]).transfer(balanceToDistribute);
            }
        }

        emit Victim(victim, room);
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        block.difficulty,
                        block.timestamp,
                        room
                    )
                )
            ) % 6;
    }

    function setEntryPrice(uint256 entryPrice_) external onlyOwner {
        entryPrice = entryPrice_;
    }
}
