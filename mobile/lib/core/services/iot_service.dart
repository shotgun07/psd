import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IoTService {
  late MqttServerClient client;

  IoTService() {
    client = MqttServerClient('broker.hivemq.com', 'flutter_client');
    client.logging(on: true);
  }

  Future<void> connect() async {
    await client.connect();
  }

  void subscribeToTopic(String topic, Function(String) onMessage) {
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      onMessage(pt);
    });
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
  }
}