import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../configuration/conf.dart';
import '../models/friend_request_list_response.dart';
import '../models/friend_request_user_response.dart';
import '../models/friend_response.dart';
import '../models/friends_list_response.dart';

class FriendsProvider with ChangeNotifier {
  bool isLoading = false;

  final HttpService http = HttpService();

  FriendRequestList? friendRequestListResponse;
  List<FriendRequestUser> friendRequestUsers = [];

  FriendListResponse? friendListResponse;
  List<FriendUserResponse> friendUsers = [];

  Future<void> getFriends() async {
    setLoading(true);
    try {
      final response = await http.getFriendListRequest('api/v1/friend-list/');
      if (response.statusCode == 200) {
        friendListResponse = FriendListResponse.fromJson(response.data);
        friendUsers = friendListResponse?.friendUser ?? [];
      } else {
        print('Status code is not 200.');
      }
    } catch (e) {
      print('Error fetching friends: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getFriendRequests() async {
    setLoading(true);
    try {
      final response = await http.getFriendRequestListRequest('api/v1/friend-request-list/');
      if (response.statusCode == 200) {
        friendRequestListResponse = FriendRequestList.fromJson(response.data);
        friendRequestUsers = friendRequestListResponse?.friendRequestUser ?? [];
      } else {
        print('Status code is not 200.');
      }
    } catch (e) {
      print('Error fetching friend requests: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> friendRequestAction(int requestID, String action) async {
    setLoading(true);
    try {
      final response = await http.friendRequestActionRequest(
        'api/v1/friend_request_action/', requestID, action);
      if (response.statusCode == 200) {
        friendRequestListResponse = FriendRequestList.fromJson(response.data);
        friendRequestUsers = friendRequestListResponse?.friendRequestUser ?? [];
      } else {
        print('Status code is not 200.');
      }
    } catch (e) {
      print('Error performing friend request action: $e');
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
