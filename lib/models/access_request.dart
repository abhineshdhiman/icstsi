class AccessRequest {
  final String? id;
  final String companyName;
  final String city;
  final String stateProvince;
  final String country;
  final String zipCode;
  final String businessAddress;
  final String taxIdNumber;
  final String email;
  final String terminal;
  final String userType;
  final String? copyFrom;
  final String repName;
  final String repEmail;
  final String? repPosition;
  final String? remarks;
  final String status;
  final List<String> documentPaths;

  const AccessRequest({
    this.id,
    required this.companyName,
    required this.city,
    required this.stateProvince,
    required this.country,
    required this.zipCode,
    required this.businessAddress,
    required this.taxIdNumber,
    required this.email,
    required this.terminal,
    required this.userType,
    this.copyFrom,
    required this.repName,
    required this.repEmail,
    this.repPosition,
    this.remarks,
    this.status = 'pending',
    this.documentPaths = const [],
  });

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'city': city,
        'state_province': stateProvince,
        'country': country,
        'zip_code': zipCode,
        'business_address': businessAddress,
        'tax_id_number': taxIdNumber,
        'email': email,
        'terminal': terminal,
        'user_type': userType,
        if (copyFrom != null) 'copy_from': copyFrom,
        'rep_name': repName,
        'rep_email': repEmail,
        if (repPosition != null) 'rep_position': repPosition,
        if (remarks != null) 'remarks': remarks,
        'status': status,
      };
}
