import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/blocs/user_bloc.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/pages/auth_page.dart';
import 'package:ferplayapp/src/pages/evento_page.dart';
import 'package:ferplayapp/src/pages/eventos_admin_page.dart';
import 'package:ferplayapp/src/pages/eventos_page.dart';
import 'package:ferplayapp/src/pages/start_page.dart';
import 'package:ferplayapp/src/shared/adaptive_theme.dart';
import 'package:ferplayapp/src/widgets/helpers/custom_route.dart';
import 'package:ferplayapp/src/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool _isLoading;
  bool _authenticated;
  //final _platformChannel = MethodChannel('flutter-course.com/battery');

  // Future<Null> _getBatteryLevel() async {
  //   String batteryLevel;
  //   try {
  //     final int result = await _platformChannel.invokeMethod('getBatteryLevel');
  //     batteryLevel = 'Battery level is $result %.';
  //   } catch (error) {
  //     batteryLevel = 'Failed to get battery level.';
  //     print(error);
  //   }
  //   print(batteryLevel);
  // }

  @override
  Widget build(BuildContext context) {
    print('building main page');
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    final EventoBloc eventoBloc = BlocProvider.of<EventoBloc>(context);
    return StreamBuilder<bool>(
      stream: userBloc.outLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        snapshot.hasData ? _isLoading = snapshot.data : _isLoading = false;

        if (_isLoading)
          return MaterialApp(
            title: 'Yo Corro¿Y tu?',
            theme: getAdaptiveThemeData(context),
            home: Scaffold(body: Center(child: AdaptiveProgressIndicator())),
          );
        else
          return StreamBuilder<bool>(
            stream: userBloc.outAuthenticated,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              snapshot.hasData
                  ? _authenticated = snapshot.data
                  : _authenticated = false;
              //_getBatteryLevel();
              return MaterialApp(
                // debugShowMaterialGrid: true,
                title: 'Yo Corro¿Y tu?',
                theme: getAdaptiveThemeData(context),
                //   home: AuthPage(),
                routes: {
                  '/': (BuildContext context) =>
                      !_authenticated ? AuthPage() : StartPage(),
                  '/admin': (BuildContext context) =>
                      !_authenticated ? AuthPage() : _adminPage(),
                },
                onGenerateRoute: (RouteSettings settings) {
                  print("Estoy en onGenerateRoute");
                  if (!_authenticated) {
                    return MaterialPageRoute<bool>(
                      builder: (BuildContext context) => AuthPage(),
                    );
                  }
                  final List<String> pathElements = settings.name.split('/');
                  if (pathElements[0] != '') {
                    return null;
                  }
                  if (pathElements[1] == 'evento') {
                    final String eventoId = pathElements[2];
                    eventoBloc.selectEvento(eventoId);
                    final Evento evento = eventoBloc.selectedEvento;
                    return CustomRoute<bool>(
                      builder: (BuildContext context) =>
                          !_authenticated ? AuthPage() : EventoPage(evento),
                    );
                  }
                  return null;
                },
                onUnknownRoute: (RouteSettings settings) {
                  return MaterialPageRoute(
                      builder: (BuildContext context) =>
                          !_authenticated ? AuthPage() : EventosPage());
                },
              );
            },
          );
      },
    );
  }

  Widget _adminPage() {
    //final EventoBloc eventoBloc = BlocProvider.of<EventoBloc>(context);
    //eventoBloc.selectEvento(null);
    return EventosAdminPage();
  }
}
