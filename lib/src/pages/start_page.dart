import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/pages/account_page.dart';
import 'package:ferplayapp/src/pages/eventos_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool displayMode;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    final List<Widget> _pages = [EventosPage(),AccountPage()];

    _eventoBloc.fetchEventos();

    // return StreamBuilder<bool>(
    //     stream: _eventoBloc.outToggleDisplayMode,
    //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
    //       snapshot.hasData ? displayMode = snapshot.data : displayMode = false;
          return Scaffold(
            //drawer: _buildSideDrawer(context),
            appBar: AppBar(
              title: Text('Yo Corro ¿Y tú?'),
              elevation:
                  Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
              actions: <Widget>[
                // IconButton(
                //   icon: Icon(
                //       displayMode ? Icons.favorite : Icons.favorite_border),
                //   onPressed: () {
                //     _eventoBloc.toggleDisplayMode();
                //   },
                // ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Powered by'),
                    Text('FerPlay'),
                  ],
                ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              fixedColor: Theme.of(context).primaryColor,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: new Icon(Icons.home), title: new Text("Eventos")),
                BottomNavigationBarItem(
                    icon: new Icon(Icons.person), title: new Text("Yo")),
              ],
            ),
          );
        // });
  }
}

// Widget _buildSideDrawer(BuildContext context) {
//   return Drawer(
//     child: Column(
//       children: <Widget>[
//         AppBar(
//           automaticallyImplyLeading: false,
//           title: Text('Choose'),
//           elevation:
//               Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
//         ),
//         ListTile(
//           leading: Icon(Icons.edit),
//           title: Text('Manage Eventos'),
//           onTap: () {
//             Navigator.pushReplacementNamed(context, '/admin');
//           },
//         ),
//         Divider(),
//         LogoutListTile()
//       ],
//     ),
//   );
// }
