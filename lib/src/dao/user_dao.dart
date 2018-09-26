
import 'dart:async';
import 'package:ferplayapp/src/dao/model/user_data.dart';
import 'package:ferplayapp/src/repository/firebase_http_repository.dart';

import 'dart:convert';

abstract class UserDao{
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserData> googleLogin();
  Future<UserData> facebookLogin();
  Future<UserData> googleAutoLogin();
  Future<UserData> facebookAutoLogin(String token);
}

class UserDaoFirebaseImpl implements UserDao{
  FirebaseHttpRepository firebaseRepository;

  UserDaoFirebaseImpl(){
    firebaseRepository = FirebaseHttpRepository();
  }
  
  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    
    var response = await firebaseRepository.signUp(email, password);

    return json.decode(response.body);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async{
    
    var response = await firebaseRepository.login(email, password);

    return json.decode(response.body);
  }

  @override
  Future<UserData> googleAutoLogin() async{

    var response = await firebaseRepository.googleAutoLogin();

    if(response!=null)
      return UserData(id: response['id'],
            email: response['email'],
            displayName: response['displayName'],
            photoUrl: response['photoUrl'],
            token: response['token']);
    else
      return null;
      
  }

  @override
  Future<UserData> facebookAutoLogin(String token) async{

    var response = await firebaseRepository.facebookAutoLogin(token);

    if(response!=null)
      return UserData(id: response['id'],
            email: response['email'],
            displayName: response['displayName'],
            photoUrl: response['photoUrl'],
            token: response['token']);
    else
      return null;
      
  }

  @override
  Future<UserData> googleLogin() async{

    var response = await firebaseRepository.googleLogin();

    if(response!=null)
      return UserData(id: response['id'],
            email: response['email'],
            displayName: response['displayName'],
            photoUrl: response['photoUrl'],
            userId: response['userId'],
            token: response['token'],
            expiryTime: response['expiryTime']);
    else
      return null;

  }

  @override
  Future<UserData> facebookLogin() async{
    var response = await firebaseRepository.facebookLogin();

    if(response!=null)
      return UserData(id: response['id'],
            email: response['email'],
            displayName: response['displayName'],
            photoUrl: response['photoUrl'],
            userId: response['userId'],
            token: response['token'],
            expiryTime: response['expiryTime']);
    else
      return null;
  }
}