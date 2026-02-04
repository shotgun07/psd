part of 'generated.dart';

class GetRideReviewsVariablesBuilder {
  String rideId;

  final FirebaseDataConnect _dataConnect;
  GetRideReviewsVariablesBuilder(this._dataConnect, {required  this.rideId,});
  Deserializer<GetRideReviewsData> dataDeserializer = (dynamic json)  => GetRideReviewsData.fromJson(jsonDecode(json));
  Serializer<GetRideReviewsVariables> varsSerializer = (GetRideReviewsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetRideReviewsData, GetRideReviewsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetRideReviewsData, GetRideReviewsVariables> ref() {
    GetRideReviewsVariables vars= GetRideReviewsVariables(rideId: rideId,);
    return _dataConnect.query("GetRideReviews", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetRideReviewsRide {
  final List<GetRideReviewsRideReviewsOnRide> reviews_on_ride;
  GetRideReviewsRide.fromJson(dynamic json):
  
  reviews_on_ride = (json['reviews_on_ride'] as List<dynamic>)
        .map((e) => GetRideReviewsRideReviewsOnRide.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRideReviewsRide otherTyped = other as GetRideReviewsRide;
    return reviews_on_ride == otherTyped.reviews_on_ride;
    
  }
  @override
  int get hashCode => reviews_on_ride.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reviews_on_ride'] = reviews_on_ride.map((e) => e.toJson()).toList();
    return json;
  }

  GetRideReviewsRide({
    required this.reviews_on_ride,
  });
}

@immutable
class GetRideReviewsRideReviewsOnRide {
  final String id;
  final String? comment;
  final int rating;
  final GetRideReviewsRideReviewsOnRideReviewer reviewer;
  GetRideReviewsRideReviewsOnRide.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  comment = json['comment'] == null ? null : nativeFromJson<String>(json['comment']),
  rating = nativeFromJson<int>(json['rating']),
  reviewer = GetRideReviewsRideReviewsOnRideReviewer.fromJson(json['reviewer']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRideReviewsRideReviewsOnRide otherTyped = other as GetRideReviewsRideReviewsOnRide;
    return id == otherTyped.id && 
    comment == otherTyped.comment && 
    rating == otherTyped.rating && 
    reviewer == otherTyped.reviewer;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, comment.hashCode, rating.hashCode, reviewer.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if (comment != null) {
      json['comment'] = nativeToJson<String?>(comment);
    }
    json['rating'] = nativeToJson<int>(rating);
    json['reviewer'] = reviewer.toJson();
    return json;
  }

  GetRideReviewsRideReviewsOnRide({
    required this.id,
    this.comment,
    required this.rating,
    required this.reviewer,
  });
}

@immutable
class GetRideReviewsRideReviewsOnRideReviewer {
  final String id;
  final String username;
  GetRideReviewsRideReviewsOnRideReviewer.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRideReviewsRideReviewsOnRideReviewer otherTyped = other as GetRideReviewsRideReviewsOnRideReviewer;
    return id == otherTyped.id && 
    username == otherTyped.username;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, username.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  GetRideReviewsRideReviewsOnRideReviewer({
    required this.id,
    required this.username,
  });
}

@immutable
class GetRideReviewsData {
  final GetRideReviewsRide? ride;
  GetRideReviewsData.fromJson(dynamic json):
  
  ride = json['ride'] == null ? null : GetRideReviewsRide.fromJson(json['ride']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRideReviewsData otherTyped = other as GetRideReviewsData;
    return ride == otherTyped.ride;
    
  }
  @override
  int get hashCode => ride.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (ride != null) {
      json['ride'] = ride!.toJson();
    }
    return json;
  }

  GetRideReviewsData({
    this.ride,
  });
}

@immutable
class GetRideReviewsVariables {
  final String rideId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetRideReviewsVariables.fromJson(Map<String, dynamic> json):
  
  rideId = nativeFromJson<String>(json['rideId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRideReviewsVariables otherTyped = other as GetRideReviewsVariables;
    return rideId == otherTyped.rideId;
    
  }
  @override
  int get hashCode => rideId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rideId'] = nativeToJson<String>(rideId);
    return json;
  }

  GetRideReviewsVariables({
    required this.rideId,
  });
}

