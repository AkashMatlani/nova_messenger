import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:nova/models/admin_contact.dart';
import 'package:nova/models/thumbnail_response.dart';
import 'package:nova/models/trengo_data.dart';
import 'package:uuid/uuid.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/contact_data.dart';
import 'package:nova/models/broadcast_list.dart';
import 'package:nova/models/getgroupdata_response.dart';
import 'package:nova/models/get_list_response.dart';
import 'package:nova/models/get_user_response.dart';
import 'package:nova/models/group_chat_data.dart';
import 'package:nova/models/register_usermobile_response.dart';
import 'package:nova/models/updatebroadcast_listresponse.dart';
import 'package:nova/models/updateimageresponse.dart';
import 'package:nova/models/updateprofilename.dart';
import 'package:nova/models/updateprofilenameresponse.dart';
import 'package:nova/models/create_broadcast_list.dart';
import 'package:nova/models/create_broadcast_list_response.dart';
import 'package:nova/models/create_contacts.dart';
import 'package:nova/models/create_group.dart';
import 'package:nova/models/device_token.dart';
import 'package:nova/models/institution_response.dart';
import 'package:nova/models/publickey_token.dart';
import 'package:nova/models/register_student_mobile.dart';
import 'package:nova/models/register_user_response.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

class HttpService {
  String serverURL = dotenv.env['SERVER'];
  String authHeader = dotenv.env['AUTH_HEADER'];

