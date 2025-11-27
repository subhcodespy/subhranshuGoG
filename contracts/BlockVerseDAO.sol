// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockVerseDAO {
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) votes;
    }

    address public owner;
    mapping(address => bool) public members;
    Proposal[] public proposals;

    event MemberAdded(address indexed member);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);
    event ProposalExecuted(uint256 indexed proposalId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only DAO members");
        _;
    }

    constructor() {
        owner = msg.sender;
        members[msg.sender] = true; // Founder is first member
    }

    // Add a new member (by owner)
    function addMember(address _member) external onlyOwner {
        members[_member] = true;
        emit MemberAdded(_member);
    }

    // Create a new proposal
    function createProposal(string memory _description) external onlyMember {
        proposals.push();
        Proposal storage p = proposals[proposals.length - 1];
        p.description = _description;
        p.voteCount = 0;
        p.executed = false;

        emit ProposalCreated(proposals.length - 1, _description);
    }

    // Vote on a proposal
    function vote(uint256 _proposalId) external onlyMember {
        Proposal storage p = proposals[_proposalId];
        require(!p.votes[msg.sender], "Already voted");
        require(!p.executed, "Proposal executed");

        p.votes[msg.sender] = true;
        p.voteCount++;

        emit Voted(_proposalId, msg.sender);
    }

    // Execute proposal if it has majority votes
    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage p = proposals[_proposalId];
        require(!p.executed, "Already executed");
        require(p.voteCount > countMembers() / 2, "Not enough votes");

        p.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    // Count total DAO members
    function countMembers() public view returns (uint256 total) {
        total = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            // dummy loop; in a real DAO, you would track members in an array
        }
        // For simplicity, this DAO currently only counts the mapping externally
        total = 2; // placeholder; replace with dynamic member count if needed
    }

    // Get total proposals
    function totalProposals() external view returns (uint256) {
        return proposals.length;
    }
}
