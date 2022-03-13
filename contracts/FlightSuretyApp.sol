pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    function authorizeContract(address contractAddress) external;
    function registerAirline(string _name, address _airlineAddress) external;
    function isOperational() external view returns(bool operational);
    function isAirlineAuthorized() external view returns(bool);
    function getAirlinesAmount() external view returns(uint);
    function buy(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp) external payable;
    function setCreditInsuree(address _userAddress, uint256 _creditInsurees, address _airlineAddress, string _flight, uint256 _timestamp) external;
    function pay(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp) external payable;
    function fund(address _airlineAddress) external payable;
    function getInsurancePaymentAmount(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp) external returns(uint256);
}

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20; // Este el código que va a disparar la lógica de devolución
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    address private contractOwner;          // Account used to deploy contract

    // Estructura para respaldar los Oracles
    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airline;
    }
    mapping(bytes32 => Flight) private flights;

    // Data Contract
    FlightSuretyData flightSuretyData;

    // Consensus class vars
    uint constant M = 50; // It's a percentage
    // With the consensus method implemented, the votes to register a new airline will remain in the blockchain to future queries. Check who voted, or the number of votes
    mapping(address => mapping(address => bool)) private airlinesInConsensusSamples; // First Address => airlineCandidateAddr, Second Address => airlineVoteAddr
    mapping(address =>  uint) private airlinesInConsensusAmount; // KeyAddress => airlineCandidateAddr, value => votesAmount

    // Operational array with mapping between Flight and user addresses with insurance. When a status 20 occurs, we will only walk the necessary addresses saving gas,
    mapping(bytes32 => address[]) userInsurancesByFlight; // bytes32 key => flightKey, address values => userAddress


    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor(address _dataContract)
    public
    {
        contractOwner = msg.sender;
        flightSuretyData = FlightSuretyData(_dataContract); // To find the contract, need pass the FlightSuretyData address
    }

    /********************************************************************************************/
    /*                                       EVENTS                                             */
    /********************************************************************************************/

    // Emitted when any authorized airline votes
    event AirlineVoted(string _name, address _airlineAddress);

    /********************************************************************************************/
    /*                                 FUNCTION MODIFIERS                                       */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
         // Modify to call data contract's status
        require(flightSuretyData.isOperational(), "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireIsAirlineAuthorized()
    {
        require(flightSuretyData.isAirlineAuthorized(), "Can't register new airline, the airline caller is not authorized");
        _;
    }

    modifier requireIsNotAirlineInConsensus(address airlineCandidate)
    {
        require(!airlinesInConsensusSamples[airlineCandidate][msg.sender], "The airline has already voted");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
    external
    view
    returns(bool)
    {
        return flightSuretyData.isOperational();  // Modify to call data contract's status
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    /**
     * @dev Add an airline to the registration queue
     *
     *   struct Airline {
     *    string name;
     *    address airlineAddress;
     *    uint256 registerTimestamp;
     *    bool isPendingDeposit;
     *   }
     */
    function registerAirline(string _name, address _airlineAddress)
    external
    requireIsOperational
    requireIsAirlineAuthorized
    returns(bool register, uint256 votes)
    {
        uint airlinesAmount = flightSuretyData.getAirlinesAmount();

        if (airlinesAmount <= 4) {
            flightSuretyData.registerAirline(_name, _airlineAddress);
            register = true;
            votes = 1;
        } else {
            // Si no funciona añadir var por delante
            (register, votes) = playConsensusGame(_name, _airlineAddress);
        }

        return (register, votes);
    }

    function playConsensusGame(string _name, address _airlineCandidateAddr)
    private
    requireIsNotAirlineInConsensus(_airlineCandidateAddr)
    returns(bool register, uint256 votes)
    {
        // Vote
        airlinesInConsensusSamples[_airlineCandidateAddr][msg.sender] = true;
        airlinesInConsensusAmount[_airlineCandidateAddr]++;

        // Prepare response values
        register = false;
        votes = airlinesInConsensusAmount[_airlineCandidateAddr];

        emit AirlineVoted(_name, _airlineCandidateAddr);

        // Play "N percent" > "M percent"
        if (airlinesInConsensusAmount[_airlineCandidateAddr] * 100 / flightSuretyData.getAirlinesAmount() > M) {
            flightSuretyData.registerAirline(_name, _airlineCandidateAddr);
            register = true;
        }

        return (register, votes);
    }

    function buy(address _airlineAddress, string _flight, uint256 _timestamp)
    external
    payable
    requireIsOperational
    {
        // Buy
        flightSuretyData.buy.value(msg.value)(msg.sender, _airlineAddress, _flight, _timestamp);

        // Set user to flight insures list
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);
        userInsurancesByFlight[flightKey].push(msg.sender);

    }

    function pay(address _airlineAddress, string _flight, uint256 _timestamp)
    external
    requireIsOperational
    {
        flightSuretyData.pay(msg.sender, _airlineAddress, _flight, _timestamp);
    }

    function fund()
    external
    payable
    {
        flightSuretyData.fund.value(msg.value)(msg.sender);
    }

   /**
    * @dev Register a future flight for insuring.
    * Puede estar hardcodeada en la DApp. Pero si queremos hacer un sistema de registro de vuelos, esta función esta para eso. Luego el usuario puede elegir de los que se muestran disponibles directamente en la DApp.
    */
//    function registerFlight()
//    external
//    view
//    requireIsOperational
//    {
//
//    }
    
   /**
    * @dev Called after oracle has updated flight status
    * Parte importante del código. Se disparará cuando un Oracle  regresa con un resultado y tiene que decidir a donde van las cosas a partir de ahí.
    * Si el vuelo salió a tiempo y devuelve un códdigo de estado que no es un 20, entonces tiene que determinar si sucede algo o si ocurren otras acciones del usuario.
    * En la mayoria de los casos, solo hay que reaccionar al código 20. en ese momento hay que buscar pasajeros que hayan comprado un seguro para este vuelo en particular, y comenzar el proceso que calcula cuanto se les debe pagar.
    */  
    function processFlightStatus(address _airlineAddress, string memory _flight, uint256 _timestamp, uint8 statusCode)
    internal
    requireIsOperational
    {
        address userAddress;
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);

        // Set credit on each user account with a insurance paid
        if (statusCode == STATUS_CODE_LATE_AIRLINE) {
            uint256 idx = 0;
            uint256 creditInsuree;
            uint256 usersToPayAmount = userInsurancesByFlight[flightKey].length;
            uint256 insurancePaymentAmount;

            for(; idx < usersToPayAmount; idx++){
                userAddress = userInsurancesByFlight[flightKey][idx];
                insurancePaymentAmount = flightSuretyData.getInsurancePaymentAmount(userAddress, _airlineAddress, _flight, _timestamp);
                creditInsuree = calculateCreditInsuree(insurancePaymentAmount);
                flightSuretyData.setCreditInsuree(userAddress, creditInsuree, _airlineAddress, _flight, _timestamp);
            }

            delete userInsurancesByFlight[flightKey];
        }
    }


    function calculateCreditInsuree(uint256 _insuranceAmount)
    private
    pure
    returns(uint256)
    {
        uint256 creditInsuree = _insuranceAmount * 2;

        return creditInsuree;
    }

    // Generate a request for oracles to fetch flight information
    /**
    * Esta es la funcion que se activa desde el interface de usuario mendiante un botón.
    * Será un botón el que haga click en la dapp del cliente (lo llamaremosobtener estado del vuelo), y generará el evento que luego será recogido por los oráculos y luego responderá a ellos.
    */
    function fetchFlightStatus
                            (
                                address airline,
                                string flight,
                                uint256 timestamp
                            )
    external
    requireIsOperational
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        emit OracleRequest(index, airline, flight, timestamp);
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function()
    external
    payable
    {
//        flightSuretyData.fund.value(msg.value)(msg.sender);
    }







    // -------------------------------------------- //
    //           region ORACLE MANAGEMENT           //
    // -------------------------------------------- //

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


    function isRegistredOracle()
    external
    view
    returns(bool, uint8[3])
    {
        bool isReg = oracles[msg.sender].isRegistered;
        uint8[3] memory indexes;

        if (isReg) {
            indexes = getMyIndexes();
        } else {
            indexes[0] = 0;
            indexes[1] = 0;
            indexes[2] = 0;
        }

        return (isReg, indexes);
    }

    // Register an oracle with the contract
    function registerOracle ()
    external
    payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
    }

    function getMyIndexes()
    public
    view
    returns(uint8[3])
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }


    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse(uint8 index, address airline, string flight, uint256 timestamp, uint8 statusCode)
    external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }


    function getFlightKey (address airline, string flight, uint256 timestamp)
    pure
    internal
    returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes(address account)
    internal
    returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex(address account)
    internal
    returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   
