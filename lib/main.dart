import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sympla_dev/navigatorSymplaDev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BodySimplaDev(),
    )
  );
}
