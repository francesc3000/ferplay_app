import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ferplayapp/src/shared/global_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class FirebaseHttpRepository {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final _analytics = new FirebaseAnalytics();

  Future<http.Response> signUp(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKeyAuth',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  Future<http.Response> login(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKeyAuth',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  Future<http.Response> uploadImage(String token, File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-course-2f03d.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] = 'Bearer $token';

    try {
      final streamedResponse = await imageUploadRequest.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<http.Response> addEvento(
      String token, Map<String, dynamic> eventoData) async {
    final http.Response response = await http.post(
        'https://flutter-course-2f03d.firebaseio.com/eventos.json?auth=$token',
        body: json.encode(eventoData));

    return response;
  }

  Future<http.Response> updateEvento(String token, String updatedEventoId,
      Map<String, dynamic> updateData) async {
    final http.Response response = await http.put(
        'https://flutter-course-2f03d.firebaseio.com/eventos/$updatedEventoId.json?auth=$token',
        body: json.encode(updateData));

    return response;
  }

  Future<http.Response> deleteEvento(
      String token, String deletedEventoId) async {
    final http.Response response = await http.delete(
        'https://flutter-course-2f03d.firebaseio.com/eventos/$deletedEventoId.json?auth=$token');

    return response;
  }

  Future<http.Response> fetchEventos(String token) async {
    try {
      http.Response response = await http.get(
          'https://flutter-course-2f03d.firebaseio.com/eventos.json?auth=$token');

      return response;
    } catch (error) {
      print('Something went wrong fetching eventos');
      return null;
    }
  }

  Future<http.Response> addFavoriteEvento(
      String eventoId, String userId, String token) async {
    try {
      http.Response response = await http.put(
          'https://flutter-course-2f03d.firebaseio.com/eventos/$eventoId/wishlistUsers/$userId.json?auth=$token',
          body: json.encode(true));

      return response;
    } catch (error) {
      print('Something went wrong adding favorite evento in db');
      return null;
    }
  }

  Future<http.Response> deleteFavoriteEvento(
      String eventoId, String userId, String token) async {
    try {
      http.Response response = await http.delete(
          'https://flutter-course-2f03d.firebaseio.com/eventos/$eventoId/wishlistUsers/$userId.json?auth=$token');

      return response;
    } catch (error) {
      print('Something went wrong deleting favorite evento in db');
      return null;
    }
  }

  Future<Map<String, dynamic>> googleAutoLogin() async {
    try {
      GoogleSignInAccount googleUser = _googleSignIn.currentUser;
      if (googleUser == null) googleUser = await _googleSignIn.signInSilently();

      if (googleUser != null)
        return _buildUserFields(
            email: googleUser.email,
            displayName: googleUser.displayName,
            photoUrl: googleUser.photoUrl,
            token: null,
            expiryTime: null);
    } catch (error) {
      print(error);
    }

    return null;
  }

  Future<Map<String, dynamic>> facebookAutoLogin(String token) async {
    FirebaseUser firebaseUser =
        await _auth.signInWithFacebook(accessToken: token);

    return firebaseUser == null
        ? null
        : _buildUserFields(
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoUrl,
            token: token,
            expiryTime: null);
  }

  Future<Map<String, dynamic>> googleLogin() async {
    GoogleSignInAuthentication credentials;

    try {
      await _googleSignIn.signIn();
      _analytics.logLogin();
      if (await _auth.currentUser() == null) {
        credentials = await _googleSignIn.currentUser.authentication;

        await _auth.signInWithGoogle(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken,
        );
      }

      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null)
        return _buildUserFields(
            email: googleSignInAccount.email,
            displayName: googleSignInAccount.displayName,
            photoUrl: googleSignInAccount.photoUrl,
            token: credentials == null ? null : credentials.accessToken,
            expiryTime: null);
    } catch (error) {
      print(error);
    }

    return null;
  }

  Future<Map<String, dynamic>> facebookLogin() async {
    var accessToken;
    Map<String, dynamic> response;
    _analytics.logLogin();
    //if (googleSignInAccount == null) {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin
        //.logInWithReadPermissions(['email', 'user_photos']);
        .logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        accessToken = result.accessToken;
        FirebaseUser firebaseUser =
            await _auth.signInWithFacebook(accessToken: accessToken.token);
        //  var graphResponse = await http.get(
        //      'https://graph.facebook.com/v3.1/${accessToken.userId}?fields=id,name,email&access_token=${accessToken.token}');

        // if (graphResponse.statusCode == 200 ||
        //     graphResponse.statusCode == 201) {

        //   //https://developers.facebook.com/docs/graph-api/reference/profile-picture-source/
        //   var pictureResponse = await http
        //       //.get('http://graph.facebook.com/$userId/picture?type=square');
        //       .get('https://graph.facebook.com/v3.1/${accessToken.userId}/picture?redirect=false&access_token=${accessToken.token}');

        //   if (pictureResponse.statusCode == 200 ||
        //       pictureResponse.statusCode == 201) {

        //     var photoUrl;
        //     var profile = json.decode(graphResponse.body);
        //     var photoProfile = json.decode(pictureResponse.body);

        //     Map<String,dynamic> data = photoProfile['data'];

        //     data.forEach((key, value){
        //       if(key=='url')
        //         photoUrl = value;
        //     });

        response = _buildUserFields(
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoUrl,
            token: accessToken.token,
            expiryTime: accessToken.expires);

        //}
        //}
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
    //}

    return response;
  }

  Map<String, dynamic> _buildUserFields(
      {String email,
      String displayName,
      String photoUrl,
      String token,
      DateTime expiryTime}) {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'token': token,
      'expiryTime': expiryTime
    };
  }
}
