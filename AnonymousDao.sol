// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AnonymousDao {
    
    struct Proposal {
        address creator;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) voted;
    }
    
    uint numRequests;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public isVoter;
    mapping(address => uint) public tokenBalance;

    address public governorTokenAddress;
    uint256 public minimumTokensToVote;
    
    constructor(address _governorTokenAddress, uint _minimumTokensToVote) {
        governorTokenAddress = _governorTokenAddress;
        minimumTokensToVote = _minimumTokensToVote;
    }
    
    function createProposal(string memory description) public {
        require(isVoter[msg.sender], "Only voters can create proposals");

        Proposal storage prop = proposals[numRequests];
        prop.creator = msg.sender;
        prop.description = description;
        numRequests++;
    }
    
    function vote(uint proposalId, bool choice) public {
        require(isVoter[msg.sender], "Only voters can vote");
        require(proposalId < numRequests, "Invalid proposal index");
        require(!proposals[proposalId].voted[msg.sender], "You have already voted for this proposal");
        require(tokenBalance[msg.sender] >= minimumTokensToVote, "You do not have enough tokens to vote");
        
        proposals[proposalId].voted[msg.sender] = true;
        
        if (choice) {
            proposals[proposalId].yesVotes += tokenBalance[msg.sender];
        } else {
            proposals[proposalId].noVotes += tokenBalance[msg.sender];
        }
    }
    
    function addVoter(address voter, uint tokens) public {
        require(msg.sender == governorTokenAddress, "Only governor token contract can add voters");
        
        isVoter[voter] = true;
        tokenBalance[voter] = tokens;
    }
    
    function removeVoter(address voter) public {
        require(msg.sender == governorTokenAddress, "Only governor token contract can remove voters");
        
        isVoter[voter] = false;
        tokenBalance[voter] = 0;
    }
    
    function getProposalCount() public view returns (uint) {
        return numRequests;
    }
    
    function getProposal(uint index) public view returns (address, string memory, uint, uint) {
        require(index < numRequests, "Invalid proposal index");
        Proposal storage prop = proposals[index];
        return (prop.creator, prop.description, prop.yesVotes, prop.noVotes);
    }
}
