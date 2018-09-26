import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';

import './evento_edit_page.dart';
import './evento_list_page.dart';
import '../widgets/ui_elements/logout_list_tile.dart';

class EventosAdminPage extends StatefulWidget{
  EventosAdminPageState createState()=>  EventosAdminPageState();
}

class EventosAdminPageState extends State<EventosAdminPage> {

@override
  void initState() {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    _eventoBloc.fetchEventos(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Manage Eventos'),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Evento',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Eventos',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[EventoEditPage(), EventoListPage()],
        ),
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
            elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Eventos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }


}
