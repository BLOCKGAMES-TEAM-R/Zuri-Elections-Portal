# Advanced Sample Hardhat Project

This project demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"



Contract Address: https://rinkeby.etherscan.io/tx/0x77ca31e02897fa8fc5d97c597fb6eba60e5ae433b391f98af2da82bf21ae8b97

Team repo: https://github.com/BLOCKGAMES-TEAM-R/Zuri-Elections-Portal

# Nest Elections Project (Team R)

## Problem Statement: 
### ZURI as an organisation needs to setup an election for leadership position in its school. The major stakeholders here are the school board of directors, the teachers and the students. Create a smart contract that enables the following:
> Each stakeholders should be able to vote.

> Setup Access control for all stakeholders

> Only the chairman and teachers can setup and compile the result of the votes

> Only the chairman can grant access for the vote to happen.(There should be enable and disable vote.). If vote is disabled, no voting should take place.

> Students should not see result of votes until made public by the other stakeholders

# Team Members:
    >> Clinton Chukwunenye F.
    >> Gbolahan Adebayo
    >> Majid Kareem
    >> Oluwafemi Banji
