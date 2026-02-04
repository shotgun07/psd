library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'list_rides.dart';

part 'update_driver_profile.dart';

part 'get_ride_reviews.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  ListRidesVariablesBuilder listRides () {
    return ListRidesVariablesBuilder(dataConnect, );
  }
  
  
  UpdateDriverProfileVariablesBuilder updateDriverProfile () {
    return UpdateDriverProfileVariablesBuilder(dataConnect, );
  }
  
  
  GetRideReviewsVariablesBuilder getRideReviews ({required String rideId, }) {
    return GetRideReviewsVariablesBuilder(dataConnect, rideId: rideId,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'mobile',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
