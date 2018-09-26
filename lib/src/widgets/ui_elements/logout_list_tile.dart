import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/user_bloc.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc _userBloc = BlocProvider.of<UserBloc>(context);
    return ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text('Logout'),
      onTap: () {
        _userBloc.logout();
      },
    );
  }
}
