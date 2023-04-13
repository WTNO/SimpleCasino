//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Casino {
    address public owner;
    uint256 public minimumBet; // 最小投注额
    uint256 public totalBet; // 所有投注额
    uint256 public numberOfBets; // 投注数
    uint256 public maxAmountOfBets = 100; // 最大投注数
    address[] public players; // 玩家数组

    struct Player {
        uint256 amountBet; // 每个玩家投注的数额
        uint256 numberSelected; // 每个玩家投注的数
    }

    mapping(address => Player) public playerInfo;

    modifier onlyOwner {
        require(msg.sender == owner)
    }

    constructor(uint256 _minimumBet) public {
        owner = msg.sender;
        if (_minimumBet != 0) {
            minimumBet = _minimumBet;
        }
    }

    // 对1~10之间的数下注
    function bet (uint256 numberSelected) public payable {
        require(!checkPalyerExists(msg.sender)); // 玩家必须不存在
        require(numberSelected >=1 & numberSelected <= 10); // 玩家可投注数在1~10之间
        require(msg.value >= minimumBet); // 投注额必须大于最低投注额
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++; // 投注者总数加一
        players.push(msg.sender); // 加新玩家到玩家数组
        totalBet += msg.value; // 总投注额调整

        if (numberOfBets >= maxAmountOfBets)
            generateNumberWinner();

    }

    function checkPalyerExists(address player) private pure returns(bool) {
        for (uint256 i = 0;i < players.length; i++) {
            if (plays[i] == player)
                return true;
        }
        return false;
    }

    function generateNumberWinner() private {
        uint256 numberGenerateed = block.number % 10 + 1; // 这种生成方式是不安全的
        distributePrizes(numberGenerateed);
    }

    function distributePrizes(uint256 numberWinner) public {
        address[100] memory winners;
        uint256 count = 0; // 赢家计数器
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == numberWinner) {
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress]; // 删除所有玩家
        }
        players.length = 0; // 删除所有玩家数组
        uint256 winnerEtherAmount = totalBet / winners.length;
        for (uint256 j = 0; j < count; j++) {
            if (winners[j] != address(0)) {
                winners[j].transfer(winnerEtherAmount); // 最好的方式应该是approve + transferFrom
            }
        }
    }

    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}