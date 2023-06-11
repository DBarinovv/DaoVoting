pragma solidity ^0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract BlindVoting {
    using SafeMath for uint256;

    struct Vote {
        bytes32 blindVote;
        bool isRevealed;
    }

    address public authority;
    mapping(address => Vote) public votes;
    mapping(bytes32 => bool) public usedTokens;
    uint256 public yesVotes;
    uint256 public noVotes;

    constructor(address _authority) public {
        authority = _authority;
    }

    function submitVote(bytes32 _blindVote, bytes32 _token) public {
        require(!usedTokens[_token], "Token has already been used.");
        votes[msg.sender] = Vote(_blindVote, false);
        usedTokens[_token] = true;
    }

    function revealVote(uint256 _vote, bytes _blindFactor, bytes32 _token) public {
        require(!votes[msg.sender].isRevealed, "Vote has already been revealed.");
        require(keccak256(abi.encodePacked(_vote, _blindFactor)) == votes[msg.sender].blindVote, "Vote does not match committed vote.");
        
        if (_vote == 1) {
            yesVotes = yesVotes.add(1);
        } else if (_vote == 0) {
            noVotes = noVotes.add(1);
        } else {
            revert("Invalid vote.");
        }
        
        votes[msg.sender].isRevealed = true;
    }

    function getResults() public view returns (uint256 _yesVotes, uint256 _noVotes) {
        return (yesVotes, noVotes);
    }
}
