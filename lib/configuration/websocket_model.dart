import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import '../configuration/authorization_storage.dart'; // Updated import

class NotificationController {
  static final NotificationController _singleton = NotificationController._internal();

  StreamController<String> streamController = StreamController.broadcast(sync: true);

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

    print("Attempting to connect to WebSocket with userID: $userID");

    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000/chat/$userID/'),
        pingInterval: const Duration(seconds: 10),
      );

      channelStream = channel!.stream.asBroadcastStream();

      print("WebSocket connection established successfully");

      channel?.sink.done.then((dynamic _) {
        print("WebSocket connection closed");
        _onDisconnected();
      });

      _listenToMessages();
    } on SocketException catch (e) {
      print("SocketException: $e");
      print("This might be due to the server being unreachable or a network issue.");
    } on WebSocketException catch (e) {
      print("WebSocketException: $e");
      print("This might be due to the WebSocket handshake failing.");
    } on Exception catch (e) {
      print("Other exception: $e");
    }

    // Wait before attempting to reconnect
    await Future.delayed(const Duration(seconds: 5));
    initWebSocketConnection();
}

  void _listenToMessages() {
    print('oya');
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

  void sendMessage(Map<String, dynamic> messageObject) {
  try {
    print("Sending message: ${json.encode(messageObject)}");
    channel?.sink.add(json.encode(messageObject));
  } on Exception catch (e) {
    print("Send message error: $e");
  }
}

  void _onDisconnected() {
    print("Disconnected from WebSocket. Reconnecting...");
    initWebSocketConnection();
  }
}
