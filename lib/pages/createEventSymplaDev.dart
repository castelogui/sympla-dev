import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sympla_dev/navigatorSymplaDev.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class CreateEventSymplaDev extends StatefulWidget {
  var user = '';
  CreateEventSymplaDev(this.user);

  @override
  _CreateEventSymplaDevState createState() => _CreateEventSymplaDevState();
}

class _CreateEventSymplaDevState extends State<CreateEventSymplaDev> {
  TextEditingController _controllerNome = TextEditingController();
  String _controllerData = '';
  String _controllerHora = '';
  String _controllerTipo = '';
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerLocal = TextEditingController();
  String opTipo = '';

  CollectionReference newEvento = FirebaseFirestore.instance.collection('eventos');

  Future<void> criarEvento()async{
    return await
    newEvento
        .add({
          'nome': _controllerNome.text.toString(),
          'local': _controllerLocal.text.toString(),
          'lat': lat.toString(),
          'lng': lng.toString(),
          'data': _controllerData.toString(),
          'hora': _controllerHora.toString(),
          'tipo': _controllerTipo.toString(),
          'user': widget.user.toString(),
          'descricao': _controllerDescricao.text.toString(),
        })
          .then((value) => print("Evento adicionado com sucesso!"))
          .catchError((onError) => print("Nao foi possível inserir"));
  }

  Set<Marker> _point = {};

  var lat;
  var lng;

  CollectionReference cordenadas = FirebaseFirestore.instance.collection("cordenadas");

  Future<void> _salvarCordenadas(LatLng latLng, Placemark endereco){
    return cordenadas.add({
      "latitude": latLng.latitude,
      "longitude": latLng.longitude,
      "name": endereco.name,
      "street": endereco.street,
      "isoCountryCode": endereco.isoCountryCode,
      "country": endereco.country,
      "postalCode": endereco.postalCode,
      "administrativeArea": endereco.administrativeArea,
      "subAdministrativeArea": endereco.subAdministrativeArea,
      "locality": endereco.locality,
      "sublocality": endereco.subLocality,
      "thoroughfare": endereco.thoroughfare,
      "subThoroughfare": endereco.subThoroughfare
    })
        .then((value) => print("Cordenadas salvas"))
        .catchError((onError) => print("Não foi possível salvar cordenada"));

  }

  late Placemark endereco;
  String enderecoFinal = '';

  _adicionarPoint(LatLng latlng)async{
    List<Placemark> placemarks = await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
    if(placemarks != null && placemarks.length > 0) {
      endereco = placemarks[0];
      String setor = endereco.subLocality.toString();
      String rua = endereco.street.toString();
      String numero = endereco.subThoroughfare.toString();
      setState(() {
        lat = latlng.latitude;
        lng = latlng.longitude;
      });
      _salvarCordenadas(latlng, endereco);

      Marker point = Marker(
          markerId: MarkerId("marcador-${latlng.latitude}-${latlng.longitude}"),
          position: latlng,
          infoWindow: InfoWindow(
              title: setor,
              snippet: ("$rua - $numero")
          )
      );
      setState(() {
        _point.clear();
        _point.add(point);
        enderecoFinal = ("$rua, $numero, $setor");
      });
    }
  }

  showDialogMessage(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Evento criado com sucesso!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                )),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () async{
                    await criarEvento();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BodySimplaDev()));
                  },
                  child: Text('Okay'))
            ],
          );
        }
    );
  }


  showDialogCreatePoint() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clique no mapa para adicionar um ponto",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
            content: Container(
              width: 200,
              height: 350,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(-9.899061,-63.02922959999999),
                  zoom: 14,
                ),
                onTap: _adicionarPoint,
                markers: _point,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context,enderecoFinal);
                    setState(() {
                      _controllerLocal.text = enderecoFinal.toString();
                    });
                  },
                  child: Text('Okay'))
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat("dd/MM/yyyy HH:mm");

    return Scaffold(
      appBar: AppBar(
        title: Text("Criar Evento DEV"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  // NOME DO EVENTO
                  Container(
                    width: 250,
                    child: TextField(
                      controller: _controllerNome,
                      decoration: InputDecoration(
                          icon: Icon(Icons.drive_file_rename_outline),
                          labelText: "Nome"
                      ),
                    ),
                  ),
                  // DATA DO EVENTO
                  Container(
                    width: 250,
                    child: DateTimeField(
                      format: format,
                      decoration: InputDecoration(
                          icon: Icon(Icons.date_range_sharp),
                          labelText: "Data"
                      ),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100)
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          );
                          _controllerData = DateTimeField.combine(date, time).toString().split(' ')[0];
                          _controllerHora = DateTimeField.combine(date, time).toString().split(' ')[1].split('.')[0];
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                  // DESCRIÇÃO DO EVENTO
                  Container(
                    width: 250,
                    child: TextField(
                      controller: _controllerDescricao,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: "Descrição               300"
                      ),
                    ),
                  ),
                  // LOCAL DO EVENTO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 230,
                        child: TextField(
                          controller: _controllerLocal,
                          decoration: InputDecoration(
                              icon: Icon(Icons.map),
                              labelText: "Local"
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: showDialogCreatePoint,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(color: Colors.blue, blurRadius: 1)
                            ]
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white
                          ),
                        ),
                      )
                    ],
                  ),
                  // TIPO DO EVENTO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Radio(
                              value: 'Online',
                              groupValue: _controllerTipo,
                              onChanged: (opTipo){
                                setState((){
                                  _controllerTipo = opTipo.toString();
                                });
                              }
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Text("Online"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Radio(
                              value: 'Presencial',
                              groupValue: _controllerTipo,
                              onChanged: (opTipo){
                                setState((){
                                  _controllerTipo = opTipo.toString();
                                });
                              }
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Text("Presencial"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: ElevatedButton(
                        onPressed: ()async{
                          showDialogMessage();
                        },
                        child: Text("Criar")
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
