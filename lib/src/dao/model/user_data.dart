import 'package:flutter/material.dart';

class UserData{
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final String userId;
  final String token;
  final DateTime expiryTime;

  UserData({@required this.id, @required this.email, @required this.displayName, this.photoUrl, this.userId, this.token, this.expiryTime});
}