pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    // Authorized callers
    mapping(address => bool) private authorizedContracts;

    // Airline vars
    struct Airline {
        string name;
        address airlineAddress;
        bool isPendingDeposit;
    }
    mapping(address => Airline) private airlines;
    uint private airlinesAmount = 0;

    // User account vars
    struct Insurance {
        address airline;
        string flight;
        uint256 timestamp;
        uint256 insuranceAmount;
        uint256 creditInsuree;
    }
    struct User {
        address userAddress;
        bool isActive;
        mapping(bytes32 => Insurance) insurances; // bytes32 key => flightKey
    }
    mapping(address => User) private userAccounts; // address key => userAddress

    // Max insurance value (configurable by onlyOwner method)
    uint256 maxInsuranceCharge = 1;


    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Constructor
    *       The deploying account becomes contractOwner
    *
    *       The deployer is the original owner, not the contract caller
    */
    constructor(string _name, address _airlineAddress)
    public
    {
        contractOwner = msg.sender;
        registerAirline(_name, _airlineAddress);
    }

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // Emitted when the airline pass the consensus
    event AirlineAccepted(string _name, address _airlineAddress);
    // Emitted when the airline deposit de insurance amount
    event AirlineRegistred(string _name, address _airlineAddress);
    // Emitted when user buy an insurance
    event PurchasedInsurance(address _userAddress, address _airlineAddress, string _flight, uint256 timestamp);
    // Emitted when the insurance credit to refund is set to user account
    event InsuranceCreditAvailableToRefund(address _userAddress, uint256 _creditInsurees, address _airlineAddress, string _flight, uint256 _timestamp);
    // Emitted when the insurance credit is refunded
    event InsuranceCreditRefunded(address _userAddress, uint256 refund, address _airlineAddress, string _flight, uint256 _timestamp);

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
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
        require(operational, "Contract is currently not operational");
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

    modifier requireIsCallerAuthorized()
    {
        require(authorizedContracts[msg.sender] || msg.sender == contractOwner, "Caller not authorized");
        _;
    }

    modifier requireIsAirlinePendingDeposit(address _airlineAddress)
    {
        require(airlines[_airlineAddress].isPendingDeposit, "Airline not authorized to deposit funds");
        _;
    }

    modifier requireIsAirlinePaidEnough()
    {
        require(msg.value >= 10 ether, "Insufficent funds, must be 10 ether");
        _;
    }

    modifier requireIsUserPaidEnough() {
        require(msg.value >= 0, "Incorrect deposit, must be a maximum of 1 ether");
        _;
    }

    modifier requireIsUserActive(address _userAddress)
    {
        require(userAccounts[_userAddress].isActive, "User not exists");
        _;
    }

    modifier requireIsElegiblePayout(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp)
    {
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);
        require(userAccounts[_userAddress].insurances[flightKey].creditInsuree > 0, "User is not elegible to payout");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational()
    external
    view
    returns(bool)
    {
        return operational;
    }

    function isAirlineAuthorized()
    external
    view
    returns(bool)
    {
        return !airlines[msg.sender].isPendingDeposit;
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus(bool mode)
    external
    requireContractOwner
    {
        operational = mode;
    }

    function authorizeContract(address contractAddress)
    public
    requireContractOwner
    {
        authorizedContracts[contractAddress] = true;
    }

    function deauthorizeContract(address contractAddress)
    external
    requireContractOwner
    {
        delete authorizedContracts[contractAddress];
    }

    function setMaxInsuranceCharge(uint256 _maxInsuranceCharge)
    external
    requireContractOwner
    {
        maxInsuranceCharge = _maxInsuranceCharge;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function getAirlinesAmount()
    external
    view
    requireIsOperational
    requireIsCallerAuthorized
    returns(uint)
    {
        return airlinesAmount;
    }


    /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    *   struct Airline {
    *    string name;
    *    address airlineAddress;
    *    bool isPendingDeposit;
    *   }
    */
    function registerAirline(string _name, address _airlineAddress)
    public
    requireIsOperational
    requireIsCallerAuthorized
    {
        Airline memory newAirline = Airline(
            _name,
            _airlineAddress,
            true
        );
        airlines[_airlineAddress] = newAirline;
        airlinesAmount++;

        emit AirlineAccepted(_name, _airlineAddress);
    }

   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp)
    external
    payable
    requireIsOperational
    requireIsCallerAuthorized
    requireIsUserActive(_userAddress)
    requireIsUserPaidEnough
    {
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);

        if (msg.value > maxInsuranceCharge) {
            // Set payment
            userAccounts[_userAddress].insurances[flightKey].insuranceAmount = maxInsuranceCharge;

            // Return the difference
            uint amountToReturn = msg.value - maxInsuranceCharge;
            _userAddress.transfer(amountToReturn);
        } else {
            // Set payment
            userAccounts[_userAddress].insurances[flightKey].insuranceAmount = msg.value;
        }

        // Inform to listeners
        emit PurchasedInsurance(msg.sender, _airlineAddress, _flight, _timestamp);
    }

    function getInsurancePaymentAmount(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp)
    external
    view
    requireIsOperational
    requireIsCallerAuthorized
    returns(uint256)
    {
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);

        return userAccounts[_userAddress].insurances[flightKey].insuranceAmount;
    }

    /**
     *  @dev Credits payouts to insurees
     * Queremos asegurarnos de no enviar los fondos directamente. Primero acreditar si los usuarios son elegibles para un pago y luego, cuando llega en momento de los pagos, podemos llamar a la función pay para retirar los fondos
    */
    function setCreditInsuree(address _userAddress, uint256 _creditInsurees, address _airlineAddress, string _flight, uint256 _timestamp)
    external
    requireIsOperational
    requireIsCallerAuthorized
    {
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);
        userAccounts[_userAddress].insurances[flightKey].creditInsuree = _creditInsurees;

        emit InsuranceCreditAvailableToRefund(_userAddress, _creditInsurees, _airlineAddress, _flight, _timestamp);
    }


    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay(address _userAddress, address _airlineAddress, string _flight, uint256 _timestamp)
    external
    payable // TODO: Must be payable?
    requireIsOperational
    requireIsCallerAuthorized
    requireIsElegiblePayout(_userAddress, _airlineAddress, _flight, _timestamp)
    {
        // Reset insurace vars
        bytes32 flightKey = getFlightKey(_airlineAddress, _flight, _timestamp);
        uint256 refund = userAccounts[_userAddress].insurances[flightKey].creditInsuree;
        userAccounts[_userAddress].insurances[flightKey].creditInsuree = 0;
        userAccounts[_userAddress].insurances[flightKey].insuranceAmount = 0;

        // Refund
        _userAddress.transfer(refund);

        emit InsuranceCreditRefunded(_userAddress, refund, _airlineAddress, _flight, _timestamp);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    * El lo que la aerolinea usaría para activarse ella misma.
    * Las aerolineas pasan por un proceso de 2 pasos: primero deben registrarse, y después de la cuarta aerolinea deben esperar que el resto de aerolineas voten. Una vez hecho esto, deben ingresar (fund) los 10 ethers para estar activos en el contrato
    */   
    function fund(address _airlineAddress)
    public
    payable
    requireIsOperational
    requireIsCallerAuthorized
    requireIsAirlinePendingDeposit(_airlineAddress)
    requireIsAirlinePaidEnough
    {
        // Set the airline deposit up to date
        airlines[_airlineAddress].isPendingDeposit = false;

        // Return the payment difference to sender
        uint amountToReturn = msg.value - 10 ether;
        _airlineAddress.transfer(amountToReturn);

        emit AirlineRegistred(airlines[_airlineAddress].name, airlines[_airlineAddress].airlineAddress);
    }

    function getFlightKey
    (
        address airline,
        string memory flight,
        uint256 timestamp
    )
    view
    internal
    requireIsOperational
    returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
//    function()
//    external
//    payable
//    {
//        fund();
//    }
}

