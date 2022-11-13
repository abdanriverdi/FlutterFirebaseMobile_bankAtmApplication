import 'package:bankauygulamasi2/database_db.dart';
import 'package:bankauygulamasi2/islem_gecmisi.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:bankauygulamasi2/eft_islemleri.dart';
import 'package:bankauygulamasi2/havale_islemleri.dart';
import 'package:bankauygulamasi2/para_cek.dart';
import 'package:bankauygulamasi2/para_yatir.dart';
import 'package:intl/intl.dart';

class AnaSayfa extends StatefulWidget {
  AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late int sayi;

  late Future<Map<String, dynamic>> futUserData;
  @override
  void initState() {
    super.initState();
    futUserData = DataBaseGets().getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: futUserData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(26, 29, 33, 1),
            body: Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 25),
                  Stack(
                    children: <Widget>[
                      Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.identity()..rotateZ(-15 * 3.1415927 / 180),
                        child: Container(
                          height: 210,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.25), borderRadius: BorderRadius.circular(38)),
                        ),
                      ),
                      Container(
                        height: 210,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.25), borderRadius: BorderRadius.circular(38)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //MasterCard Icon
                            SizedBox(
                              width: 30,
                              child: Stack(
                                children: <Widget>[
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.yellow,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text('mastercart', style: TextStyle(color: Colors.grey)),
                            Text('${snapshot.data!['BankaAdi']}',
                                style: const TextStyle(fontSize: 20, color: Colors.blue)),
                            const SizedBox(height: 10),
                            Text('Sayın: ${snapshot.data!['isim']}',
                                style: const TextStyle(color: Colors.grey, fontSize: 17)),
                            const SizedBox(height: 10),
                            Text('Bakiye: ${snapshot.data!['toplamNakit']} ₺',
                                style: const TextStyle(color: Colors.grey, fontSize: 15)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text('Hesap No: ${snapshot.data!['hesapNo']}',
                                        style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                                Column(
                                  children: const [
                                    Text('Exp date', style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 3),
                                    Text('25/5'),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                if (snapshot.data!['toplamNakit'] != '6000') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParaYatir(money: snapshot.data!['toplamNakit']),
                                      )).then(((value) {
                                    setState(() {
                                      futUserData;
                                    });
                                  }));
                                } else {
                                  CustomSnackBar().snackbar(context, 'Nakitiniz maximum seviyede!', 4);
                                }
                              },
                              child: const Text(
                                "Para Yatır=>",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 19.0),
                          child: const Icon(
                            Icons.money,
                            color: Color.fromARGB(255, 0, 2, 1),
                            size: 37.0,
                          ),
                          color: const Color.fromARGB(255, 226, 242, 255),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 19.0),
                          child: const Icon(
                            Icons.money,
                            color: Color.fromARGB(255, 0, 2, 1),
                            size: 37.0,
                          ),
                          color: const Color.fromARGB(255, 226, 242, 255),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                if (snapshot.data!['toplamNakit'] != '0') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParaCek(money: snapshot.data!['toplamNakit']),
                                      )).then(((value) {
                                    setState(() {
                                      futUserData;
                                    });
                                  }));
                                } else {
                                  CustomSnackBar()
                                      .snackbar(context, 'Çekebileceğiniz Nakit Miktari Bulunmamaktatır!', 4);
                                }
                              },
                              child: const Text(
                                "=>Para Çek",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HavaleIslemleri(
                                        userData: snapshot.data!,
                                      ),
                                    )).then(((value) {
                                  setState(() {
                                    futUserData;
                                  });
                                }));
                              },
                              child: const Text(
                                "Havale",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            color: Color.fromARGB(255, 0, 2, 1),
                            size: 37.0,
                          ),
                          color: const Color.fromARGB(255, 226, 242, 255),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 19.0),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Color.fromARGB(255, 0, 2, 1),
                            size: 37.0,
                          ),
                          color: const Color.fromARGB(255, 226, 242, 255),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EftIslemleri(
                                        userData: snapshot.data!,
                                      ),
                                    )).then(((value) {
                                  setState(() {
                                    futUserData;
                                  });
                                }));
                              },
                              child: const Text(
                                "EFT",
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IslemGecmisi(),
                                  ));
                            },
                            child: const Text(
                              "İşlem Özeti",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
