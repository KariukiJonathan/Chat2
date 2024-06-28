import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../configuration/authorization_storage.dart'; // Updated import

class NotificationController {
  static final NotificationController _singleton =
      NotificationController._internal();

  StreamController<String> streamController =
      StreamController.broadcast(sync: true);

  IOWebSocketChannel? channel;
  late Stream<dynamic> channelStream;

  factory NotificationController() {
    return _singleton;
  }

  NotificationController._internal() {
    initWebSocketConnection();
  }

  Future<void> initWebSocketConnection() async {
    var storedUserInfo = await StorageServices().getUserInfoStorage();
    String userID = storedUserInfo['user_id'] ?? '';

    print("Connecting...");

    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000//chat/$userID/'), // Updated to ws://
        pingInterval: const Duration(seconds: 10),
      );

      channelStream = channel!.stream.asBroadcastStream();

      print("Socket connection initialized");

      channel?.sink.done.then((dynamic _) => _onDisconnected());
      _listenToMessages();
    } on Exception catch (e) {
      print("Connection error: $e");
      await Future.delayed(const Duration(seconds: 5));
      initWebSocketConnection();
    }
  }

  void _listenToMessages() {
    channelStream.listen(
      (data) {
        Map message = json.decode(data);
        streamController.add(message['message']);
      },
      onError: (error) {
        print('WebSocket error: $error');
        _onDisconnected();
      },
      onDone: () {
        print('WebSocket closed');
        _onDisconnected();
      },
    );
  }

  void sendMessage(Map<String, dynamic> messageObject, Function(Map) messageListener) {
    try {
      channel?.sink.add(json.encode(messageObject));
      channelStream.listen((data) {
        Map message = json.decode(data);
        messageListener(message);
      });
    } on Exception catch (e) {
      print("Send message error: $e");
    }
  }

  void _onDisconnected() {
    print("Disconnected from WebSocket. Reconnecting...");
    initWebSocketConnection();
  }
}
