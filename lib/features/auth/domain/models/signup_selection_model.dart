class SignUpSelectionModel {
  int? id;
  String? name;

  SignUpSelectionModel({this.id, this.name});

  SignUpSelectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse('${json['id']}');
    name = json['name']?.toString() ??
        json['title']?.toString() ??
        json['area_name']?.toString() ??
        json['building_name']?.toString() ??
        json['organization_name']?.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is SignUpSelectionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
