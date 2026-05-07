class OfferModel {
  int? id;
  String? title;
  String? bannerImage;
  String? bannerImageFullUrl;
  String? startDate;
  String? endDate;
  String? termsConditions;
  String? offerType;
  double? offerValue;
  double? minOrderAmount;
  double? maxDiscountAmount;
  int? usageLimitPerUser;
  String? description;
  int? totalClicks;
  bool? status;
  double? calculatedDiscount;
  String? createdAt;
  String? updatedAt;

  OfferModel({
    this.id,
    this.title,
    this.bannerImage,
    this.bannerImageFullUrl,
    this.startDate,
    this.endDate,
    this.termsConditions,
    this.offerType,
    this.offerValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimitPerUser,
    this.description,
    this.totalClicks,
    this.status,
    this.calculatedDiscount,
    this.createdAt,
    this.updatedAt,
  });

  OfferModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    title = json['title'];
    bannerImage = json['banner_image'];
    bannerImageFullUrl = json['banner_image_full_url'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    termsConditions = json['terms_conditions'];
    offerType = json['offer_type'];
    offerValue = _toDouble(json['offer_value']);
    minOrderAmount = _toDouble(json['min_order_amount']);
    maxDiscountAmount = _toDouble(json['max_discount_amount']);
    usageLimitPerUser = int.tryParse(json['usage_limit_per_user'].toString());
    description = json['description'];
    totalClicks = int.tryParse(json['total_clicks'].toString());
    status = json['status'] == true || json['status'] == 1;
    calculatedDiscount = _toDouble(json['calculated_discount']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }
}
