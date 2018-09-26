import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/user_bloc.dart';
import 'package:ferplayapp/src/models/user.dart';
import 'package:ferplayapp/src/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    return Column(
      children: <Widget>[
        StreamBuilder<User>(
          stream: userBloc.outAuthUserController,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if(!snapshot.hasData)
              return Center(child: AdaptiveProgressIndicator());

            User user = snapshot.data;

            return Row(
              children: <Widget>[
                CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
                Column(
                  children: <Widget>[
                    Text(user.fullName),
                    Text(user.email),
                  ],
                )
              ],
            );
          },
         ),
          RaisedButton(
            child: Text('Cerrar Sesión'),
            onPressed: () {
              userBloc.logout();
            },
          ),
      ],
    );
  }
}
