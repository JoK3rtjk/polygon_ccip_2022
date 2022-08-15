// SPDX-License-Identifier: GPL-3.0
pragma solidity^0.8.0;

contract ccip{
    
    // CCIP is based on ERC721, an NFT standard
    // Each CCIP is a smart contract with a standard amount of carbon emission 
    // CCIPm1 is the smallest unit with carbon emission of 1 unit, which is 1m tonne of CO2
    // CCIPm2 represents carbon emission of 10 units 
    // CCIPm3 represents a specified amount of carbon emission
    // This is to reduce the incentives of speculative buying of carbon emission, if one party wants to split the carbon emission to sell it to different parties,
    // they bear a higher cost in terms of minting more CCIPm1. 

    //Every carbon offset credit will be entitled to mint their respective CCIP

    //Carbon credit registry organisation name
    string ccip_verified;
    //Blockchain wallet address of carbon credit issuer 
    address addressOfCarbonCreditIssuer;
    //Carbon offset project name
    string name_project;
    //Project org name, ccip issuer
    string name_projOrg;
    //url of project org
    string website_projOrg;
    // type of ccip
    enum ccip_type {m1, m2, m3}
    ccip_type _TYPE;
    // vintage year, year the carbon emission was offset
    uint vintage_year;
    //Amount in tonnes of carbon emission offset
    uint offset_amount; //unit is one metric ton of CO2
    //Name of project validator
    string proj_validator;
    //Owner of CCIP
    address ccip_owner;
    //State of CCIP
    enum State {New, Active, Retired}
    State _state;


    event CCIPdeployed (string nameCarbonReg, uint time, address addressIssuer, string nameProject, string nameOrg, ccip_type cciptype, uint year, uint offsetAmount);
    event mintEvent (address ccipOwner, uint time, uint offsetAmt);
    event retireCCIP (address ccip_owner, uint time, uint offsetAmt, string message);
    event transferEvent (address ccip_currentOwner, address ccip_newOwner, uint time, uint offsetAmt);
    // constructor for carbon credit registry to input the details they require
    constructor(string memory carbon_registry_org, address cci_address, string memory name, string memory organisation, uint cciptype, uint year, uint amt) {
        ccip_verified = carbon_registry_org;
        addressOfCarbonCreditIssuer = cci_address;
        name_project = name;
        name_projOrg = organisation;
        vintage_year = year;
        _state = State.New;
        if(cciptype == 1){
            _TYPE = ccip_type.m1;
            offset_amount = 1;
        } else if (cciptype == 2){
            _TYPE = ccip_type.m2;
            offset_amount = 10;
        } else {
            _TYPE = ccip_type.m3;
            offset_amount = amt;
        }
        emit CCIPdeployed (ccip_verified, block.timestamp, cci_address, name_project, name_projOrg, _TYPE, vintage_year, offset_amount);
    }

    // approvedAddress usually smart contract to transfer. 
    address private approvedAddress = address(0);

    modifier onlyCarbonCIssuer (){
        require (msg.sender == addressOfCarbonCreditIssuer, "Only carbon registry can mint");
        _;
    }

    modifier onlyCCIPowner (){
        require (msg.sender == ccip_owner, "Only valid for CCIP current owner");
        _;
    }

    modifier onlyApprovedUsers (){
        require (msg.sender == ccip_owner || msg.sender == approvedAddress, "Only valid for CCIP current owners or approved address");
        _;
    }

    function getOwner () public view returns (address){
        return ccip_owner;
    }

    function getAmount () public view returns (uint){
        return offset_amount;
    }

    function getApprovedaddress () internal view returns (address){
        return approvedAddress;
    }

    function mint (address _toOwner) public onlyCarbonCIssuer() {
        _safemint(_toOwner);
        
    }

    function _safemint (address owner) internal {
        require (owner != addressOfCarbonCreditIssuer, "Owner cannot be Carbon Credit Issuer");
        require (msg.sender != address(0), "cannot mint to 0");
        require (_state != State.Active, "CCIP has already been minted, please use transfer to change owners");
        require (_state != State.Retired, "CCIP has already been retired, please deploy a new CCIP");
        ccip_owner = owner;
        _state = State.Active;
        emit mintEvent (owner, block.timestamp, offset_amount);
    }

    function retire () public onlyCCIPowner(){
        require (_state == State.Active, "CCIP is currently not in an active status");
        _state = State.Retired;
        string memory retire_message = "Thank you for doing your part, the amount of carbon emission you have offset is succesfully retired!";
        emit retireCCIP(ccip_owner, block.timestamp, offset_amount, retire_message);
    }

    function transfer (address _to) public onlyApprovedUsers() {
        _safeTransfer (_to);
    }

    function _safeTransfer (address _transferTo) internal {
        require (msg.sender != address(0), "CCIP cannot be transferred to 0");
        require (_state == State.Active, "CCIP is not in an Active state");
        ccip_owner = _transferTo;
        approvedAddress = address(0);
        emit transferEvent (msg.sender, _transferTo, block.timestamp, offset_amount);
    }
     
   
    // For CCIP to be easily ported to carbon credit exchanges on blockchain
    // Allow smart contract as approved operator to buy and sell
    event Approval(address ccip_owner, address approved_operator, uint time);
    
    function approve(address _approved) public virtual onlyCCIPowner returns (bool) {
        _approve(_approved);
        return true;
    }

    function _approve (address _operator) internal {
        require (_state == State.Active, "CCIP is not in an active state");
        require(msg.sender != address(0), "Approved address cannot be 0");
        approvedAddress = _operator;
        emit Approval (msg.sender, _operator, block.timestamp);
    }


}
