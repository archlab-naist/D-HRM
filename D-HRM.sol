 //******************************************************//
 // Project Name: Decentralized Health Record Management System 
 // Instructor: Nakashima Yasuhiko, Tran Thi Hong
 // Student: Pham Hoai Luan
 // This code is written by Pham Hoai Luan on Jan. 2020
 //******************************************************//


pragma solidity ^0.4.18;



contract HRM_SC{



    address public Government;


    modifier onlyGovernment() {
        require(msg.sender == Government);
        _;
    }



    function HRM_SC() public {
        Government = msg.sender;
    }

    //******************************************************//
    //                                                      //
    //       Government Structure Smart Contract            //
    //                                                      //
    //******************************************************//

    mapping (address => bool) Hospital;

    function Authorize_Hospital(address _HospitalAddress) onlyGovernment public {
        Hospital[_HospitalAddress] = true;
    }

    function Unthorize_Hospital(address _HospitalAddress) onlyGovernment public {
        Hospital[_HospitalAddress] = false;
    }

    function Get_Authorize_Hospital(address _HospitalAddress) view public returns (bool) {
        return (Hospital[_HospitalAddress]);
    }
    
    //******************************************************//
    //                                                      //
    //          Hospital Structure Smart Contract           //
    //                                                      //
    //******************************************************//
    
    modifier onlyHospital() {
        require(Hospital[msg.sender] == true);
        _;
    }
    
    struct Doctor{
        bool Valid;
        uint index;
        mapping (uint=>address) Patient;
    }
    
    mapping (address => Doctor) doctors;
    
    function Add_Doctor(address _DoctorAddress) onlyHospital public {
        doctors[_DoctorAddress].Valid = true;
    }

    function Remove_Doctor(address _DoctorAddress) onlyHospital public {
        doctors[_DoctorAddress].Valid = false;
    }
    
    struct Patient{
        bool Valid;
        uint index;
        mapping (uint=>string) IPFS_Data_Record;
        address Doctor;
        mapping (address=>bool) Doctor_Valid;
        string IPFS_Treatment;
    }
    
    mapping (address => Patient) patients;
    
    function Add_Patient(address _PatientAddress) onlyHospital public {
        patients[_PatientAddress].Valid = true;
    }

    function Remove_Hospital(address _PatientAddress) onlyHospital public {
        patients[_PatientAddress].Valid = false;
    }
    
    function Authorize_Doctor_For_Patient(address _DoctorAddress,address _PatientAddress) onlyHospital public{
        patients[_PatientAddress].Doctor = _DoctorAddress;
        patients[_PatientAddress].Doctor_Valid[_DoctorAddress] = true;
        doctors[_DoctorAddress].Patient[doctors[_DoctorAddress].index + 1] = _PatientAddress;
        doctors[_DoctorAddress].index = doctors[_DoctorAddress].index +1;
    }
    
    function UnAuthorize_Doctor_For_Patient(address _DoctorAddress,address _PatientAddress) onlyHospital public{
        patients[_PatientAddress].Doctor_Valid[_DoctorAddress] = false;
    }
    
    function Check_Authorization_For_Patient(address _PatientAddress) view public returns (address) {
        return (patients[_PatientAddress].Doctor);
    }
    
    function Check_Authorization_For_Doctor(address _DoctorAddress) view public returns (uint) {
        return (doctors[_DoctorAddress].index);
    }
    
    function Get_Authorization_For_Doctor(address _DoctorAddress, uint _index) view public returns (address) {
        return (doctors[_DoctorAddress].Patient[_index]);
    }
    
    function Check_Doctor(address _DoctorAddress) view public returns (bool) {
        return (doctors[_DoctorAddress].Valid);
    }
    
    function Check_Patient(address _PatientAddress) view public returns (bool) {
        return (patients[_PatientAddress].Valid);
    }
    
    //******************************************************//
    //                                                      //
    //         Doctor Structure Smart Contract              //
    //                                                      //
    //******************************************************//

    event Requested(address _address);
    event Commented(address _address,string _IPFS);
    
    modifier onlyDoctor(address _PatientAddress) {
        require(patients[_PatientAddress].Doctor_Valid[msg.sender] == true);
        _;
    }
    
    function Request_WriteHR(address _PatientAddress) onlyDoctor(_PatientAddress) public{
        Requested(_PatientAddress);
    }
    
    function Write_Treatment(address _PatientAddress, string _IPFS) onlyDoctor(_PatientAddress) public{
        patients[_PatientAddress].IPFS_Treatment = _IPFS;
        Commented(_PatientAddress,_IPFS);
        
    }
    
    function Get_Treatment(address _PatientAddress) view public returns (string) {
        return (patients[_PatientAddress].IPFS_Treatment);
        
    }
    
    //******************************************************//
    //                                                      //
    //         Patient Structure Smart Contract             //
    //                                                      //
    //******************************************************//
    
    function Get_HRData(address _PatientAddress,uint _index) view public returns (string) {
        return (patients[_PatientAddress].IPFS_Data_Record[_index]);
    }
    
    function Get_HRIndex(address _PatientAddress) view public returns (uint) {
        return (patients[_PatientAddress].index);
    }
    
    //******************************************************//
    //                                                      //
    //        Smart Device Structure Smart Contract         //
    //                                                      //
    //******************************************************//
    
    modifier onlyPatient() {
        require(patients[msg.sender].Valid == true);
        _;
    }
    
    modifier onlyAuthorizeDoctor(address _DoctorAddress) {
        require(patients[msg.sender].Doctor_Valid[_DoctorAddress] == true);
        _;
    }
    
    event Alerted(address _DoctorAddress, address _PatientAddress);
     
    function Alert(address _DoctorAddress) onlyAuthorizeDoctor(_DoctorAddress) public{
        Alerted(_DoctorAddress,msg.sender);
    }
    
    function Write_HRData(string _IPFS) onlyPatient public{
        patients[msg.sender].IPFS_Data_Record[patients[msg.sender].index+1] = _IPFS;
        patients[msg.sender].index = patients[msg.sender].index+1;
    }
 
}
