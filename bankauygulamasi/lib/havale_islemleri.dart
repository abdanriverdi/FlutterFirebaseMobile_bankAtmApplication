import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HavaleIslemleri extends StatefulWidget {
  HavaleIslemleri({Key? key, required this.userData}) : super(key: key);

  Map<String, dynamic> userData;
  @override
  State<HavaleIslemleri> createState() => _HavaleIslemleriState();
}

class _HavaleIslemleriState extends State<HavaleIslemleri> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _hesapNo = TextEditingController();
  TextEditingController _paraMiktari = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Havale İşlemleri'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 70,
                ),
                TextField(
                  controller: _hesapNo,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hesap No',
                    hintText: 'Hesap No Giriniz',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 6,
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _paraMiktari,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'miktar',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  maxLength: 7,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      int userMoney = int.parse(widget.userData['toplamNakit']);
                      String _bankaAdi = widget.userData['BankaAdi'];

                      Map<String, dynamic> _sonuc = {};
                      String docID = '';
                      await _firestore
                          .collection('bankaUygulamasi')
                          .where('hesapNo', isEqualTo: _hesapNo.text)
                          .get()
                          .then((qs) {
                        for (var item in qs.docs) {
                          docID = item.id;
                          _sonuc = item.data();
                        }
                      });
                      if (_hesapNo.text == widget.userData['hesapNo']) {
                        CustomSnackBar().snackbar(
                            context,
                            'Kendi hesabınızdan aynı hesaba havale işlemi gerçekleştirmeye çalışıyorsunuz!!!',
                            5);
                      } else {
                        if (int.parse(_sonuc['toplamNakit']) +
                                int.parse(_paraMiktari.text) >
                            6000) {
                          CustomSnackBar().snackbar(
                              context,
                              'Alıcının nakit miktarı 6000 i aşmakta olacağı için işleminizi gerçekleştiremiyoruz!\nLütfen göndermek istediğiniz miktarı azaltarak işlemi tekrar deneyiniz.',
                              6);
                        } else {
                          if (_bankaAdi == _sonuc['BankaAdi']) {
                            if (_paraMiktari.text.isEmpty) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Lütfen Yollamak İstadiğiniz Miktarı Gerekli Alanda Belirtiniz!',
                                  3);
                            } else if (int.parse(_paraMiktari.text) % 5 != 0) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Yalnızca 5 veya 5 in katı için işlemler yapabilirsiniz!',
                                  3);
                            } else {
                              if (_paraMiktari.text.compareTo(
                                      widget.userData['toplamNakit']) <=
                                  0) {
                                userMoney -= int.parse(_paraMiktari.text);

                                Map<String, dynamic> havaleIslemi = {};
                                havaleIslemi['islem tarihi'] = DateTime.now();
                                havaleIslemi['tutar'] =
                                    '-' + _paraMiktari.text + " ₺";
                                havaleIslemi['açıklama'] = 'Havale';
                                havaleIslemi['bakiye'] = userMoney.toString();

                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('islemler')
                                    .doc()
                                    .set(havaleIslemi);

                                Map<String, dynamic> paraMiktariDegisim = {};
                                paraMiktariDegisim['toplamNakit'] =
                                    userMoney.toString();
                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update(paraMiktariDegisim);

                                Map<String, dynamic> paraMiktariDegisimAlici =
                                    {}; // alıcının
                                paraMiktariDegisimAlici['toplamNakit'] =
                                    (int.parse(_sonuc['toplamNakit']) +
                                            int.parse(_paraMiktari.text))
                                        .toString();
                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(docID)
                                    .update(paraMiktariDegisimAlici);

                                Map<String, dynamic> gelenHavale = {};
                                gelenHavale['islem tarihi'] = DateTime.now();
                                gelenHavale['tutar'] =
                                    '+' + _paraMiktari.text + " ₺";
                                gelenHavale['açıklama'] = 'Havale';
                                gelenHavale['bakiye'] =
                                    paraMiktariDegisimAlici['toplamNakit']
                                        .toString();
                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(docID)
                                    .collection('islemler')
                                    .doc()
                                    .set(gelenHavale);

                                CustomSnackBar().snackbar(
                                    context,
                                    'Hesabınızdan ${_hesapNo.text} Nolu Hesaba\n${_paraMiktari.text} ₺ Havale Gerçekleşmiştir.',
                                    5);

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnaSayfa(),
                                    ),
                                    (route) => false);
                              } else {
                                CustomSnackBar().snackbar(context,
                                    'Hesabınızdaki nakit miktarını aştınız', 3);
                              }
                            }
                          } else {
                            CustomSnackBar().snackbar(
                                context, 'Havale işlemi başarısız', 3);
                          }
                        }
                      }
                    } catch (e) {
                      CustomSnackBar().snackbar(
                          context,
                          'Hata!!!\nLütfen bilgileri tekrar kontrol ediniz.',
                          3);
                    }
                  },
                  child: Text('İşlemi Onayla'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
