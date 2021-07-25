import 'package:eshop/exception/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier{
  String _token = "";
  DateTime _expiryDate = DateTime.now();
  String _userId = "";
  var _authTimer;
  bool get isAuth{
    //if token != null means we are authenticated.
    return token != "";
  }

  String get token{

    if(_expiryDate != DateTime.now() && _expiryDate.isAfter(DateTime.now()) && _token!=""){
      return _token;
    }
    return "";
  }

  dynamic get userId{
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async{

    final url = "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBAP9zr8UZXLvmDrSWJg8ZKeLRUhMGCBEY";
    //this is Firebase Rest API
    final response, responseData;
    try{
      response = await http.post(Uri.parse(url), body: json.encode({
        "email":email,
        "password": password,
        "returnSecureToken": true,
      }));

      responseData = json.decode(response.body);

      if(responseData["error"] != null){ //this signIn/signUp does not throw error or you can say it always return status code 400, so http will not be able
        //to throw error so we have to check ourself that there is any error in our response
        throw HttpException(responseData["error"]["message"]);
      }

      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData["expiresIn"]))); //the api return a response which says
      //in how much time the use token will expire.

      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance(); //creating a shared preference object
      //if we are able to authenticate user the we will store user data on device using sharedpreferences package.
      final userData = json.encode({
        "token":_token,
        "userId":_userId,
        "expiryDate":_expiryDate.toIso8601String(),
      });


      prefs.setString("userData", userData); //and storing data as string into that, and that will eventually will be saved on device.
    }
    catch(error){
      throw error;
    }

  }

  Future<void> signUp (String email, String password) async {
    return _authenticate(email, password, "signUp");

  }

  Future<void> signIn(String email, String password) async{
    print("sign in");
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    //this method will try to auto login in user on basis of user Data stored on device.

    print("trying auto log in");
    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey("userData")) return false; //if userDate is not stored on device return false;
    final extractedData = json.decode(prefs.getString("userData") as String) as Map<String, dynamic>;


    if(DateTime.parse(extractedData["expiryDate"]).isBefore(DateTime.now())){
      return false; //if expiry time of token is passed then return false;
    }

    //else store the user data in variables.
    _token = extractedData["token"];
    _userId = extractedData["userId"];
    _expiryDate = DateTime.parse(extractedData["expiryDate"]);
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token ="";
    _userId ="";
    _expiryDate = DateTime.now();
    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); //this here when we logout will remove stored user token from device which will prevent auto log in
    notifyListeners();
  }

  void _autoLogout(){

    //this method will auto logout user as time of token expire.
    //which is stored in expiry time.
    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }

    final _timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds:_timeToExpiry), logout);
  }
}