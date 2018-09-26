import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/user_bloc.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc _userBloc = BlocProvider.of<UserBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Registro"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              color: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Text("Google"),
              onPressed: () => _userBloc.googleLogin(),
            ),
            RaisedButton(
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Text("Facebook"),
              onPressed: () => _userBloc.facebookLogin(),
            ),
          ],
        ),
      ),
    );
  }
}
