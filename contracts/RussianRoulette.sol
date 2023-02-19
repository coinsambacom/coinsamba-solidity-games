// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Russian Roulette gambling game
/// @author Coinsamba Team
/// @notice This contract was created to be used in the Coinsamba Russian Roulette game
contract RussianRoulette is Ownable {
    using SafeMath for uint256;

    uint256 public entryPrice = 0.1 ether;

    uint256 public room;
    address[] private players;

    event PlayerJoined(address indexed player, uint256 indexed room);
    event Victim(address indexed victim, uint256 indexed room);

    /// @notice Enter the current room and execute if the player is the sixth
    /// @param referrer The index of the player who was eliminated
    function enter(address referrer) external payable {
        require(players.length < 6);
        require(msg.value == entryPrice);

        // referrer will receive 1 percent of entry price
        uint256 referrerCut = entryPrice.div(100);
        Address.sendValue(payable(referrer), referrerCut);

        players.push(msg.sender);

        emit PlayerJoined(msg.sender, room);

        if (players.length == 6) {
            executeRoom();
        }
    }

    /// @notice Execute the current room
    function executeRoom() private {
        require(players.length == 6);

        uint256 victimSeat = random();

        distributeFunds(victimSeat);

        room = room + 1;

        players = new address[](0);
    }

    /// @notice Make payment to winners
    /// @param victimSeat_ The index of the player who was eliminated
    function distributeFunds(uint256 victimSeat_) private {
        uint256 balanceToDistribute = address(this).balance.div(5);

        address victim = players[victimSeat_];

        for (uint i = 0; i < 6; i++) {
            if (i != victimSeat_) {
                Address.sendValue(payable(players[i]), balanceToDistribute);
            }
        }

        emit Victim(victim, room);
    }

    /// @notice Returns a pseudorandom number that is equivalent to a player in the current room.
    /// @return Player index
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

    /// @notice Sets the new price to join the game
    /// @param entryPrice_ The new entry price
    function setEntryPrice(uint256 entryPrice_) external onlyOwner {
        entryPrice = entryPrice_;
    }
}
