import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';

class UserInfoModel {
  int? id;
  String? fName;
  String? lName;
  String? email;
  String? imageFullUrl;
  String? phone;
  String? password;
  int? orderCount;
  int? memberSinceDays;
  double? walletBalance;
  int? loyaltyPoint;
  String? refCode;
  int? socialId;
  User? userInfo;
  String? createdAt;
  String? validity;
  bool? isValidForDiscount;
  double? discountAmount;
  String? discountAmountType;
  bool? isPhoneVerified;
  bool? isEmailVerified;
  int? zoneId;
  int? areaId;
  int? buildingId;
  int? companyId;
  String? zoneName;
  String? areaName;
  String? buildingName;
  String? companyName;

  UserInfoModel({
    this.id,
    this.fName,
    this.lName,
    this.email,
    this.imageFullUrl,
    this.phone,
    this.password,
    this.orderCount,
    this.memberSinceDays,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.socialId,
    this.userInfo,
    this.createdAt,
    this.validity,
    this.isValidForDiscount,
    this.discountAmount,
    this.discountAmountType,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.zoneId,
    this.areaId,
    this.buildingId,
    this.companyId,
    this.zoneName,
    this.areaName,
    this.buildingName,
    this.companyName,
  });

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    phone = json['phone'];
    password = json['password'];
    orderCount = json['order_count'];
    memberSinceDays = json['member_since_days'];
    walletBalance = json['wallet_balance'].toDouble();
    loyaltyPoint = json['loyalty_point'];
    refCode = json['ref_code'];
    socialId = json['social_id'];
    userInfo =
        json['userinfo'] != null ? User.fromJson(json['userinfo']) : null;
    createdAt = json['created_at'];
    validity = json['validity'];
    isValidForDiscount = json['is_valid_for_discount'] ?? false;
    discountAmount = json['discount_amount']?.toDouble();
    discountAmountType = json['discount_amount_type'];
    isPhoneVerified = json['is_phone_verified'] == 1;
    isEmailVerified = json['is_email_verified'] == 1;
    zoneId = json['zone_id'] is int
        ? json['zone_id']
        : int.tryParse('${json['zone_id']}');
    areaId = json['area_id'] is int
        ? json['area_id']
        : int.tryParse('${json['area_id']}');
    buildingId = json['building_id'] is int
        ? json['building_id']
        : int.tryParse('${json['building_id']}');
    companyId = json['company_id'] is int
        ? json['company_id']
        : int.tryParse('${json['company_id']}');
    zoneName =
        json['zone_name']?.toString() ?? json['zone']?['name']?.toString();
    areaName =
        json['area_name']?.toString() ?? json['area']?['name']?.toString();
    buildingName = json['building_name']?.toString() ??
        json['building']?['name']?.toString();
    companyName = json['company_name']?.toString() ??
        json['company']?['name']?.toString() ??
        json['organization']?['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['phone'] = phone;
    data['password'] = password;
    data['order_count'] = orderCount;
    data['member_since_days'] = memberSinceDays;
    data['wallet_balance'] = walletBalance;
    data['loyalty_point'] = loyaltyPoint;
    data['ref_code'] = refCode;
    if (userInfo != null) {
      data['userinfo'] = userInfo!.toJson();
    }
    data['created_at'] = createdAt;
    data['validity'] = validity;
    data['is_valid_for_discount'] = isValidForDiscount;
    data['discount_amount'] = discountAmount;
    data['discount_amount_type'] = discountAmountType;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['zone_id'] = zoneId;
    data['area_id'] = areaId;
    data['building_id'] = buildingId;
    data['company_id'] = companyId;
    data['zone_name'] = zoneName;
    data['area_name'] = areaName;
    data['building_name'] = buildingName;
    data['company_name'] = companyName;
    return data;
  }
}
