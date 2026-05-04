class UpdateUserModel {
  String? name;
  String? email;
  String? phone;
  String? otp;
  String? buttonType;
  String? sessionInfo;
  String? verificationOn;
  String? verificationMedium;
  int? zoneId;
  int? areaId;
  int? buildingId;
  int? companyId;

  UpdateUserModel({
    this.name,
    this.email,
    this.phone,
    this.otp,
    this.buttonType,
    this.sessionInfo,
    this.verificationOn,
    this.verificationMedium,
    this.zoneId,
    this.areaId,
    this.buildingId,
    this.companyId,
  });

  UpdateUserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    otp = json['otp'];
    buttonType = json['button_type'];
    sessionInfo = json['session_info'];
    verificationOn = json['verification_on'];
    verificationMedium = json['verification_medium'];
    zoneId = json['zone_id'];
    areaId = json['area_id'];
    buildingId = json['building_id'];
    companyId = json['organization_id'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['name'] = name ?? '';
    data['email'] = email ?? '';
    data['phone'] = phone ?? '';
    data['otp'] = otp ?? '';
    data['button_type'] = buttonType ?? '';
    if (zoneId != null) {
      data['zone_id'] = zoneId.toString();
    }
    if (areaId != null) {
      data['area_id'] = areaId.toString();
    }
    if (buildingId != null) {
      data['building_id'] = buildingId.toString();
    }
    if (companyId != null) {
      data['organization_id'] = companyId.toString();
    }
    if (sessionInfo != null) {
      data['session_info'] = sessionInfo ?? '';
    }
    if (verificationOn != null) {
      data['verification_on'] = verificationOn ?? '';
    }
    if (verificationMedium != null) {
      data['verification_medium'] = verificationMedium ?? '';
    }
    return data;
  }
}
