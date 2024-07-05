import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:international_chat_app/configuration/conf.dart';
import '../configuration/websocket_model.dart';
import '../models/chat_messages_response.dart';
import '../providers/user_authorization_provider.dart';
import 'package:international_chat_app/models/chat_messages_list_response.dart';

class ChatMessage {
  String? content;
  int? room;
  String? user;
  DateTime? createdAt;

  String? message;
  String? toUser;
  ChatMessage({this.message, this.toUser});
}

class Messages extends StatefulWidget {
  final String? userUid;
  final String? name;
  final int? roomID;

  const Messages({Key? key, this.userUid, this.name, this.roomID}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final NotificationController notificationController = NotificationController();
  TextEditingController sendMessageController = TextEditingController();
  bool isLoading = false;
  late Future<List<ChatMessagesListResponse>> futureChatMessages;
  List<ChatMessagesListResponse> chatMessagesListResponse = [];
  HttpService httpService = HttpService();

  @override
  void initState() {
    super.initState();
    futureChatMessages = getRoomMessages();
  }

  Future<List<ChatMessagesListResponse>> getRoomMessages() async {
    setState(() => isLoading = true);
    try {
      Response response = widget.roomID == null
          ? await httpService.getChatRoomsResponse('api/v1/room-messages/${widget.userUid}/')
          : await httpService.getChatRoomsResponse('api/v1/room-messages/${widget.userUid}/${widget.roomID}/');

      ChatMessagesResponse chatMessagesResponse = ChatMessagesResponse.fromJson(response.data);
      chatMessagesListResponse = chatMessagesResponse.chatMessagesListResponse;
      return chatMessagesListResponse;
    } catch (e) {
      throw Exception('Failed to load chat messages: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void messageListener(Map message) {
    Map messageData = message;
    if (mounted) {
      setState(() {
        chatMessagesListResponse.add(
          ChatMessagesListResponse(
            messageId: messageData['message_id'],
            roomId: messageData['message_room'],
            messageContent: messageData['message_content'],
            fromMessageUser: messageData['message_user'],
            messageTime: messageData['message_created_at'],
          ),
        );
      });
    }
    print(messageData);
  }

  @override
  void dispose() {
    sendMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pinimg.com/originals/e0/41/fa/e041fa5038a055ff62d51fdbcc15dbc9.jpg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                widget.name ?? '',
                style: const TextStyle(color: Colors.black87, fontSize: 18.0),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Block')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: FutureBuilder<List<ChatMessagesListResponse>>(
        future: futureChatMessages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages found'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chatMessagesListResponse.length,
                    itemBuilder: (context, index) {
                      final chatMessage1 = chatMessagesListResponse[index];
                      bool isOwnMessage = chatMessage1.fromMessageUser == widget.userUid;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        child: Align(
                          alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isOwnMessage ? Colors.grey.shade400 : Colors.grey.shade300,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              chatMessage1.messageContent ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Material(
                  elevation: 12.0,
                  child: Container(
                    color: Colors.grey[100],
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 4.0, 15.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: sendMessageController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[300],
                                hintText: 'Message',
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              var messageText = sendMessageController.text;
                              if (messageText.isEmpty) return;

                              var messageObject = {
                                'message': messageText,
                                'to_user': widget.userUid,
                              };

                              sendMessageController.clear();

                              // Call sendMessage without await
                              notificationController.sendMessage(messageObject);
                            },
                            icon: const Icon(Iconsax.send_14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
