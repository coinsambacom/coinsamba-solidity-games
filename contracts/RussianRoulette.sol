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

    struct Room {
        bool finished;
        uint256 entryPrice;
        address[] players;
        uint8 deadSeat;
        uint256 blockNumber;
    }

    uint256 public nextEntryPrice;

    mapping(uint256 => Room) rooms;
    uint256 public currentRoom;

    event PlayerJoined(address indexed player, uint256 indexed room);
    event Victim(address indexed victim, uint8 deadSeat, uint256 indexed room);

    constructor(uint256 nextEntryPrice_) {
        nextEntryPrice = nextEntryPrice_;
    }

    /// @notice Enter the current room and execute if the player is the sixth
    /// @param referrer The index of the player who was eliminated
    function enter(address referrer) external payable {
        if (rooms[currentRoom].blockNumber == 0) {
            rooms[currentRoom].blockNumber = block.number;
            rooms[currentRoom].entryPrice = nextEntryPrice;
        }

        require(rooms[currentRoom].players.length < 6);
        require(msg.value == nextEntryPrice);

        // referrer will receive 1 percent of entry price
        uint256 referrerCut = nextEntryPrice.div(100);
        Address.sendValue(payable(referrer), referrerCut);

        rooms[currentRoom].players.push(msg.sender);

        emit PlayerJoined(msg.sender, currentRoom);

        if (rooms[currentRoom].players.length == 6) {
            executeRoom();
        }
    }

    /// @notice Execute the current room
    function executeRoom() private {
        require(rooms[currentRoom].players.length == 6);

        uint8 victimSeat = random();

        distributeFunds(victimSeat);

        rooms[currentRoom].deadSeat = victimSeat;

        rooms[currentRoom].finished = true;

        currentRoom = currentRoom + 1;
    }

    /// @notice Make payment to winners
    /// @param victimSeat_ The index of the player who was eliminated
    function distributeFunds(uint8 victimSeat_) private {
        uint256 balanceToDistribute = address(this).balance.div(5);

        address victim = rooms[currentRoom].players[victimSeat_];

        for (uint8 i = 0; i < 6; i++) {
            if (i != victimSeat_) {
                Address.sendValue(
                    payable(rooms[currentRoom].players[i]),
                    balanceToDistribute
                );
            }
        }

        emit Victim(victim, victimSeat_, currentRoom);
    }

    /// @notice Returns a pseudorandom number that is equivalent to a player in the current room.
    /// @return Player index
    function random() private view returns (uint8) {
        return
            uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            msg.sender,
                            block.difficulty,
                            block.timestamp,
                            currentRoom
                        )
                    )
                ) % 6
            );
    }

    /// @notice Sets the new price to join the game
    /// @param nextEntryPrice_ The new entry price
    function setNextEntryPrice(uint256 nextEntryPrice_) external onlyOwner {
        nextEntryPrice = nextEntryPrice_;
    }

    /// @notice Return the current room details
    /// @param room The room that you need
    function getRoom(uint256 room)
        external
        view
        returns (
            bool,
            uint256,
            address[] memory,
            uint8,
            uint256
        )
    {
        Room memory _room = rooms[room];

        return (
            _room.finished,
            _room.entryPrice == 0 ? nextEntryPrice : _room.entryPrice,
            _room.players,
            _room.deadSeat,
            _room.blockNumber == 0 ? block.number : _room.blockNumber
        );
    }
}
