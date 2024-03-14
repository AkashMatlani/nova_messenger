import 'package:hive/hive.dart';

class HivePreferences {

  static const _preferencesBox = '_preferencesBox';
  static const _userUuid = '_userUuid';
  static const _isLoggedIn = '_isLoggedIn';
  static const _userToken = '_userToken';
  static const _currentMainChats = '_currentMainChats';
  static const _currentContacts = '_currentContacts';
  static const _currentGroupChats = '_currentGroupChats';
  static const _currentListChats = '_currentListChats';
  static const _currentDirectChats = '_currentDirectChats';
  static const _isTermsAccepted = '_isTermsAccepted';
  static const _currentLastMessages = '_currentLastMessages';
  static const _currentLastPageData = '_currentLastPageData';
  static const _publicKey = '_publicKey';
  static const _privateKey = '_privateKey ';
  static const _queuedMessages = '_queuedMessages';
  static const _archivedMessages = '_archivedMessages';
  static const _inChatUuid = '_inChatUuid';
  static const _inChatType = 'inChatType';
  static const _trengoId = '_trengoId';

  final Box<dynamic> _box;
  HivePreferences._(this._box);

  static Future<HivePreferences> getInstance() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    return HivePreferences._(box);
  }

  static void deleteAllPreferences() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    for (dynamic key in box.keys) {
        box.delete(key);
    }
  }

  static void deleteLastSaved() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    for (dynamic key in box.keys) {
      if (key == "_currentLastPageData") {
        box.delete(key);
      }
    }
  }

  String getTrengoId() => _getValue(_trengoId);
  Future<void> setTrengoId(String trengoId) =>
      _setValue(_trengoId, trengoId);

  String getArchivedChats() => _getValue(_archivedMessages);
  Future<void> setArchivedChats(String archivedMessages) =>
      _setValue(_archivedMessages, archivedMessages);

  String getQueuedMessages() => _getValue(_queuedMessages);
  Future<void> setQueuedMessages(String queuedMessages) =>
      _setValue(_queuedMessages, queuedMessages);

  String getInChatUuid() => _getValue(_inChatUuid);
  Future<void> setInChatUuid(String inChatUuid) =>
      _setValue(_inChatUuid, inChatUuid);

  String getInChatType() => _getValue(_inChatType);
  Future<void> setInChatType(String inChatType) =>
      _setValue(_inChatType , inChatType);

  String getPublicKey() => _getValue(_publicKey);
  Future<void> setPublicKey(String publicKey) =>
      _setValue(_publicKey, publicKey);

  String getPrivateKey() => _getValue(_privateKey);
  Future<void> setPrivateKey(String privateKey) =>
      _setValue(_privateKey, privateKey);

  String getLastPageData() => _getValue(_currentLastPageData);
  Future<void> setLastPageData(String lastPageData) =>
      _setValue(_currentLastPageData, lastPageData);

  String getCurrentLastMessages() => _getValue(_currentLastMessages);
  Future<void> setCurrentLastMessages(String lastMessages) =>
      _setValue(_currentLastMessages, lastMessages);

  String getCurrentChats() => _getValue(_currentMainChats);
  Future<void> setCurrentChats(String currentChats) =>
      _setValue(_currentMainChats, currentChats);

  String getGroupChats() => _getValue(_currentGroupChats);
  Future<void> setGroupChats(String currentGroupChats) =>
      _setValue(_currentGroupChats, currentGroupChats);

  String getListChats() => _getValue(_currentListChats);
  Future<void> setListChats(String currentListChats) =>
      _setValue(_currentListChats, currentListChats);

  String getDirectChats() => _getValue(_currentDirectChats);
  Future<void> setDirectChats(String currentDirectChats) =>
      _setValue(_currentDirectChats, currentDirectChats);

  String getCurrentContacts() => _getValue(_currentContacts);
  Future<void> setCurrentContacts(String currentContacts) =>
      _setValue(_currentContacts, currentContacts);

  String getUserId() => _getValue(_userUuid);
  Future<void> setUserId(String userId) =>
      _setValue(_userUuid, userId);

  bool getIsLoggedIn() => _getValue(_isLoggedIn);
  Future<void> setIsLoggedIn(bool isLoggedIn) =>
      _setValue(_isLoggedIn, isLoggedIn);

  String getUserToken() => _getValue(_userToken);
  Future<void> setUserToken(String userToken) =>
      _setValue(_userToken, userToken);

  bool getTermsAcceptance() => _getValue(_isTermsAccepted);
  Future<void> setTermsAcceptance(bool termsAccepted) =>
      _setValue(_isTermsAccepted, termsAccepted);

  _getValue<T>(key, {defaultValue}) =>
      _box.get(key, defaultValue: defaultValue);

  Future<void> _setValue<T>(key,value) => _box.put(key, value);
}
