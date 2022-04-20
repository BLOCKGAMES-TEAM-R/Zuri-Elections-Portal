// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Election is Pausable, AccessControl {
    
    uint public candidateCount;
    address public chairman;
    uint256 public deadline = block.timestamp + 24 hours;

    //Hash input using keccak256 hashing
    bytes32 public constant CANDIDATE_MANAGER_ROLE = keccak256("CANDIDATE_MANAGER_ROLE");

    //Hash input for batch authorizer role using keccak256
    bytes32 public constant BATCH_AUTHORIZER_ROLE = keccak256("BATCH_AUTHORIZER_ROLE");

    event AssignedBatchAuthorizer (address account);
    
    constructor () public {
        chairman = msg.sender;
        //chairman[msg.sender] = true;
        //moderator[msg.sender] = true;  
        deadline = block.timestamp + 24 hours;
       
        // Grant admin role to the contract deployer/chairman
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _setRoleAdmin(CANDIDATE_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        _setRoleAdmin(BATCH_AUTHORIZER_ROLE, DEFAULT_ADMIN_ROLE);



        //_renounceRole(CANDIDATE_SETTING_ROLE, account);

    }
     
    using Counters for Counters.Counter;

    /// @notice total number of voters who votes
    /// @dev counts the number of items in the state variable `_itemIds`
    Counters.Counter private _voters;

    /// @notice total number of items made private
    /// @dev counts the number of items in the state variable `_itemsPrivate`
    Counters.Counter private _candidates;

    struct BOD {
        uint directorId;
        address director;
    }

    struct Teachers {
        uint teacherId;
        address teacher;
    }

    //struct Students {
      //  address _votersID;
    //} 

   struct Candidate {
        uint candidateId;
        string name;
        uint voteCount;
    }

   struct Voter {
        bool voted;
        uint voteIndex;
        uint weight;
        //address _votersID;
    }


    mapping(address => Voter) public voter;
    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;

    event ElectionResult(string name, uint voteCount);


    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to only admin.");
        _;
    }

    modifier onlyCandidateManager() {
        require(isCandidateManager(msg.sender), "Restricted to only Candidate Managers.");
        _;
    }

    modifier onlyBatchAuthorizer() {
        require(isBatchAuthorizer(msg.sender), "Restricted to only Batch Authorizers.");
        _;
    }

     
    //@dev: Returns 'true' if the account belongs to an admin
    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }
    
    //@dev: Returns 'true' if the account belongs to a candidate manager
    function isCandidateManager(address account) public view returns (bool) {
        return hasRole(CANDIDATE_MANAGER_ROLE, account);
    }

    //@dev: Returns 'true' if the account belongs to a batch authorizer
    function isBatchAuthorizer(address account) public view returns (bool) {
        return hasRole(BATCH_AUTHORIZER_ROLE, account);
    }


    // @notice Ensure that only a moderator can call a specific function.
    // @dev Modifier to check that address is an assigned moderator.
