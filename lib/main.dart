import 'package:ferplayapp/app.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/blocs/user_bloc.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/shared/global_config.dart';
import 'package:map_view/map_view.dart';

// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  MapView.setApiKey(apiKey);
  runApp(BlocProvider<UserBloc>(
    bloc: UserBloc(),
    child: BlocProvider<EventoBloc>(
      bloc: EventoBloc(),
      child: App(),
    ),
  ));
}