import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/models/location_data.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/widgets/form_inputs/image.dart';
import 'package:ferplayapp/src/widgets/form_inputs/location.dart';
import 'package:ferplayapp/src/widgets/ui_elements/adapative_progress_indicator.dart';

class EventoEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventoEditPageState();
  }
}

class _EventoEditPageState extends State<EventoEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final _titleFocusNode = FocusNode();
  //final _descriptionFocusNode = FocusNode();
  //final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    final Widget pageContent = _buildPageContent(context, _eventoBloc);
    return _eventoBloc.selectedEventoIndex == -1
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Evento'),
              elevation:
                  Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            ),
            body: pageContent,
          );
  }

  Widget _buildTitleTextField(Evento evento) {
    if (evento == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (evento != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = evento.title;
    } else if (evento != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (evento == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return TextFormField(
      //focusNode: _titleFocusNode,
      decoration: InputDecoration(labelText: 'Evento Title'),
      controller: _titleTextController,
      // initialValue: evento == null ? '' : evento.title,
      validator: (String value) {
        // if (value.trim().length <= 0) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Evento evento) {
    if (evento == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (evento != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = evento.description;
    }
    return TextFormField(
      //focusNode: _descriptionFocusNode,
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Evento Description'),
      // initialValue: evento == null ? '' : evento.description,
      controller: _descriptionTextController,
      validator: (String value) {
        // if (value.trim().length <= 0) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Evento evento) {
    if (evento == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (evento != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = evento.price.toString();
    }
    return TextFormField(
      //focusNode: _priceFocusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Evento Price'),
      controller: _priceTextController,
      // initialValue: evento == null ? '' : evento.price.toString(),
      validator: (String value) {
        // if (value.trim().length <= 0) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
      },
    );
  }

  Widget _buildSubmitButton(EventoBloc eventoBloc) {
    return StreamBuilder<bool>(
      stream: eventoBloc.outLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool _isLoading = false;
        snapshot.hasData ? _isLoading = snapshot.data : _isLoading = false;
        Widget content = Center(child: Text('No Eventos Found!'));

        _isLoading ?
          content = Center(child: AdaptiveProgressIndicator())
        : content = RaisedButton(
            child: Text('Save'),
            textColor: Colors.white,
            onPressed: () => _submitForm(
                context,
                eventoBloc.addEvento,
                eventoBloc.updateEvento,
                eventoBloc.selectEvento,
                eventoBloc.selectedEventoIndex),
          );

        return content;
      },
    );
  }

  Widget _buildPageContent(BuildContext context, EventoBloc eventoBloc) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    var evento = eventoBloc.selectedEvento;
    return 
    // GestureDetector(
    //   onTap: () {
    //     FocusScope.of(context).requestFocus(FocusNode());
    //   },
    //   child: 
      Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(evento),
              _buildDescriptionTextField(evento),
              _buildPriceTextField(evento),
              SizedBox(
                height: 10.0,
              ),
              LocationInput(_setLocation, evento),
              SizedBox(height: 10.0),
              ImageInput(_setImage, evento),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(eventoBloc),
              // GestureDetector(
              //   onTap: _submitForm,
              //   child: Container(
              //     color: Colors.green,
              //     padding: EdgeInsets.all(5.0),
              //     child: Text('My Button'),
              //   ),
              // )
            ],
          ),
        ),
      // ),
    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(BuildContext context, Function addEvento,
      Function updateEvento, Function setSelectedEvento,
      [int selectedEventoIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedEventoIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectedEventoIndex == -1) {
      addEvento(
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              double.parse(
                  _priceTextController.text.replaceFirst(RegExp(r','), '.')),
              _formData['location'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/eventos')
              .then((_) => setSelectedEvento(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again!'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateEvento(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text.replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((_) => Navigator.pushReplacementNamed(context, '/eventos')
          .then((_) => setSelectedEvento(null)));
    }
  }
}
