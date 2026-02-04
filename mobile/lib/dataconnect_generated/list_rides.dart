part of 'generated.dart';

class ListRidesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListRidesVariablesBuilder(this._dataConnect, );
  Deserializer<ListRidesData> dataDeserializer = (dynamic json)  => ListRidesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListRidesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListRidesData, void> ref() {
    
    return _dataConnect.query("ListRides", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListRidesRides {
  final String id;
  final String status;
  final double? fare;
  ListRidesRides.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']),
  fare = json['fare'] == null ? null : nativeFromJson<double>(json['fare']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRidesRides otherTyped = other as ListRidesRides;
    return id == otherTyped.id && 
    status == otherTyped.status && 
    fare == otherTyped.fare;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode, fare.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    if (fare != null) {
      json['fare'] = nativeToJson<double?>(fare);
    }
    return json;
  }

  ListRidesRides({
    required this.id,
    required this.status,
    this.fare,
  });
}

@immutable
class ListRidesData {
  final List<ListRidesRides> rides;
  ListRidesData.fromJson(dynamic json):
  
  rides = (json['rides'] as List<dynamic>)
        .map((e) => ListRidesRides.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRidesData otherTyped = other as ListRidesData;
    return rides == otherTyped.rides;
    
  }
  @override
  int get hashCode => rides.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rides'] = rides.map((e) => e.toJson()).toList();
    return json;
  }

  ListRidesData({
    required this.rides,
  });
}

