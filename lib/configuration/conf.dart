import 'package:dio/dio.dart';
import '../configuration/authorization_storage.dart'; // Updated import

class HttpService {
  final Dio _dio = Dio();
  final StorageServices storage = StorageServices();

  String userToken = 'none';

  final baseUrl = 'http://127.0.0.1:8000/';

  Future<Response> registerUser(String endPoint, userData) async {
    var header = {
      'content-type': 'application/json',
    };

    Response response = Response(
      requestOptions: RequestOptions(path: ''), // Provide a default empty RequestOptions
    );

    String username = userData['username'];
    String emailId = userData['email_id'];
    String name = userData['name'];
    String password = userData['password'];
    String confirmPassword = userData['confirm_password'];

    var data = {
      'username': username,
      'email_id': emailId,
      'name': name,
      'password': password,
      'confirm_password': confirmPassword,
    };

    try {
      response = await _dio.post(
        baseUrl + endPoint,
        data: data,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      var responseMessage = e.response?.data;
      try {
        if (responseMessage is Map && responseMessage['message'] is Map) {
          responseMessage = responseMessage['message']['non_field_errors'][0];
        } else if (responseMessage is Map && responseMessage['message'] is List) {
          responseMessage = responseMessage['message'][0];
        } else {
          responseMessage = 'An unexpected error occurred';
        }
      } on Exception catch (_) {
        responseMessage = 'An unexpected error occurred';
      }

      throw Exception(responseMessage);
    }
    return response;
  }

  Future<Response> loginUser(String endPoint, userData) async {
    var header = {
      'content-type': 'application/json',
    };

    Response response = Response(
      requestOptions: RequestOptions(path: ''), // Provide a default empty RequestOptions
    );

    String username = userData['username'];
    String password = userData['password'];

    var data = {
      'username': username,
      'password': password,
    };

    try {
      print('trying');
      response = await _dio.post(
        baseUrl + endPoint,
        data: data,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      print("error");
      var responseMessage = e.response?.data;
      // Handle different possible response structures
      if (responseMessage is Map) {
        if (responseMessage.containsKey('message')) {
          if (responseMessage['message'] is Map && responseMessage['message'].containsKey('message')) {
            if (responseMessage['message']['message'] is List && responseMessage['message']['message'].isNotEmpty) {
              throw Exception(responseMessage['message']['message'][0]);
            } else if (responseMessage['message']['message'] is String) {
              throw Exception(responseMessage['message']['message']);
            }
          } else if (responseMessage['message'] is List && responseMessage['message'].isNotEmpty) {
            throw Exception(responseMessage['message'][0]);
          } else if (responseMessage['message'] is String) {
            throw Exception(responseMessage['message']);
          }
        } else {
          throw Exception('Unexpected response structure: ${responseMessage.toString()}');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    }
    return response;
  }

  Future<Response> logoutUser(String endPoint) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get(baseUrl + endPoint,
          options: Options(
            headers: header,
          ));
    } on DioError catch (e) {
      var responseMessage = e.response;
      throw Exception(responseMessage);
    }
    return response;
  }

  Future<Response> getNearbyUserProfileRequest(String userUid) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get('${baseUrl}api/v1/user-profile-info/$userUid/',
          options: Options(headers: header));
    } on DioError catch (e) {
      throw Exception(e.response);
    }
    return response;
  }

  Future<Response> getFriendRequestListRequest(String endPoint) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get(
        baseUrl + endPoint,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response> getFriendListRequest(String endPoint) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get(
        baseUrl + endPoint,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response> getSearchedUsersRequest(String endPoint) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get(
        baseUrl + endPoint,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response> getChatRoomsResponse(String endPoint) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    Response response;

    try {
      response = await _dio.get(
        baseUrl + endPoint,
        options: Options(headers: header),
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response> sendFriendRequest(String endPoint, String userUid) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    var data = {
      'sender_user': 'eecd66e7-4874-4b96-bde0-7dd37d0b83b3',
      'receiver_user': userUid
    };
    Response response;

    try {
      response = await _dio.post(baseUrl + endPoint,
          options: Options(headers: header), data: data);
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response> friendRequestActionRequest(
      String endPoint, int requestID, String action) async {
    var storedUserInfo = await storage.getUserInfoStorage();
    userToken = storedUserInfo['token'] ?? '';

    late var header = {
      'content-type': 'application/json',
      'Authorization': 'Token $userToken',
    };

    var data = {'request_id': requestID, 'request_option': action};

    Response response;

    try {
      response = await _dio.post(baseUrl + endPoint,
          options: Options(headers: header), data: data);
    } on DioError catch (e) {
      throw Exception(e.message);
    }

    return response;
  }
}
