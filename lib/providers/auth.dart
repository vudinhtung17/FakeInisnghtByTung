import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/io_client.dart';
import 'package:rest_api_login/utils/api.dart';
import 'package:http/http.dart' ;//as http;
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_api_login/utils/globals.dart' as globals;
import 'package:device_info_plus/device_info_plus.dart';

class Auth with ChangeNotifier {
  var MainUrl = Api.authUrl;
  var AuthKey = Api.authKey;

  String _token;
  String _userId;
  String _userEmail;
  String _dataAction;
  String _fullName;
  String _statusCheckin;
  String _statusCheckout;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    /*if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }*/
    return _token;
  }

  String get userId {
    return _userId;
  }

  String get userEmail {
    return _userEmail;
  }

  String get fullName {
    return _fullName;
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  Future<void> logout() async {
    _token = null;
    _userEmail = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    //pref.clear();
    pref.remove('userData');
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timetoExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoExpiry), logout);
  }

  Future<bool> tryautoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(pref.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _userEmail = extractedUserData['userEmail'];
    _fullName = extractedUserData['fullName'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autologout();

    return true;
  }

  Future<void> doAuthentication(
      String username, String password, String endpoint) async {
    try {
      final url = '${MainUrl}/${endpoint}';
      print(url);
      String deviceModel ='Redmi Note 11 Pro 5G';
      String deviceOSVersion = '11';
      String lastIP = random(15, 200).toString();
      String deviceIP = "10.15.191." +lastIP;
      print(deviceIP);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceOSVersion = androidInfo.version.release;
        print('Running on ${androidInfo.model}, osVersion ${androidInfo.version.release}');
      }
      if (Platform.isIOS){
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        deviceOSVersion = iosInfo.systemVersion;
        print('Running on ${iosInfo.utsname.machine}, osVersion ${iosInfo.systemVersion}');  // e.g. "iPod7,1"
      }

      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);

      final responce = await http.post(url,
          body: {
            'username' : username,
            'password' : password,
            'osVersion' : deviceOSVersion,
            'deviceModel' : deviceModel,
            'buildNumber' : "10947",
            'version' : "1.83",
            'deviceIP': deviceIP
          });

      final responceData = jsonDecode(responce.body);
      print(responceData);
      if (responceData['resultCode'] != 1) {
        throw HttpException(responceData['message']);
      }
      _token = responceData['data']['token'];
      _userId = responceData['data']['userId'];
      _userEmail = responceData['data']['username'];
      _fullName = responceData['data']['fullName'];

      globals.fullName = _fullName;
      globals.empID = responceData['data']['employeeId'];
      globals.isLoggedIn= true;

      //_autologout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userEmail': _userEmail,
        'fullName':_fullName/*,
        'expiryDate': _expiryDate.toIso8601String(),*/
      });

      prefs.setString('userData', userData);

      print('check' + userData.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> doAction(String endpoint, int typeAction) async {
    try {
      final url = '${MainUrl}/${endpoint}';
      String userDataStr;
      try{
          final prefs = await SharedPreferences.getInstance();
          userDataStr = prefs.getString('userData');
          if (userDataStr.isEmpty){
            throw Exception("Cần đăng nhập trước khi thực hiện checkin/checkout");
          }
      }
      catch (e){
        throw e;
      }
      final userData = json.decode(userDataStr);

      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);

      final responce = await http.post(url,
      body: json.encode({
        'deviceId':"",
        'reason':"",
        'ipGateway':"10.15.191.1",
        'type':0}),
      headers: { 'Content-type': 'application/json',
                 "Authorization": "Bearer "+userData['token']});

      final responceData = json.decode(responce.body);
      print(responceData);
      if (responceData['resultCode'] == -1) {
        throw HttpException(responceData['message']);
      }
      _dataAction = responceData['message'] ;//responceData['data']['checkinTime'];
      print(_dataAction);
      globals.messageAction = _dataAction;
    } catch (e) {
      throw e;
    }
  }

  Future<void> doActionOnsite(String endpoint, int typeAction) async {
    try {
      final url = '${MainUrl}/${endpoint}';
      String userDataStr;
      try{
        final prefs = await SharedPreferences.getInstance();
        userDataStr = prefs.getString('userData');
        if (userDataStr.isEmpty){
          throw Exception("Cần đăng nhập trước khi thực hiện checkin/checkout");
        }
      }
      catch (e){
        throw e;
      }
      final userData = json.decode(userDataStr);

      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);

      final responce = await http.post(url,
          body: json.encode({
            'deviceId':"",
            'image' : "",
            'type' : typeAction,
            'lat' : 21.028499410121334,
            'long' : 105.85691040729077,
            'address' : "41A P. Lý Thái Tổ, Lý Thái Tổ, Hoàn Kiếm, Hà Nội, Việt Nam",
            'reason':""
          }),
          headers: { 'Content-type': 'application/json',
            "Authorization": "Bearer "+userData['token']});

      final responceData = json.decode(responce.body);
      print(responceData);
      if (responceData['resultCode'] == -1) {
        throw HttpException(responceData['message']);
      }
      _dataAction = responceData['message'] ;//responceData['data']['checkinTime'];
      print(_dataAction);
      globals.messageAction = _dataAction;
    } catch (e) {
      throw e;
    }
  }

  Future<void> getDayStatus(String endpoint) async {
    try {
      final url = '${MainUrl}/${endpoint}';
      String userDataStr;
      final prefs = await SharedPreferences.getInstance();
      userDataStr = prefs.getString('userData');
      if (!userDataStr.isEmpty){
        final userData = json.decode(userDataStr);

        final ioc = new HttpClient();
        ioc.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        final http = new IOClient(ioc);

        final responce = await http.get(url,
            headers: { 'Content-type': 'application/json',
              "Authorization": "Bearer "+userData['token']});

        final responceData = json.decode(responce.body);
        print(responceData);
        if (responceData['resultCode'] == 1) {
          _statusCheckin = responceData['data']['checkinTime'];
          _statusCheckout = responceData['data']['checkoutTime'];
          print('statusCheckin: '+ _statusCheckin);
          print('statusCheckout: '+ _statusCheckout);
          if (_statusCheckin.isNotEmpty){
            globals.statusCheckin = "Bạn đã checkin thành công lúc: "+_statusCheckin;
            print(globals.statusCheckin);
          }
          if (_statusCheckout.isNotEmpty){
            globals.statusCheckout = "Bạn đã checkout thành công lúc: " + _statusCheckout;
            print(globals.statusCheckout);
          }
        }
      }
    } catch (e) {
    }
  }

  Future<void> login(String username, String password) {
    return doAuthentication(username, password, 'login');
  }

  Future<void> signUp(String username, String password) {
    return doAuthentication(username, password, 'signUp');
  }

  Future<void> checkIn(int typeAction) {
    if (typeAction ==0) {
      return doAction('checkin_all', typeAction);
    }
    else {
      return doActionOnsite('checkin_all', typeAction);
    }
  }

  Future<void> checkOut(int typeAction) {
    if (typeAction ==0) {
      return doAction('checkout_all', typeAction);
    }
    else{
      return doActionOnsite('checkout_all', typeAction);
    }
  }
}
