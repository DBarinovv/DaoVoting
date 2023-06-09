// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;

// contract OpenDAO {
    
//     struct Proposal {
//         address creator;
//         string description;
//         uint256 yesVotes;
//         uint256 noVotes;
//         mapping(address => bool) voted;
//     }
    
//     mapping(address => uint256) public tokenBalances;
//     mapping(address => mapping(uint256 => Proposal)) public proposals;
//     mapping(address => uint256) public numProposals;
//     uint256 public totalTokens;
//     uint256 public minimumTokensToVote;
    
//     constructor(uint256 _minimumTokensToVote) {
//         minimumTokensToVote = _minimumTokensToVote;
//     }
    
//     function createProposal(string memory description) public {
//         require(tokenBalances[msg.sender] > 0, "You do not have any tokens to vote with.");
//         require(tokenBalances[msg.sender] >= minimumTokensToVote, "You do not have enough tokens to create a proposal.");
        
//         Proposal storage prop = proposals[msg.sender][numProposals[msg.sender]];
//         prop.creator = msg.sender;
//         prop.description = description;  
//         numProposals[msg.sender]++;
//     }
    
//     function vote(address creator, uint256 proposalId, bool choice) public {
//         require(tokenBalances[msg.sender] > 0, "You do not have any tokens to vote with.");
//         require(!proposals[creator][proposalId].voted[msg.sender], "You have already voted in this proposal.");
        
//         uint256 tokenBalance = tokenBalances[msg.sender];
//         proposals[creator][proposalId].voted[msg.sender] = true;
        
//         if (choice) {
//             proposals[creator][proposalId].yesVotes += tokenBalance;
//         } else {
//             proposals[creator][proposalId].noVotes += tokenBalance;
//         }
//     }
    
//     function addTokens(uint256 numTokens) public {
//         tokenBalances[msg.sender] += numTokens;
//         totalTokens += numTokens;
//     }
    
//     function removeTokens(uint256 numTokens) public {
//         require(tokenBalances[msg.sender] >= numTokens, "You do not have enough tokens to remove.");
        
//         tokenBalances[msg.sender] -= numTokens;
//         totalTokens -= numTokens;
//     }
    
//     function getProposal(address creator, uint256 proposalId) public view returns (string memory) {
//         return proposals[creator][proposalId].description;
//     }
    
//     function getVotes(address _creator, uint256 proposalId) public view returns (uint256, uint256) {
//         Proposal storage proposal = proposals[_creator][proposalId];
//         return (proposal.yesVotes, proposal.noVotes);
//     }
// }
