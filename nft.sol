// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

//Importación de modulos que necesitaremos para este proyecto.
import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";

//Creación de nuestro Smart Contract 
contract NFT is ERC721, Ownable{

    // ==================================
    // Declaración de variables
    // ==================================

    //Constructor de nuestro smart contract
    constructor (string memory _name, string memory _symbol)
    ERC721(_name,_symbol){}

    // Necesitamos un contador - Contador de token NFT
    uint256 COUNTER;

    // Necesitamos precio de nuestros tokens NFTs - Precio de Nuestros NFTs
    uint256 fee = 5 ether;

    // Precio para subir de nivel a nuestro token NFT
    uint256 feeLevel = 5 ether;

    // Estructura de datos con las propiedades de nuestro proyecto NFT
    struct Nft {
        string name;
        uint256 id;
        uint256 dna;
        uint8 level;
        uint8 rarity;
    }

    // Estructura de almacenamiento ara guardar nuestros NFT
    Nft [] public nfts;

    // Declaración de un evento 
    event NewNFT ( address indexed owner, uint256 id, uint256 dna);

    // ==================================
    // Funciones de ayuda
    // ==================================

    //CREACIÓN DE UNA FUNCIÓN PARA CREAR UN NUMERO RANDOM.
    function _createRandomNumber(uint256 _mod) internal view returns (uint256){
        bytes32 hash_randomNumber = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        uint256 randomNumber = uint256(hash_randomNumber);
        return randomNumber % _mod;
    }

    //Creación del Token NFT - GENERACIÓN DEL TOKEN NFT
    function _createNFT(string memory _name) internal{
        uint8 randomRarity = uint8(_createRandomNumber(1000));
        uint256 randomDna = _createRandomNumber(10**16);
        Nft memory newNFT = Nft(_name, COUNTER, randomDna, 1, randomRarity);
        nfts.push(newNFT);
        _safeMint(msg.sender, COUNTER);
        emit NewNFT(msg.sender, COUNTER, randomDna);
        COUNTER++;
    }

    //GESTIÓN ECONOMICA DEL TOKEN NFT.

    //UPDATE DEL PRECIO DEL TOKEN NFT
    function updateFee(uint256 _fee) external onlyOwner{
        fee = _fee;
    }

    //Update del fee para subir de nivel del NFT.
    function updatefeelevel(uint _feeLevel) external onlyOwner{
        feeLevel = _feeLevel;
    }

    //Visualización del balance del SMART CONTRACT
    function infoSmartContract() public view returns(address, uint256){
        address SmartContract_address = address(this);
        uint SmartContract_money = address(this).balance/ 10**18;
        return (SmartContract_address, SmartContract_money);
    }

    //Obtener todos los NFT creados
    function getallNFT() public view returns (Nft [] memory){
        return nfts;
    }

    //Obtener los tokens NFTs de un usuario
    function getOwnerNFT(address _owner) public view returns (Nft [] memory){
        Nft [] memory result = new Nft[](balanceOf(_owner));
        uint256 counter_owner = 0;
        for(uint256 i = 0 ; i< nfts.length ; i++ ){
            if(ownerOf(i) == _owner){
                result[counter_owner] = nfts[i];
                counter_owner++;
            }
        }
        return result;
    }

    // ==================================
    // DESARROLLO DEL TOKEN NFT
    // ==================================

    //Pago del Token NFT
    function createRandomNFT(string memory _name) public payable{
        require(msg.value >= fee, "Chequea el balance para pagar el minimo del precio del NFT");
        _createNFT(_name);
    }

    //Extracción de los ether (beneficios) del smart contract del owner.
    function withdraw() external payable onlyOwner{
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    //Subir nivel del NFT
    function levelUp(uint256 _nftid) public payable{
        require(msg.value >= feeLevel, "Chequea el balance para pagar el minimo del precio para subir de level del NFT");
        require(ownerOf(_nftid) == msg.sender, "No tienes permiso para incrementar el nivel");
        Nft storage nft = nfts[_nftid];
        nft.level++;
    }

}
