// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Election is Pausable, AccessControl {

    //string public name;
    address public chairman;
    uint public candidateCount = 0;
    uint public voteCount = 0;
    uint256 public deadline = block.timestamp + 24 hours;

    //Hash input for candidate manager role using keccak256 hashing
    bytes32 public constant CANDIDATE_MANAGER_ROLE = keccak256("CANDIDATE_MANAGER_ROLE");

    //Hash input for batch authorizer role using keccak256
    bytes32 public constant BATCH_AUTHORIZER_ROLE = keccak256("BATCH_AUTHORIZER_ROLE");
    
    constructor () public {
        chairman = msg.sender; 
        deadline = block.timestamp + 24 hours;
        //addCandidate = name;
       
        // Grants admin role to the contract deployer/chairman
        _setupRole(
            DEFAULT_ADMIN_ROLE, msg.sender
            );

        // Grants the contract deployer the default admin role of the candidate manager role
        _setRoleAdmin(
            CANDIDATE_MANAGER_ROLE, DEFAULT_ADMIN_ROLE
            );
        
        // Grants the contract deployer the default admin role of the batch authorizer role
        _setRoleAdmin(
            BATCH_AUTHORIZER_ROLE, DEFAULT_ADMIN_ROLE
            );

        //_renounceRole(CANDIDATE_SETTING_ROLE, account);

    }
     
    //using Counters for Counters.Counter;

    /// @notice total number of voters who votes
    /// @dev counts the number of items in the state variable `_voters`
    //Counters.Counter private _voters;

    /// @notice total number of items made candidates
    /// @dev counts the number of items in the state variable `_candidates`
    //Counters.Counter private _candidates;

    struct BOD {
        uint directorId;
        address director;
    }

    struct Teacher {
        uint teacherId;
        address teacher;
    }

    struct Student {
        uint studentId;
        address student;
    } 

   struct Candidate {
        uint voteCount;
        string name;
        uint candidateCount;
        uint addedTime;
        address candidateManager;
    }

   struct Voter {
        bool voted;
        uint voteIndex;
        uint weight;
        uint voteTime;
        address voterAddr;
    }


    ///MAPPINGS

    mapping(address => Voter) public voters;
    mapping(address => bool) public voted;
    mapping(uint => Candidate) public candidates;
    mapping(address => BOD) public directors;
    mapping(address => Teacher) public teachers;
    mapping(address => Student) public students;

   
   ///EVENTS

    event AddedCandidate(
        string indexed name, 
        uint indexed candidateCount, 
        uint indexed addedTime, 
        address indexed candidateManager
    );
    
    event votedEvent(uint indexed voted);

    event ElectionResult(
        string indexed name, 
        uint indexed voteCount
    );
    
    event AssignedCandidateManager(
        address indexed adder, 
        address indexed account
    );

    event AssignedBatchAuthorizer(
        address indexed adder, 
        address indexed account
    );

    event RemovedCandidateManager(
        address indexed adder, 
        address indexed account
    );

    event RemovedBatchAuthorizer(
        address indexed adder,
        address indexed account
    );


    modifier onlyAdmin() {
        require(
            isAdmin(msg.sender),
             "Restricted to only admin.");
        _;
    }

    modifier onlyCandidateManager() {
        require(
            isCandidateManager(msg.sender),
             "Restricted to only Candidate Managers.");
        _;
    }

    modifier onlyBatchAuthorizer() {
        require(
            isBatchAuthorizer(msg.sender),
             "Restricted to only Batch Authorizers.");
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



    function addCandidate(string memory name) public 
        
       whenPaused onlyCandidateManager {

        /// @dev Makes sure candidate name exists
        require(bytes(name).length > 0);

        /// @dev Makes sure candidate manager's address exists
        require(msg.sender != address(0));

        // @notice: Add a candidate to the election portal with the initial vote count at 0
        candidates[candidateCount] = Candidate(
            candidateCount,         // @dev: Records a unique ID for a candidate 
            name,                   // @dev: Records candidate name
            0,                      // @dev: Keeps candidate votecount at 0
            block.timestamp,        // @dev: Records the time candidate was added
            msg.sender              // @dev: Records the candidate manager's address
        );

        //Increment candidate counts
        candidateCount++; 

        //emits event of the candidate added
        emit AddedCandidate(
            name, 
            candidateCount, 
            block.timestamp, 
            msg.sender
        );
    }

    // function getCandidate(uint id) external view returns (string memory name, uint voteCount) {
    //     name = candidateLookup[id].name;
    //     voteCount = candidateLookup[id].voteCount;
    // }


    // @dev: function fetches all candidates with their votecounts
    // @notice: Allows all voters and admins to fetch all candidates with their vote counts
    function fetchAllCandidates() external view 
      
      // @dev: function can be called when paused to see all the candidate listed
      whenPaused returns (string[] memory, uint[] memory) {

          string[] memory names = new string[](candidateCount);
          uint[] memory voteCounts = new uint[](candidateCount);
          
          // @dev: loops through all candidates to fetch their names and vote counts
          for (uint i = 0; i < candidateCount; i++) {
              names[i] = candidates[i].name;
              voteCounts[i] = candidates[i].voteCount;
            }
            return (names, voteCounts);
        // @notice: Only returns vote counts with candidate names when voting ends
        //if(block.timestamp >= deadline) {
        //    return (names, voteCounts);
        //} else {
        //  return (names);
        //}
    }

    function batchAuthorizeVoters(address[] calldata authVoter) public 
    
      whenNotPaused onlyBatchAuthorizer {
     
        // @dev: Grants access to only a batch authorizer
        require(
            isBatchAuthorizer(msg.sender), 
            "Only batch authorizer can give right to vote."
            );

        //voters should not exceed 200 addresses
        require(
            authVoter.length <= 200, 
            "Number of addresses exceeds maximum allowable"
            );
    
         //access can't be granted to someone who has already voted
         //require(!voters[authVoter[i]].voted, "The voter has already voted.");
         //voter's weight must be zero before given a right to vote
         //require(voters[authVoter].weight == 0);

         // @dev: Loop through the addresses to set requirement 
        for (uint256 i = 0; i < authVoter.length; i++) {
            
            //@dev: address must be valid
            require(
                authVoter[i] != address(0), 
                "Cannot authorize address 0"
                );

            // @dev: access can't be granted to someone who has already voted
            require(
                !voters[authVoter[i]].voted, 
                "The voter has already voted."
                );

            // @dev: voter's weight must be zero before given a right to vote
            require(
                voters[authVoter[i]].weight == 0
                );
           
            // @dev: this counts the vote weight of 1 for the authorized voters 
            voters[authVoter[i]].weight = 1;
        }
    }

   ///@dev function to pause the contract
    function pause() public onlyAdmin {
        _pause();
    }

    ///@dev function to unpause the contract
    function unpause() public onlyAdmin {
        _unpause();
    }

    function vote(uint voteIndex) external whenNotPaused {

        // @dev: checks that the voting time hasn't passed
        require(
            block.timestamp < deadline
            );

        // @dev: allows voter that has not voted before
        require (
            !voters[msg.sender].voted, 
            "You can't vote twice"
            );

        // @dev: records the vote so the voter can only vote once
        voters[msg.sender].voted = true;
        voters[msg.sender].voteIndex = voteIndex;


        require (
            voteIndex >= 0 && voteIndex <= candidateCount-1
            );

        // @notice: Increments votes    
        candidates[voteIndex].voteCount++;

        //emits voting event
        emit votedEvent(voteIndex);
    }

    // @notice: records the timeleft for voting to end 
    // @dev: current time is deducted from 24 hours deadline
    function timeLeft() public view returns (uint256) {
        
        if(block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    } 

    // @notice: Allows Chairman to end the vote and reveals results after time has passed
    // @dev: stops vote, checks through all accounts and reveal results
    function end () public whenNotPaused onlyAdmin {
      require(msg.sender == chairman);
      require(block.timestamp >= deadline);

      for(uint i = 0; i < candidateCount; i++) {
          names[i] = candidates[i].name;
          voteCounts[i] = candidates[i].voteCount;
        }
        emit  ElectionResult(names, voteCounts);
    }
    }

    // @notice: Allows chairman and current candidate managers to add new candidate manager
    // @dev: Only a director account from the BOD struct can be assigned
    function assignCandidateManager(address account) public 
    
       // @dev: function can only be called when contract is not paused
       whenNotPaused onlyCandidateManager {
        
        // @dev: Checks if address is valid
        require(
            account != address(0), "Cannot assign to an invalid address"
            );

        // @notice: checks if address is a member of the board of director
        // @dev: the director property was drawn from the "directors" mappings
        require(
            account == directors[account].director
            );

        // @dev: Grant candidate setting role to a member of the board of directors
        grantRole(
            CANDIDATE_MANAGER_ROLE, account
            );
        
        /// @notice Emit event when a new moderator has been added
        emit AssignedCandidateManager(msg.sender, account);
    }

    // @notice add a new batch authorizer
    function assignBatchAuthorizer(address account) public 
    
        whenNotPaused onlyBatchAuthorizer {
        
        //checks if address is valid
        require(
            account != address(0), "Cannot assign to an invalid address"
            );

        // @dev: checks if address belongs to a teacher
        // @dev: the teacher property was drawn from the "teachers" mappings
        require(
            account == teachers[account].teacher
            );

        //Grant batch transfer role to a teacher
        grantRole(
            BATCH_AUTHORIZER_ROLE, account
            ); 
        
        /// @notice Emit event when a new moderator has been added
        emit AssignedBatchAuthorizer(msg.sender, account);
    }

    // @notice remove a candidate manager
    function removeCandidateManager(address account) public 
    
       whenNotPaused onlyCandidateManager {
        
        //checks if address is valid
        require(
            account != address(0), "Cannot remove an invalid address"
            );

        // @notice: only removes a candidate manager
        // @dev: requires account is a candidate manager
        require(
            account == account
            );

        // @notice: Removes an accosunt from candidate manager role
        revokeRole (
            CANDIDATE_MANAGER_ROLE, account
            );
        
        // @notice: Emits event when a candidate manager has been removed
        emit RemovedCandidateManager(msg.sender, account);
    }

    // @notice remove a batch authorizer
    function removeBatchAuthorizer(address account) public 
       
       whenNotPaused onlyBatchAuthorizer {
        
        //checks if address is valid
        require(
            account != address(0), "Cannot remove an invalid address"
            );

        // @notice: only removes a batch authorizer
        // @dev: requires account is a batch authorizer
        require(
            account == account
            );

        // Removes an account from batch authorizer role
        revokeRole(
            BATCH_AUTHORIZER_ROLE, account
            ); 
        
        /// @notice Emit event when a batch authorizer has been removed
        emit RemovedBatchAuthorizer(msg.sender, account);
    }


    /// @dev function to  check if a connected user is a moderator for mod's features visibility
    //   function checkMod(address _user) public view whenNotPaused returns(bool){
   //     bool isAdmin = admin[_user];
    //    return isAdmin;
    //}
}