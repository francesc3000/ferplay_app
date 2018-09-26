import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String photoUrl;
  final String token;

  User({@required this.id, @required this.email, @required this.fullName, this.photoUrl, this.token});
}
