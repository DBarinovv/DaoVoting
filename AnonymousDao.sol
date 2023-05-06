// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AnonymousGovernor is Governor {
    IERC20 public token;

    mapping(uint256 => uint256) private _forVotes;
    mapping(uint256 => uint256) private _againstVotes;
    mapping(uint256 => mapping(address => bool)) private _voted;

    uint256 private _votingDelay;
    uint256 private _votingPeriod;

    event ProposalCreated(uint256 indexed proposalId);

    constructor(
        IERC20 token_,
        string memory name,
        uint256 votingDelay_,
        uint256 votingPeriod_
    ) Governor(name) {
        token = token_;
        _votingDelay = votingDelay_;
        _votingPeriod = votingPeriod_;
    }

    function createProposal(
        string memory description,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public returns (uint256) {
        uint256 proposalId = propose(targets, values, calldatas, description);
        emit ProposalCreated(proposalId);
        return proposalId;
    }

    function vote(
        uint256 proposalId,
        bool support,
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!_voted[proposalId][msg.sender], "Already voted.");

        // Verify the blind signature
        require(
            verifyBlindSignature(msg.sender, messageHash, v, r, s),
            "Invalid blind signature."
        );

        uint256 weight = token.balanceOf(msg.sender);

        if (support) {
            _forVotes[proposalId] += weight;
        } else {
            _againstVotes[proposalId] += weight;
        }

        _voted[proposalId][msg.sender] = true;
    }

    function getVotes(uint256 proposalId)
        public
        view
        returns (uint256 forVotes, uint256 againstVotes)
    {
        return (_forVotes[proposalId], _againstVotes[proposalId]);
    }

    function verifyBlindSignature(
        address voter,
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        // Recover signer's address from the provided signature
        address signer = ecrecover(messageHash, v, r, s);

        // Check if the signer's address matches the voter's address
        return signer == voter;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(Governor)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function state(uint256 proposalId)
        public
        view
        virtual
        override(Governor)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function quorum(uint256 blockNumber)
        public
        view
        virtual
        override(Governor)
        returns (uint256)
    {
        return token.totalSupply() / 2;
    }

    function votingDelay() public view virtual override(Governor) returns (uint256) {
        return _votingDelay;
    }
}
