// ignore_for_file: file_names, unnecessary_const, unnecessary_null_comparison, unnecessary_brace_in_string_interps, deprecated_member_use, non_constant_identifier_names
import 'dart:async';

import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/database_db.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:flutter/services.dart';

class OnaySayfasi extends StatefulWidget {
  OnaySayfasi({Key? key}) : super(key: key);

  @override
  State<OnaySayfasi> createState() => _OnaySayfasiState();
}

class _OnaySayfasiState extends State<OnaySayfasi> {
  var _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String randomSayi = '';
  String randomNumara = "";
  bool _randomDogrula = false;

  late Future<Map<String, dynamic>> futdata;

  @override
  void initState() {
    super.initState();
    futdata = DataBaseGets().getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: futdata,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return body(snapshot);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Scaffold body(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 238, 252),
      appBar: AppBar(
        title: Text(
          "Sayın ${snapshot.data!['isim']}",
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Kod: $randomSayi',
              style: const TextStyle(fontSize: 30.0),
            ),
            Container(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: <Widget>[
                  _loading ? _LinearProgressIndicator() : Container(),
                  _ilerlemeyiSagla()
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  if (buttonOnayi == true) {
                    _updateProgress();
                    _loading = !_loading;
                  }
                });
              },
              child: const Text(" Güvenlik Kodu Almak İçin Tıklayınız"),
              color: buttonOnayi == false ? Colors.grey : Colors.blue,
            ),
            Expanded(
              child: Container(
                child: TextFormField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      randomNumara = value;
                    });
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: _controller.clear,
                      icon: Icon(Icons.clear),
                    ),
                    labelText: "Kodu giriniz",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Container(
                        child: RaisedButton(
                          color: Colors.teal,
                          onPressed: () {
                            _randomOnayla();
                          },
                          child: const Text(
                            "Doğrula",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: RaisedButton(
                        color: Colors.teal,
                        onPressed: () {
                          RandomGirisOnayi();
                        },
                        child: const Text(
                          "Giriş Yap",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 90.0),
              ],
            )
          ],
        ),
      ),
    );
  }

  void RandomGirisOnayi() async {
    late Map<String, dynamic> data;
    data = await futdata;
    if (_randomDogrula == true && randomNumara == randomSayi) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => AnaSayfa()));
      CustomSnackBar().snackbar(context, 'Hoş Geldiniz.', 3);
    } else if (randomNumara == null) {
      CustomSnackBar().snackbar(context, 'Lütfen Önce Kodu Doğrulayın!!!', 3);
    } else {
      CustomSnackBar().snackbar(context, 'Lütfen Önce Kodu Doğrulayın!!!', 3);
    }
  }

  void _randomOnayla() async {
    if (randomSayi == '') {
      CustomSnackBar().snackbar(context, 'Lütfen Önce Kodu Alınız!!!', 3);
    } else if ((randomNumara == '')) {
      CustomSnackBar().snackbar(context, 'Kodu Girdiniz!!!', 3);
    } else if ((randomNumara != randomSayi)) {
      CustomSnackBar().snackbar(context, 'Kodu Hatalı Girdiniz!!!', 3);
    } else if ((randomNumara == randomSayi)) {
      _randomDogrula = true;
      CustomSnackBar().snackbar(context, 'Kod Başarıyla Doğrulandı', 3);
    } else {
      _randomDogrula = false;
      CustomSnackBar().snackbar(context, 'Kodu Giriniz!!!', 3);
    }
  }

  @override
  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.2;

        if (_progressValue.toStringAsFixed(1) == '1.0') {
          randomSayi = (Random().nextInt(89999) + 10000).toString();
          buttonOnayi = false;
          _loading = true;
          t.cancel();

          CustomSnackBar().snackbar(context, 'Kod Başarıyla Alındı.', 3);
          return;
        }
      });
    });
  }
}

double _progressValue = 0;
bool _loading = false;
bool buttonOnayi = true;

Widget _ilerlemeyiSagla() {
  String progress = '${_progressValue * 100}';
  return Text('%$progress');
}

Widget _LinearProgressIndicator() {
  return LinearProgressIndicator(
    value: _progressValue,
  );
}
