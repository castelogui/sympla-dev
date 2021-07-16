import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sympla_dev/pages/favoriteEventSymplaDev.dart';

class EventSymplaDev extends StatefulWidget {
  var data;
  EventSymplaDev(this.data);

  @override
  _EventSymplaDevState createState() => _EventSymplaDevState();
}

class _EventSymplaDevState extends State<EventSymplaDev> {
  CollectionReference favoritos =
      FirebaseFirestore.instance.collection("favoritos");

  Future<void> _favoritar() {
    return favoritos
        .add({
          'nome': widget.data['nome'],
          'local': widget.data['local'],
          'lat': widget.data['lat'],
          'lng': widget.data['lng'],
          'data': widget.data['data'],
          'hora': widget.data['hora'],
          'tipo': widget.data['tipo'],
          'user_creator': widget.data['user'],
          'descricao': widget.data['descricao'],
        })
        .then((value) => print("Evento favorito salvo"))
        .catchError((onError) => print("Não foi possível salvar"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe0dfdf),
      floatingActionButton: BackButton(
        color: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Column(
        children: [
          Image.network(
              "https://blog.sympla.com.br/wp-content/uploads/2018/09/O-que-é-um-evento.png"),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            width: 500,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.data['nome']}",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '@${widget.data['user']}',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _favoritar();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FavoriteEventSymplaDev()));
                        },
                        child: Container(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.black26,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.date_range_sharp,
                            color: Colors.black38,
                            size: 20,
                          ),
                        ),
                        Text(
                          "${widget.data['data'].split('-')[2]}/"
                          "${widget.data['data'].split('-')[1]}/"
                          "${widget.data['data'].split('-')[0]}"
                          " às ${widget.data['hora'].split(':')[0]}"
                          ":${widget.data['hora'].split(':')[1]}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.language,
                            color: Colors.black38,
                            size: 20,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.data['tipo']}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${widget.data['local']}",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Expanded(
              child: Container(
                width: 500,
                height: 200,
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Descrição do evento",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 500,
                        child: Text(
                          '${widget.data['descricao']}',
                          style: TextStyle(),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
