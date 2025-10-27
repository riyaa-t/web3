// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title QuantumBase
 * @dev A decentralized data storage and verification system using quantum-inspired hashing
 * @notice This contract provides secure data storage with immutable records and verification
 */
contract QuantumBase {
    
    // Struct to store data records
    struct DataRecord {
        bytes32 dataHash;
        address owner;
        uint256 timestamp;
        bool isActive;
        string metadata;
    }
    
    // Mapping from record ID to DataRecord
    mapping(uint256 => DataRecord) public records;
    
    // Mapping from address to their record IDs
    mapping(address => uint256[]) public ownerRecords;
    
    // Counter for record IDs
    uint256 public recordCount;
    
    // Events
    event RecordCreated(uint256 indexed recordId, address indexed owner, bytes32 dataHash, uint256 timestamp);
    event RecordVerified(uint256 indexed recordId, address indexed verifier, bool isValid);
    event RecordDeactivated(uint256 indexed recordId, address indexed owner);
    
    /**
     * @dev Creates a new data record with quantum-inspired hashing
     * @param _data The data to be stored (hashed on-chain)
     * @param _metadata Additional metadata about the record
     * @return recordId The ID of the newly created record
     */
    function createRecord(string memory _data, string memory _metadata) public returns (uint256) {
        require(bytes(_data).length > 0, "Data cannot be empty");
        
        recordCount++;
        uint256 newRecordId = recordCount;
        
        // Create quantum-inspired hash combining data, timestamp, and sender
        bytes32 dataHash = keccak256(abi.encodePacked(_data, block.timestamp, msg.sender));
        
        // Store the record
        records[newRecordId] = DataRecord({
            dataHash: dataHash,
            owner: msg.sender,
            timestamp: block.timestamp,
            isActive: true,
            metadata: _metadata
        });
        
        // Add to owner's records
        ownerRecords[msg.sender].push(newRecordId);
        
        emit RecordCreated(newRecordId, msg.sender, dataHash, block.timestamp);
        
        return newRecordId;
    }
    
    /**
     * @dev Verifies if provided data matches a stored record
     * @param _recordId The ID of the record to verify
     * @param _data The data to verify against the stored hash
     * @return isValid True if the data matches the stored record
     */
    function verifyRecord(uint256 _recordId, string memory _data) public returns (bool) {
        require(_recordId > 0 && _recordId <= recordCount, "Invalid record ID");
        require(records[_recordId].isActive, "Record is not active");
        
        DataRecord memory record = records[_recordId];
        
        // Recreate the hash with original parameters
        bytes32 verifyHash = keccak256(abi.encodePacked(_data, record.timestamp, record.owner));
        
        bool isValid = (verifyHash == record.dataHash);
        
        emit RecordVerified(_recordId, msg.sender, isValid);
        
        return isValid;
    }
    
    /**
     * @dev Deactivates a record (only owner can deactivate)
     * @param _recordId The ID of the record to deactivate
     */
    function deactivateRecord(uint256 _recordId) public {
        require(_recordId > 0 && _recordId <= recordCount, "Invalid record ID");
        require(records[_recordId].owner == msg.sender, "Only owner can deactivate");
        require(records[_recordId].isActive, "Record already deactivated");
        
        records[_recordId].isActive = false;
        
        emit RecordDeactivated(_recordId, msg.sender);
    }
    
    /**
     * @dev Retrieves all record IDs owned by an address
     * @param _owner The address to query
     * @return An array of record IDs
     */
    function getOwnerRecords(address _owner) public view returns (uint256[] memory) {
        return ownerRecords[_owner];
    }
    
    /**
     * @dev Gets detailed information about a specific record
     * @param _recordId The ID of the record
     * @return dataHash The hash of the stored data
     * @return owner The owner's address
     * @return timestamp When the record was created
     * @return isActive Whether the record is active
     * @return metadata Additional metadata
     */
    function getRecordDetails(uint256 _recordId) public view returns (
        bytes32 dataHash,
        address owner,
        uint256 timestamp,
        bool isActive,
        string memory metadata
    ) {
        require(_recordId > 0 && _recordId <= recordCount, "Invalid record ID");
        
        DataRecord memory record = records[_recordId];
        return (
            record.dataHash,
            record.owner,
            record.timestamp,
            record.isActive,
            record.metadata
        );
    }
}
