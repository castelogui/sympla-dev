import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sympla_dev/pages/eventSymplaDev.dart';

class HomeSymplaDev extends StatefulWidget {
  const HomeSymplaDev({Key? key}) : super(key: key);

  @override
  _HomeSymplaDevState createState() => _HomeSymplaDevState();
}

class _HomeSymplaDevState extends State<HomeSymplaDev> {
  final Stream<QuerySnapshot> _eventosStream =
      FirebaseFirestore.instance.collection("eventos").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _eventosStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Erro ao carregar!");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Column(
              children: [Text("Carregando informações")],
            ),
          );
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(
                "Eventos",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),
            body: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return Container(
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventSymplaDev(data))),
                        child: Container(
                            width: 250,
                            height: 110,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1, color: Colors.black)
                                ]),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${data['nome']}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Text('Evento ${data['tipo']}'),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                        '${data['data'].split('-')[2]}/${data['data'].split('-')[1]} - ${data['hora']}'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                      child: Expanded(
                                        child: Text(
                                          '${data['local'].split(",")[0]}, ${data['local'].split(",")[2]}',
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ));
      },
    );
  }
}