//    modifier isMod(address _teacher) {
  //      bool ismod = moderator[_teacher];
    //    require(ismod, "Only Moderators Have Access!");
      //  _;
    //}


    function addCandidate(string memory name) public onlyRole (CANDIDATE_MANAGER_ROLE) {
        candidates[candidateCount] = Candidate(candidateCount, name, 0);
        candidateCount++; 
    }

    // function getCandidate(uint id) external view returns (string memory name, uint voteCount) {
    //     name = candidateLookup[id].name;
    //     voteCount = candidateLookup[id].voteCount;
    // }

    function fetchAllCandidates() external view returns (string[] memory names, uint[] memory voteCount) {
        string[] memory names = new string[](candidateCount);
        uint[] memory voteCounts = new uint[](candidateCount);
        for (uint i = 0; i < candidateCount; i++) {
            names[i] = candidates[i].name;
            voteCounts[i] = candidates[i].voteCount;
        }
        return (names, voteCounts);
    }

    function batchAuthorizeVoters(address[] calldata voter) public onlyRole (BATCH_AUTHORIZER_ROLE) {
        //grants access to only a batch authorizer
        require(isBatchAuthorizer(msg.sender), "Only batch authorizer can give right to vote.");
        //voters should not exceed 200 addresses
        require(voters.length <= 200, "Number of addresses exceeds maximum allowable");
        //access can't be granted to someone who has already voted
        require(!voters[voter].voted, "The voter has already voted.");
        //voter's weight must be zero before given a right to vote
        require(voters[voter].weight == 0);
           
        //this counts vote for the people we authorize for the weight of 1 
        voters[voter].weight = 1;
    }

   ///@dev function to pause the contract
    function pause() public isAdmin(msg.sender) {
        _pause();
    }

    ///@dev function to unpause the contract
    function unpause() public isAdmin(msg.sender) {
        _unpause();
    }

    function vote(uint voteIndex) external WhenNotPaused {
        //only accept a registered voter
        require (!voters[msg.sender]);

        //only accepts vote before voting ends
        require(block.timestamp < deadline);

        //voter has not voted before
        require(!voters[voter].voted, "You can't vote twice");

        //records the vote so the voter can only vote once
        voters[msg.sender].voted = true;
        voters[msg.sender].voteIndex = voteIndex;


        require (voteIndex >= 0 && voteIndex <= candidateCount-1);
        candidates[voteIndex].voteCount++;

        //emits voting event
        emit votedEvent(voteIndex);
    }

    event votedEvent(uint indexed voted);

    function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
    } 

    function endVote () private whenNotPaused onlyRole (DEFAULT_ADMIN_ROLE) {
      require(msg.sender == chairman);
      require(block.timestamp >= deadline);

      for(uint i = 0; i < candidates.length; i++){
          ElectionResult(candidates[i].name, candidates[i].voteCount);
      }
    }

  /// @notice add a new admin
    function assignCandidateManager(address account) public whenNotPaused onlyRole (DEFAULT_ADMIN_ROLE) {
        
        //checks if address is valid
        require(account != address(0), "Cannot delegate to address 0");

        //checks if address is a member of the board of director
        require(account == director);

        //Grant candidate setting role to a member of the board of directors
        _grantRole(CANDIDATE_MANAGER_ROLE, account);
        
        /// @notice Emit event when a new moderator has been added
        emit AssignCandidateManager(msg.sender, account);
    }

    /// @notice add a new admin
    function assignBatchAuthorizer(address account) public whenNotPaused onlyRole (DEFAULT_ADMIN_ROLE) {
        
        //checks if address is valid
        require(account != address(0), "Cannot delegate to address 0");

        //checks if address belongs to a teacher
        require(account == teacher);

        //Grant batch transfer role to a teacher
        _grantRole(BATCH_AUTHORIZER_ROLE, account); 
        
        /// @notice Emit event when a new moderator has been added
        emit AssignBatchAuthorizer(msg.sender, account);
    }

    /// @notice add a new admin
    function removeCandidateManager(address account) public whenNotPaused onlyRole (DEFAULT_ADMIN_ROLE) {
        
        //checks if address is valid
        require(account != address(0), "Cannot delegate to address 0");

        //checks if address is a member of the board of director
        require(account == director);

        //Grant candidate setting role to a member of the board of directors
        _revokeRole (CANDIDATE_MANAGER_ROLE, account);
        
        /// @notice Emit event when a new moderator has been added
        emit RemovedCandidateManager(msg.sender, account);
    }

    function removeBatchAuthorizer(address account) public whenNotPaused onlyRole (DEFAULT_ADMIN_ROLE) {
        
        //checks if address is valid
        require(account != address(0), "Cannot delegate to address 0");

        //checks if address belongs to a teacher
        require(account == teacher);

        //Grant batch transfer role to a teacher
        revokeRole(BATCH_AUTHORIZER_ROLE, account); 
        
        /// @notice Emit event when a new moderator has been added
        emit RemovedBatchAuthorizer(msg.sender, account);
    }


    /// @dev function to  check if a connected user is a moderator for mod's features visibility
 //   function checkMod(address _user) public view whenNotPaused returns(bool){
   //     bool isAdmin = admin[_user];
    //    return isAdmin;
    //}
}