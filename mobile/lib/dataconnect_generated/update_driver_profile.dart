part of 'generated.dart';

class UpdateDriverProfileVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  UpdateDriverProfileVariablesBuilder(this._dataConnect, );
  Deserializer<UpdateDriverProfileData> dataDeserializer = (dynamic json)  => UpdateDriverProfileData.fromJson(jsonDecode(json));
  
  Future<OperationResult<UpdateDriverProfileData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateDriverProfileData, void> ref() {
    
    return _dataConnect.mutation("UpdateDriverProfile", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class UpdateDriverProfileDriverProfileUpdate {
  final String id;
  UpdateDriverProfileDriverProfileUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateDriverProfileDriverProfileUpdate otherTyped = other as UpdateDriverProfileDriverProfileUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateDriverProfileDriverProfileUpdate({
    required this.id,
  });
}

@immutable
class UpdateDriverProfileData {
  final UpdateDriverProfileDriverProfileUpdate? driverProfile_update;
  UpdateDriverProfileData.fromJson(dynamic json):
  
  driverProfile_update = json['driverProfile_update'] == null ? null : UpdateDriverProfileDriverProfileUpdate.fromJson(json['driverProfile_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateDriverProfileData otherTyped = other as UpdateDriverProfileData;
    return driverProfile_update == otherTyped.driverProfile_update;
    
  }
  @override
  int get hashCode => driverProfile_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (driverProfile_update != null) {
      json['driverProfile_update'] = driverProfile_update!.toJson();
    }
    return json;
  }

  UpdateDriverProfileData({
    this.driverProfile_update,
  });
}

