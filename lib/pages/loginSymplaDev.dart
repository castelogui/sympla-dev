 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sympla_dev/pages/createEventSymplaDev.dart';

class LoginSymplaDev extends StatefulWidget {
  const LoginSymplaDev({Key? key}) : super(key: key);

  @override
  _LoginSymplaDevState createState() => _LoginSymplaDevState();
}

class _LoginSymplaDevState extends State<LoginSymplaDev> {
  TextEditingController username = TextEditingController();
  String newUsername = '';

  Map<String, dynamic> loginValidate = {"login": ""};

  Future<void> vLoginAntigo() async {
    FirebaseFirestore.instance
        .collection('login')
        .get()
        .then((QuerySnapshot querySnapshot) {
      Map<String, dynamic> test = querySnapshot.docs.first.data() as Map<
          String,
          dynamic>;
      if (test.values.first != "") {
        loginValidate = querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    });
  }

  late Map<String, dynamic> usuario;

  _obterRequesicao(String user) async {
    var url = Uri.https('api.github.com', '/users/$user');

    http.Response resposta = await http.get(url);
    if (resposta.statusCode == 200) {
      usuario = json.decode(resposta.body);
    } else {
      print(resposta.body);
      throw 'Erro, solicitação nao atendida';
    }
  }

  CollectionReference newUsuario = FirebaseFirestore.instance.collection('usuarios');

  CollectionReference login = FirebaseFirestore.instance.collection('login');

  Future<void> loginSympla(user) async {
    return login
        .doc("login")
        .update({'login': user.toString()})
        .then((value) => print("Login realizado"))
        .catchError((error) => print("Login nao realiazado: $error"));
  }

  Future<void> logoutSympla() async {
    setState(() {
      loginValidate = {"login": ""};
    });
    return login
        .doc("login")
        .update({'login': ""})
        .then((value) => print("Logout realizado"))
        .catchError((error) => print("Logout nao realiazado: $error"));
  }

  Future<void> adicionarUsuario() async {
    await _obterRequesicao(newUsername);
    return await
    newUsuario
        .add({
      'name': usuario["name"].toString(),
      'login': usuario["login"].toString(),
      'location': usuario["location"].toString(),
      'avatar_url': usuario["avatar_url"].toString(),
      'html_url': usuario["html_url"].toString(),
      'followers': usuario['followers'].toString(),
      'following': usuario['following'].toString(),
    })
        .then((value) => print("Usuario adicionado com sucesso!"))
        .catchError((onError) => print("Nao foi possível inserir..."));
  }

  showDialogUser(username, btValue) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$btValue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                )),
            content: TextField(
              decoration: InputDecoration(
                  labelText: "Username"
              ),
              controller: username,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      newUsername = username.text;
                    });
                    Navigator.pop(context);
                    if (btValue == "Cadastrar") {
                      await adicionarUsuario();
                    }
                    if (btValue == "Login") {
                      loginSympla(newUsername);
                    }
                  },
                  child: Text('Okay'))
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var buttonEntrar = "Login";
    var buttonCadastrar = "Cadastrar";

    CollectionReference _verifyLogin = FirebaseFirestore.instance.collection('login');

    print(loginValidate.values.first);
    if(loginValidate.values.first == ''){
      return FutureBuilder<DocumentSnapshot>(
        future: _verifyLogin.doc('login').get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Docuento not exists");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            loginValidate = snapshot.data!.data() as Map<String, dynamic>;
            if(loginValidate.values.first == ''){
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "Perfil",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                          child: Container(
                            child: Text(
                                "Faça login ou cadastre-se para ter acesso a suas informações pessoais.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w200,
                                )
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: ElevatedButton(
                                onPressed: () async {
                                  showDialogUser(username, buttonEntrar);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.person_rounded),
                                    Text("$buttonEntrar")
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green
                                ),
                              ),
                              width: 120,
                              height: 50,
                            ),
                            Container(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    showDialogUser(username, buttonCadastrar);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.assignment_ind_sharp),
                                      Text("$buttonCadastrar")
                                    ],
                                  )
                              ),
                              width: 120,
                              height: 50,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final Stream<QuerySnapshot> _userLogin =
            FirebaseFirestore.instance
                .collection('usuarios')
                .where('login', isEqualTo: loginValidate.values.first)
                .snapshots();
            return StreamBuilder<QuerySnapshot>(
                stream: _userLogin,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print("error");
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print("carregando");
                    print(snapshot.data);
                    return Text("Loading");
                  }
                  return Scaffold(
                      body: ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          print(data);
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                      child: Column(
                                        children: [
                                          // User infos
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 40, 0, 0),
                                            child: Container(
                                              width: 390,
                                              height: 210,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      //  CONTAINER AVATAR_URL
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(100),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors.black,
                                                                  spreadRadius: 2)
                                                            ],
                                                            image: DecorationImage(
                                                                fit: BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '${data["avatar_url"]}'
                                                                )
                                                            )
                                                        ),
                                                        width: 100,
                                                        height: 100,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .fromLTRB(
                                                            20, 0, 0, 0),
                                                        child: Container(
                                                          width: 200,
                                                          height: 100,
                                                          // NOME E USERNAME (LOGIN)
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              // NOME
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    // Expanded utilizado para quebrar linha automatica ao extourar layout
                                                                    child: Text(
                                                                      //name
                                                                      '${data["name"]}',
                                                                      style: TextStyle(
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight
                                                                            .w900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // LOGIN
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    '${data["login"]}',
                                                                    style: TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .black54
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  // FOLLOWERS E FOLLOWINGS
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        0, 5, 0, 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        // FOLLOWERS
                                                        Container(
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .fromLTRB(
                                                                      0, 0, 5, 0),
                                                                  child: Text(
                                                                    '${data["followers"]}',
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight: FontWeight
                                                                            .bold
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "followers",
                                                                  style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black54
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                        ),
                                                        // FOLLOWING
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .fromLTRB(
                                                                    0, 0, 5, 0),
                                                                child: Text(
                                                                  "${data["following"]}",
                                                                  style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .bold
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                "following",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: Colors
                                                                        .black54
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      logoutSympla();
                                                    });
                                                  },
                                                  child: Text(
                                                    "Sair",
                                                    style: TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.redAccent,
                                                  )
                                              ),
                                              ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.push(
                                                          context, MaterialPageRoute(
                                                          builder: (context) =>
                                                              CreateEventSymplaDev(
                                                                  "${data['login']}")
                                                      )
                                                      ),
                                                  child: Text("Criar Evento")
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                  );
                }
            );
          }
          return Text("carregando");
        },
      );
    }
    return Text("carregando");
  }
}
