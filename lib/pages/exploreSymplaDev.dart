import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class ExploreSymplaDev extends StatefulWidget {
  const ExploreSymplaDev({Key? key}) : super(key: key);

  @override
  _ExploreSymplaDevState createState() => _ExploreSymplaDevState();
}

class _ExploreSymplaDevState extends State<ExploreSymplaDev> {
  final Stream<QuerySnapshot> _eventStream = FirebaseFirestore.instance.collection('cordenadas').snapshots();

  Map<String, dynamic> data = {};
  Set<Marker> _marcadores = {};

  listEventP(snapshot){
    return new ListView(
      children: snapshot.data!.docs.map((DocumentSnapshot document) async {
        data = document.data() as Map<String, dynamic>;
        List<Placemark> placemarks = await placemarkFromCoordinates(data['latitude'], data["longitude"]);
        LatLng latlng = data['latitude']['longitude'];
        if(placemarks != null && placemarks.length > 0) {
          Placemark endereco = placemarks[0];
          String setor = endereco.subLocality.toString();
          String rua = endereco.street.toString();
          String numero = endereco.subThoroughfare.toString();
          print(endereco);

          Marker marcador = Marker(
             //markerId: MarkerId("marcador-${data['latitude']}-${data['longitude']}"),
            markerId: MarkerId("${-9.899061} - ${-63.02922959999999}"),
              position: latlng,
              infoWindow: InfoWindow(
                  title: setor,
                  snippet: ("$rua - $numero")
              )
          );
          setState(() {
            _marcadores.add(marcador);
            print(_marcadores.length);
          });
      }
      }).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _eventStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(-9.899061,-63.02922959999999),
            zoom: 14,
          ),
          markers: _marcadores,
          onCameraMove: listEventP,
        );
      },
    );
}


  /*
  Set<Marker> _marcadores = {};

  CollectionReference cordenadas = FirebaseFirestore.instance.collection("cordenadas");

  Future<void> _salvarCordenadas(LatLng latLng){
    return cordenadas.add({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    })
        .then((value) => print("Cordenadas salvas"))
        .catchError((onError) => print("Não foi possível salvar cordenada"));
  }


  _adicionarMarcadores(LatLng latlng)async{
    List<Placemark> placemarks = await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
    if(placemarks != null && placemarks.length > 0) {
      Placemark endereco = placemarks[0];
      String setor = endereco.subLocality.toString();
      String rua = endereco.street.toString();
      String numero = endereco.subThoroughfare.toString();
      _salvarCordenadas(latlng);

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latlng.latitude}-${latlng.longitude}"),
          position: latlng,
          infoWindow: InfoWindow(
            title: setor,
            snippet: ("$rua - $numero")
          )
      );
      setState(() {
        _marcadores.add(marcador);
        print(_marcadores.length);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-9.899061,-63.02922959999999),
          zoom: 14,
        ),
        markers: _marcadores,
        onLongPress: _adicionarMarcadores,
      ),

    );*/

/*
* Set<Marker> _marcadores = {};

  _carregarMarkes()async{
    Set<Marker> _listMarkers = {};
    Marker marcador1 = Marker(
      markerId: MarkerId("botanico"),
      position: LatLng(-9.9041999,-63.0500812),
      infoWindow: InfoWindow(
        title: "Primeiro Marker"
      ),
      //icon: BitmapDescriptor.defaultMarkerWithHue(
       // BitmapDescriptor.hueGreen
      //),
      icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(80, 80)),"images/marker.png"),
    );
    _listMarkers.add(marcador1);
    setState(() {
      _marcadores = _listMarkers;
    });
  }
  * @override
  Widget build(BuildContext context) {
    _carregarMarkes();
    return Container(
      child: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: CameraPosition(
          zoom: 14,
          target: LatLng(-9.9041999,-63.0500812),
        ),
        markers: _marcadores,
      ),
    );
  }

* */
}