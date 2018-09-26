import 'dart:async';

import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/dao/factory_dao.dart';
import 'package:ferplayapp/src/dao/model/user_data.dart';
import 'package:ferplayapp/src/models/auth.dart';
import 'package:ferplayapp/src/models/user.dart';
import 'package:ferplayapp/src/shared/Injector.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthPlatform{
  google,
  facebook
}

class UserBloc extends BlocBase {
  Timer _authTimer;

  // ##########  STREAMS  ##############
  ///
  /// Interface that informs authentication is loading
  ///
  BehaviorSubject<bool> _isLoadingController =
      BehaviorSubject<bool>(seedValue: false);
  Sink<bool> get _inLoading => _isLoadingController.sink;
  Stream<bool> get outLoading => _isLoadingController.stream;

  ///
  /// Interface that allows to get Authentication state
  ///
  BehaviorSubject<bool> _authenticatorController =
      BehaviorSubject<bool>(seedValue: false);
  Sink<bool> get _inAuthenticated => _authenticatorController.sink;
  Stream<bool> get outAuthenticated => _authenticatorController.stream;

  ///
  /// Interface that allows to get Authentication User
  ///
  BehaviorSubject<User> _authUserController =
      BehaviorSubject<User>();
  Sink<User> get _inAuthUserController => _authUserController.sink;
  Stream<User> get outAuthUserController => _authUserController.stream;

  ///
  /// Constructor
  ///
  UserBloc() {
    _autoAuthenticate();
  }

  @override
  void dispose() {
    _isLoadingController.close();
    _authenticatorController.close();
    _authUserController.close();
  }

  // ############# HANDLING  #####################

  // void _handleIsLoading(bool isLoading) {
  //   // Save Loading state
  //   _isLoading = isLoading;

  //   _inLoading.add(_isLoading);
  // }

  Future<Null> googleLogin() async {
    print("Dentro de googleLogin");

    _inLoading.add(true);
    UserData userData = await FactoryDao.userDao.googleLogin();

    bool _isAuthenticated = await _loadUser(AuthPlatform.google,userData);
    _inAuthenticated.add(_isAuthenticated);
    _inLoading.add(false);  
  }

  Future<Null> facebookLogin() async {
    print("Dentro de FacebookLogin");

    _inLoading.add(true);
    UserData userData = await FactoryDao.userDao.facebookLogin();

    bool _isAuthenticated = await _loadUser(AuthPlatform.facebook, userData);
    _inAuthenticated.add(_isAuthenticated);
    _inLoading.add(false);  
  }

  Future<bool> _loadUser(AuthPlatform loggedIn, UserData userData) async {
    if(userData!=null){
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('loggedIn', loggedIn.toString());
      prefs.setString('token', userData.token);
      prefs.setString('userId', userData.userId);
      prefs.setString('userEmail', userData.email);
      prefs.setString('expiryTime', userData.expiryTime==null ? "" : userData.expiryTime.toIso8601String());

      authenticatedUser = User(
          id: userData.id,
          email: userData.email,
          fullName: userData.displayName,
          photoUrl: userData.photoUrl);

      _inAuthenticated.add(true);
      
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _inLoading.add(true);

    Map<String, dynamic> responseData;
    if (mode == AuthMode.Login)
      responseData = await FactoryDao.userDao.login(email, password);
    else
      responseData = await FactoryDao.userDao.signUp(email, password);

    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          fullName: responseData['displayName'],
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _inLoading.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('fullName', responseData['displayName']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());

      _inAuthenticated.add(true);
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _inLoading.add(false);

    return {'success': !hasError, 'message': message};
  }

  void _autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String loggedIn = prefs.getString('loggedIn');

    _inLoading.add(true);
    if(loggedIn!=null && loggedIn == AuthPlatform.google.toString()){
      print("Tratando de autoregistrase en Google");
      UserData userData = await FactoryDao.userDao.googleAutoLogin();
      _loadUser(AuthPlatform.google, userData);
    }
    else if(loggedIn!=null && loggedIn == AuthPlatform.facebook.toString()){
      print("Tratando de autoregistrase en Facebook");
      final String token = prefs.getString('token');
      UserData userData = await FactoryDao.userDao.facebookAutoLogin(token);
      _loadUser(AuthPlatform.facebook, userData);
    }
    else{
      final String token = prefs.getString('token');
      final String expiryTimeString = prefs.getString('expiryTime');
      if (token != null) {
        final DateTime now = DateTime.now();
        final parsedExpiryTime = DateTime.parse(expiryTimeString);
        if (parsedExpiryTime.isBefore(now)) {
          authenticatedUser = null;
          _inAuthenticated.add(false);
          return;
        }
        final String userEmail = prefs.getString('userEmail');
        final String userId = prefs.getString('userId');
        final String fullName = prefs.getString('fullName');
        final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
        authenticatedUser = User(id: userId, email: userEmail, fullName: fullName, token: token);
        _inAuthenticated.add(true);
        setAuthTimeout(tokenLifespan);
      }
    }
    _inLoading.add(false);
  }

  set authenticatedUser(User authenticatedUser) {
    Injector.currentUser = authenticatedUser;
    _inAuthUserController.add(authenticatedUser);
  }

  void logout() async {
    authenticatedUser = null;
    _inAuthenticated.add(false);
    //TODO: Deseleccionar el eventoo
    //_selEventoId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedIn');
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    prefs.remove('expiryTime');

    if(_authTimer!=null)
      _authTimer.cancel();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}


