# CCIP  

## Clone the repository 

## Install the dependecies, `npm install`
## `npm run dev`

## 1. CCIP is a smart contract, the front end deploys this smart contract based on user inputs. 
*Register* - Registering on the front end will deploy CCIP with the user input as constructor. 

## 2. CCIP uses the same mint function as NFT 
*Issue* - Issuing CCIP on the front end calls the mint function (note only CCIP deployer can mint), minting gives ownership to what the user inputs. Mint also changes the CCIP status to Active

## 3. CCIP uses the same transfer function as NFT
*Transfer* - Transfer owernship of CCIP based on the user input (note only owner of CCIP can transfer).

## 4. CCIP has a state to track its status. Extension of NFT
*Retire* - Retire invokes a function to change the state of CCIP to retire (note only CCIP owner can retire). Retire also records the blocktime when it was called. 

##CCIP is an NFT based carbon credit to provide transparency for the voluntary carbon credit. You can head over to https://ccip0x.netlify.app/ to test the demo site.


