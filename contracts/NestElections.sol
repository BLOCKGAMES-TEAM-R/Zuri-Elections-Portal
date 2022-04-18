//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract NestElections {

    address public votersID;
    bool public voteEnabled;
    bool public isEligible = false;
    address private chairman;
    
    struct BOD {
        address _votersID;
    }


    struct Teachers {
        address _votersID;
    }

    struct students {
        address _votersID;
    }
    constructor() {

    }

    function voteNow() public {

    }
}
