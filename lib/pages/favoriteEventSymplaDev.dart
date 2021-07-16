import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sympla_dev/pages/eventSymplaDev.dart';

class FavoriteEventSymplaDev extends StatefulWidget {
  const FavoriteEventSymplaDev({Key? key}) : super(key: key);

  @override
  _FavoriteEventSymplaDevState createState() => _FavoriteEventSymplaDevState();
}

class _FavoriteEventSymplaDevState extends State<FavoriteEventSymplaDev> {
  final Stream<QuerySnapshot> _favoritosStream =
      FirebaseFirestore.instance.collection("favoritos").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _favoritosStream,
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
                "Favoritos",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EventSymplaDev(data))),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(spreadRadius: 1, blurRadius: 1)
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                          "https://blog.sympla.com.br/wp-content/uploads/2018/09/O-que-é-um-evento.png"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${data['data'].split('-')[2]}/"
                                            "${data['data'].split('-')[1]}/"
                                            "${data['data'].split('-')[0]}"
                                            " às ${data['hora'].split(':')[0]}"
                                            ":${data['hora'].split(':')[1]}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 17),
                                          ),
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.red),
                                            child: Icon(
                                              Icons.favorite,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${data['nome']}',
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 0, 0, 5),
                                            child: Text(
                                              '${data['local']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ));
      },
    );
  }
}
