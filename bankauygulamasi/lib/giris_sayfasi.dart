// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_unnecessary_containers, unused_field, unused_import, unused_element, unrelated_type_equality_checks, unnecessary_null_comparison, avoid_types_as_parameter_names, prefer_const_constructors

import 'dart:io';
import 'dart:ui';
import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/onay_sayfasi.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_auth/email_auth.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({Key? key}) : super(key: key);

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  late String _kullanici, _sifre;
  int gsayac = 3;
  int zaman = 50;
  late Timer _timer;
  late Timer _saniye;
  // ignore: non_constant_identifier_names
  String saniye_artis = "";
  bool girisButton = true;

  void _baslatZaman() async {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (zaman > 0) {
            zaman--;
          } else {
            _timer.cancel();
            girisButton = false;
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _saniye = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        saniye_artis = "${DateTime.now().second}";
      });
    });
    _baslatZaman();
  }

  bool yuklenmeDurumu = false;
  bool sifreGizle = true;
  final _formAnahtari = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Güvenlik",
        ),
        actions: <Widget>[
          const Icon(
            Icons.security,
          )
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: yuklenmeDurumu
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: _formAnahtari,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.cyan,
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            const Text(
                              "TARİH-SAAT",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.black),
                            ),
                            Container(
                              height: 40.0,
                              width: double.infinity,
                              color: Colors.cyan,
                              child: Center(
                                child: Text(
                                  DateFormat(
                                    'dd-MM-yyyy - HH:mm:ss',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 75.0,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 30, right: 30),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              validator: (oge) {
                                if (oge!.isEmpty) {
                                  return "Kullanıcı adını giriniz!!!";
                                } else if (!oge.contains("@")) {
                                  return "Girilen değer mail formatında olmalı!!!";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.person,
                                    )),
                                hintText /*İpucu */ : "*****@gmail.com",
                                labelText: "Kullanıcı Email",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (oge) {
                                setState(() {
                                  _kullanici = oge;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            //Şifre
                            TextFormField(
                              obscureText: sifreGizle,
                              keyboardType: TextInputType.text,
                              validator: (oge) {
                                if (oge!.isEmpty) {
                                  return "Şifre boş olamaz";
                                } else if (oge.trim().length < 7) {
                                  return "Şifre 6 karakterden az olamaz";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: _sifreGoster,
                                  child: sifreGizle == true
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off),
                                ),
                                prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.key,
                                    )),
                                hintText /*İpucu */ : "*********",
                                labelText: "Şifre",
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (oge) {
                                setState(() {
                                  _sifre = oge;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 70, right: 00.0),
                              child: const Icon(
                                Icons.lock_clock_rounded,
                                color: Colors.tealAccent,
                                size: 34.0,
                              ),
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: RaisedButton(
                              highlightColor: Colors.lightBlueAccent[100],
                              onPressed: () {
                                if (girisButton) {
                                  girisYap();
                                }
                              },
                              textColor: Colors.white,
                              elevation: 20.0,
                              color: girisButton == false
                                  ? Colors.grey
                                  : Colors.blue,
                              child: const Text(
                                "Giriş Yap",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.blue,
                            margin: const EdgeInsets.only(left: 0, right: 100),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '$zaman',
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        color: Colors.cyan,
                        child: Text("Giriş Hakkınız: " + gsayac.toString(),
                            style: const TextStyle(
                                fontSize: 25.0, color: Colors.indigo)),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Container(
                          child: RaisedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        highlightColor: Colors.red[100],
                        elevation: 30.0,
                        color: Colors.red,
                        child: const Text(
                          "KAPAT",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void girisYap() async {
    try {
      UserCredential kullaciGirisi = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _kullanici, password: _sifre);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnaySayfasi()));
      CustomSnackBar().snackbar(context, 'Giriş başarılı.', 3);

      print(kullaciGirisi.user!.uid);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' && error.code == 'user-not-found') {
        gsayac--;
        CustomSnackBar()
            .snackbar(context, 'Kullanıcı Adı Ve Şifre Hatalı!!!', 3);
      }
      if (error.code == 'user-not-found') {
        gsayac--;
        CustomSnackBar().snackbar(context, 'Kullanıcı Adı Hatalı!!!', 3);
      }
      if (error.code == 'wrong-password') {
        gsayac--;
        CustomSnackBar().snackbar(context, 'Şifre Hatalı!!!', 3);
      }

      if (gsayac == 0) {
        girisButton = false;
        _timer.cancel();
        CustomSnackBar().snackbar(context, 'Giriş Hakkınız Dolmuştur!!!', 3);
      }
    } catch (e) {
      CustomSnackBar()
          .snackbar(context, 'Kullanıcı bilgileri boş bırakılamaz!!!', 3);
      // ignore: dead_code_catch_following_catch
    } catch (e) {
      CustomSnackBar().snackbar(
          context, 'Lütfen doğru bilgiler girdiğinizden emin olun!', 3);
    } catch (e) {
      CustomSnackBar().snackbar(
          context, 'Lütfen doğru bilgiler girdiğinizden emin olun!', 3);
    }
  }

  void _sifreGoster() async {
    setState(() {
      sifreGizle = !sifreGizle;
    });
  }
}
