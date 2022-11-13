import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'giris_sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BankaUygulamasi(),
  ));
}

class BankaUygulamasi extends StatelessWidget {
  const BankaUygulamasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GirisEkrani();
  }
}