  Future<RegisterUserResponse> registerUser() async {
    await HivePreferences.deleteAllPreferences();
    final preferences = await HivePreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse(serverURL + '/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader'
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        RegisterUserResponse responseData =
            RegisterUserResponse.fromJson(jsonDecode(response.body));
        preferences.setUserToken(responseData.token);
        userToken = responseData.token;
        return RegisterUserResponse.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<RegisterUserMobileResponse> registerUserStudentMobile(
      RegisterStudentMobile userData) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = await preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        RegisterUserMobileResponse responseData =
            RegisterUserMobileResponse.fromJson(jsonDecode(response.body));
        await preferences.setUserToken(responseData.token);
        userToken = responseData.token;
        await preferences.setUserId(responseData.uuid);
        userUuid = responseData.uuid;
        return responseData;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<List<Institution>> getInstitutions() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = await preferences.getUserToken();
    try {
      final response = await http.get(
        Uri.parse(serverURL + '/institutions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var list = jsonDecode(response.body) as List;
        List<Institution> institutionsList =
            list.map((i) => Institution.fromJson(i)).toList();
        institutionsList.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        return institutionsList;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> updateDeviceToken(DeviceToken deviceToken) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/users'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(deviceToken),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> updatePublicKey(PublicKeyToken publicKey) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/users'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(publicKey),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> createContacts(CreateContacts contacts) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    var jsonData = jsonEncode(contacts);
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/contacts'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonData,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<AdminContacts> getContactsAdmin(String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .get(Uri.parse(serverURL + '/list_admins/' + uuid), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$authHeader',
        'X-User': "Bearer " + userTokenApi
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        AdminContacts jsonParsed =
            AdminContacts.fromJson(jsonDecode(response.body));
        contactsAdminContactData = jsonParsed.users;
        return jsonParsed;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<List<ContactData>> getContacts() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response =
          await http.get(Uri.parse(serverURL + '/contacts'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$authHeader',
        'X-User': "Bearer " + userTokenApi
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        var list = jsonDecode(response.body) as List;
        List<ContactData> contactsList =
            list.map((i) => ContactData.fromJson(i)).toList();
        contactsGlobalData = contactsList;
        String contacts = jsonEncode(contactsList
            .map<Map<String, dynamic>>((chats) => ContactData.toMap(chats))
            .toList());
        preferences.setCurrentContacts(contacts);
        return contactsList;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<CreateBroadcastListResponse> createShowBroadcastList(
      CreateBroadcastList broadcastList) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .post(
            Uri.parse(serverURL + '/lists'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(broadcastList),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonParsed =
            CreateBroadcastListResponse.fromJson(jsonDecode(response.body));
        return jsonParsed;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<List<BroadcastList>> getBroadcastLists() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.get(
        Uri.parse(serverURL + '/lists/active'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var list = jsonDecode(response.body) as List;
        List<BroadcastList> broadcastList =
            list.map((i) => BroadcastList.fromJson(i)).toList();
        return broadcastList;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<List<GroupChatData>> getGroups() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.get(
        Uri.parse(serverURL + '/groups/active'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var list = jsonDecode(response.body) as List;
        List<GroupChatData> groupList =
            list.map((i) => GroupChatData.fromJson(i)).toList();
        return groupList;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<GetListDataResponse> getContactsListData(String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.get(
        Uri.parse(serverURL + '/lists/' + uuid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return GetListDataResponse.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<GetGroupDataResponse> getContactsGroupData(String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.get(
        Uri.parse(serverURL + '/groups/' + uuid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return GetGroupDataResponse.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<GroupChatData> createNewGroup(CreateGroup group) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .post(
            Uri.parse(serverURL + '/groups'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(group),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return GroupChatData.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> updateBroadcastList(
      CreateBroadcastList broadcastList, String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/lists/' + uuid),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(broadcastList),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> leaveBroadcastList(String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.put(
        Uri.parse(serverURL + '/lists/' + uuid + '/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> leaveGroup(String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http.put(
        Uri.parse(serverURL + '/groups/' + uuid + '/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> updateGroup(CreateGroup groupList, String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/groups/' + uuid),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(groupList),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<UpdateBroadcastImageResponse> updateBroadcastListAvatar(
      String filePath, String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': '$authHeader',
      'X-User': "Bearer " + userTokenApi
    };
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final request = http.MultipartRequest(
          'PUT', Uri.parse(serverURL + "/lists/" + uuid + "/avatar"))
        ..headers.addAll(headers)
        ..files.add(http.MultipartFile.fromBytes(
            'file', await File.fromUri(Uri(path: filePath)).readAsBytes(),
            filename: fileName + filePath.split("/").last));

      final response =
          await request.send().timeout(const Duration(seconds: 20));
      final responseStr = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("File Uploaded");
        UpdateBroadcastImageResponse updateResponse =
            UpdateBroadcastImageResponse.fromJson(jsonDecode(responseStr));
        return updateResponse;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> outgoingTrengoMessage(TrengoData trengoData) async {
    try {
      final client = http.Client();
      final body = json.encode({
        "contact": {
          "name": trengoData.contact.name,
          "identifier": trengoIdentifier,
          "email": trengoData.contact.uuid + "@nova.com"
        },
        "body": {"text": trengoData.body.text},
        "attachments": {
          "*": {"url": trengoData.attachments.url}
        },
        "channel": trengoData.channel
      });
      final request = http.Request(
        'POST',
        Uri.parse('https://app.trengo.com/api/v2/custom_channel_messages'),
      )
        ..headers.addAll({
          'accept': 'application/json',
          'content-type': 'application/json',
          'Authorization': "Bearer " + dotenv.env["trengoAPIToken"]
        })
        ..body = body;
      final response = await client.send(request);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<UpdateBroadcastImageResponse> updateGroupAvatar(
      String filePath, String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': '$authHeader',
      'X-User': "Bearer " + userTokenApi
    };
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final request = http.MultipartRequest(
          'PUT', Uri.parse(serverURL + "/groups/" + uuid + "/avatar"))
        ..headers.addAll(headers)
        ..files.add(http.MultipartFile.fromBytes(
            'file', await File.fromUri(Uri(path: filePath)).readAsBytes(),
            filename: fileName + filePath.split("/").last));

      final response =
          await request.send().timeout(const Duration(seconds: 20));
      final responseStr = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("File Uploaded");
        UpdateBroadcastImageResponse updateResponse =
            UpdateBroadcastImageResponse.fromJson(jsonDecode(responseStr));
        return updateResponse;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<UpdateProfileNameResponse> updateProfileName(
      UpdateProfileName profileName) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .put(
            Uri.parse(serverURL + '/users'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode(profileName),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final preferences = await HivePreferences.getInstance();
        preferences.setIsLoggedIn(true);
        UpdateProfileNameResponse profileResponse =
            UpdateProfileNameResponse.fromJson(jsonDecode(response.body));
        globalName = profileResponse.name;
        return profileResponse;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<UpdateImageResponse> updateProfileImage(String filePath) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': '$authHeader',
      'X-User': "Bearer " + userTokenApi
    };
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final request =
          http.MultipartRequest('PUT', Uri.parse(serverURL + '/users/avatar'))
            ..headers.addAll(headers)
            ..files.add(http.MultipartFile.fromBytes(
                'file', await File.fromUri(Uri(path: filePath)).readAsBytes(),
                filename: fileName + filePath.split("/").last));

      final response =
          await request.send().timeout(const Duration(seconds: 20));
      final responseStr = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("File Uploaded");
        UpdateImageResponse profileResponse =
            UpdateImageResponse.fromJson(jsonDecode(responseStr));
        globalImage = profileResponse.avatar;
        return profileResponse;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<GetUserResponse> getUser() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();

    try {
      final response = await http.get(
        Uri.parse(serverURL + '/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        GetUserResponse userResponse =
            GetUserResponse.fromJson(jsonDecode(response.body));
        globalName = userResponse.name;
        globalMobile = userResponse.mobile;
        userUuid = userResponse.uuid;
        return userResponse;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> deleteGroup(String listUuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();

    try {
      final response = await http.delete(
        Uri.parse(serverURL + '/groups/' + listUuid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException {
      return null;
    } catch (e) {
      globalAmplitudeService?.sendAmplitudeData('ApiError', e.toString(), true);
      return null;
    }
  }

  Future<dynamic> deleteBroadCastList(String listUuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();

    try {
      final response = await http.delete(
        Uri.parse(serverURL + '/lists/' + listUuid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> deleteContact(String contactUuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();

    try {
      final response = await http.delete(
        Uri.parse(serverURL + "/contacts/" + contactUuid + "/delete"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> deleteAccount() async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();

    try {
      final response = await http.delete(
        Uri.parse(serverURL + '/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$authHeader',
          'X-User': "Bearer " + userTokenApi
        },
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<ThumbnailResponse> uploadThumbnailFile(
      String thumbnail, String uuid) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$authHeader',
      'X-User': "Bearer " + userTokenApi
    };
    final request = http.MultipartRequest('PUT',
        Uri.parse(dotenv.env['SERVERUpload'] + "/api/messages/thumbnail"))
      ..fields['uuid'] = uuid
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile.fromBytes(
          'thumbnail', await File.fromUri(Uri(path: thumbnail)).readAsBytes(),
          filename: fileName + thumbnail.split("/").last));

    try {
      final response =
          await request.send().timeout(const Duration(seconds: 20));
      ThumbnailResponse thumbnailResponse = ThumbnailResponse.fromJson(
          jsonDecode(await response.stream.bytesToString()));
      return thumbnailResponse;
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> uploadFile(
      {String to,
      String filePath,
      String type,
      String from = "",
      String channelType = "general",
      int replyIndex,
      bool isReply = false,
      String replyUuid = "",
      bool isForwarded}) async {
    String path;
    switch (channelType) {
      case "group":
        path = "/api/messages/group";
        break;
      case "list":
        path = "/api/messages/list";
        break;
      default:
        path = "/api/messages";
    }

    var uuidClient = Uuid().v1();
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$authHeader',
      'X-User': "Bearer " + userTokenApi
    };
    final request = http.MultipartRequest(
        'POST', Uri.parse(dotenv.env['SERVERUpload'] + path))
      ..fields['to'] = to
      ..fields['from'] = from
      ..fields['content_type'] = type
      ..fields['content'] = ""
      ..fields['client_uuid'] = uuidClient
      ..fields['is_a_reply'] = isReply.toString()
      ..fields['replied_message_uuid'] = replyUuid
      ..fields['reply_index'] = replyIndex.toString()
      ..fields['is_forwarding'] = isForwarded != null ? isForwarded.toString() : "false"
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile.fromBytes(
          'file', await File.fromUri(Uri(path: filePath)).readAsBytes(),
          filename: fileName + filePath.split("/").last));

    try {
      final response =
          await request.send().timeout(const Duration(seconds: 20));
      return response;
    } on TimeoutException catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      globalAmplitudeService?.sendAmplitudeData(
          'ApiError', exception.toString(), true);
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }

  Future<dynamic> logTelemetryData(message) async {
    final preferences = await HivePreferences.getInstance();
    var userTokenApi = preferences.getUserToken();
    try {
      final response = await http
          .post(
            Uri.parse(serverURL + '/client/telemetry'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$authHeader',
              'X-User': "Bearer " + userTokenApi
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        return true;
      } else {
        return null;
      }
    } on TimeoutException catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    } catch (exception) {
      await Sentry.captureException(
        exception,
      );
      return null;
    }
  }
}
