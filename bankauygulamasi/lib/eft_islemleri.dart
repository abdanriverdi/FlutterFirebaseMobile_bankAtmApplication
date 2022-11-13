import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EftIslemleri extends StatefulWidget {
  EftIslemleri({Key? key, required this.userData}) : super(key: key);

  Map<String, dynamic> userData;
  @override
  State<EftIslemleri> createState() => _EftIslemleriState();
}

int _radioButon = 1;
String _bankaSec = 'Banka Seç';
String ibanUlkeKodu = '';

class _EftIslemleriState extends State<EftIslemleri> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _hesapNo_ibanNo = TextEditingController();
  TextEditingController _paraMiktari = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EFT İşlemleri'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Hesap No',
                        style:
                            TextStyle(fontSize: 20, color: Colors.deepPurple),
                      ),
                      Radio<int>(
                          value: 1,
                          groupValue: _radioButon,
                          onChanged: (value) {
                            setState(() {
                              _radioButon = value!;
                              ibanUlkeKodu = '';
                            });
                          }),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'İban',
                        style:
                            TextStyle(fontSize: 20, color: Colors.deepPurple),
                      ),
                      Radio<int>(
                          value: 2,
                          groupValue: _radioButon,
                          onChanged: (value) {
                            setState(() {
                              _radioButon = value!;
                              ibanUlkeKodu = 'TR-';
                            });
                          }),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: [
                    DropdownButton<String>(
                        value: _bankaSec,
                        icon: const Icon(Icons.arrow_drop_down_outlined),
                        elevation: 16,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 137, 58, 183),
                            fontSize: 18),
                        underline: Container(
                          height: 2,
                          color: Color.fromARGB(255, 240, 4, 248),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _bankaSec = newValue!;
                          });
                        },
                        items: <String>[
                          'Banka Seç',
                          'Yapı Kredi',
                          'VakıfBank',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList())
                  ],
                )),
              ],
            ),
            const SizedBox(height: 90),
            TextField(
              controller: _hesapNo_ibanNo,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefix: Text(ibanUlkeKodu),
                prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 174, 0, 255),
                    fontSize: 15),
                hintText: ' Bilgileri Giriniz',
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: 12,
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

                  if (_radioButon == 2) {
                    await _firestore
                        .collection('bankaUygulamasi')
                        .where('iban', isEqualTo: _hesapNo_ibanNo.text)
                        .get()
                        .then((qs) {
                      for (var item in qs.docs) {
                        docID = item.id;
                        _sonuc = item.data();
                      }
                    });
                    if (_hesapNo_ibanNo.text.isEmpty) {
                      CustomSnackBar().snackbar(context,
                          'Lütfen İban numarasını boş bırakmayınız', 2);
                    } else if (_bankaSec == "Banka Seç") {
                      CustomSnackBar().snackbar(
                          context, 'Eft İşlemi için Lütfen Banka seçiniz!', 2);
                    } else if (_bankaSec != _sonuc['BankaAdi']) {
                      CustomSnackBar().snackbar(
                          context,
                          'Lütfen Banka seçiminizi veya iban numarasını tekrar kontrol ediniz!',
                          4);
                    } else {
                      if (_bankaSec == _sonuc['BankaAdi']) {
                        if (_hesapNo_ibanNo.text == widget.userData['iban']) {
                          CustomSnackBar().snackbar(
                              context,
                              'Kendi hesabınızdan aynı hesaba işlem gerçekleştirmeye çalışıyorsunuz!!!',
                              5);
                        } else {
                          if (_hesapNo_ibanNo.text == _sonuc['iban']) {
                            if (_paraMiktari.text.isEmpty) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Lütfen Yollamak İstadiğiniz Miktarı Gerekli Alanda Belirtiniz!',
                                  3);
                            } else if (int.parse(_paraMiktari.text) == 0) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Geçersiz İşlem Lütfen Nakit Miktarını Yükseltip Tekrar Deneyiniz.',
                                  4);
                            } else if (int.parse(_paraMiktari.text) % 5 != 0) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Yalnızca 5 veya 5 in katı için işlemler yapabilirsiniz!',
                                  3);
                            } else if (int.parse(_sonuc['toplamNakit']) +
                                    int.parse(_paraMiktari.text) >
                                6000) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Alıcının nakit miktarı 6000 i aşmakta olacağı için işleminizi gerçekleştiremiyoruz!\nLütfen göndermek istediğiniz miktarı azaltarak işlemi tekrar deneyiniz.',
                                  6);
                            } else {
                              if (_paraMiktari.text.compareTo(
                                      widget.userData['toplamNakit']) <=
                                  0) {
                                userMoney -= int.parse(_paraMiktari.text);

                                Map<String, dynamic> eftIslemi = {};
                                eftIslemi['islem tarihi'] = DateTime.now();
                                eftIslemi['tutar'] =
                                    '-' + _paraMiktari.text + " ₺";
                                eftIslemi['açıklama'] = 'EFT';
                                eftIslemi['bakiye'] = userMoney.toString();

                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('islemler')
                                    .doc()
                                    .set(eftIslemi);

                                Map<String, dynamic> paraMiktariDegisim =
                                    {}; // gonderenin para mik. değişim
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

                                Map<String, dynamic> gelenEft = {};
                                gelenEft['islem tarihi'] = DateTime.now();
                                gelenEft['tutar'] =
                                    '+' + _paraMiktari.text + " ₺";
                                gelenEft['açıklama'] = 'EFT';
                                gelenEft['bakiye'] =
                                    paraMiktariDegisimAlici['toplamNakit']
                                        .toString();
                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(docID)
                                    .collection('islemler')
                                    .doc()
                                    .set(gelenEft);

                                CustomSnackBar().snackbar(
                                    context,
                                    'Hesabınızdan ${_hesapNo_ibanNo.text} Nolu Hesaba\n${_paraMiktari.text} ₺ EFT Gerçekleşmiştir.',
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
                                context,
                                'Lütfen İban numarasını tekrar kontrol ediniz!',
                                3);
                          }
                        }
                      }
                    }
                  }
                  // #####################################-----Hesap No İle------#################################################################
                  if (_radioButon == 1) {
                    await _firestore
                        .collection('bankaUygulamasi')
                        .where('hesapNo', isEqualTo: _hesapNo_ibanNo.text)
                        .get()
                        .then((qs) {
                      for (var item in qs.docs) {
                        docID = item.id;
                        _sonuc = item.data();
                      }
                    });
                    if (_hesapNo_ibanNo.text.isEmpty) {
                      CustomSnackBar().snackbar(context,
                          'Lütfen hesap numarasını boş bırakmayınız', 2);
                    } else if (_bankaSec == "Banka Seç") {
                      CustomSnackBar().snackbar(
                          context, 'Eft İşlemi için Lütfen Banka seçiniz!', 2);
                    } else if (_bankaSec != _sonuc['BankaAdi']) {
                      CustomSnackBar().snackbar(
                          context,
                          'Lütfen Banka seçiminizi veya hesap numarasını tekrar kontrol ediniz!',
                          4);
                    } else {
                      if (_bankaSec == _sonuc['BankaAdi']) {
                        if (_hesapNo_ibanNo.text ==
                            widget.userData['hesapNo']) {
                          CustomSnackBar().snackbar(
                              context,
                              'Kendi hesabınızdan aynı hesaba işlem gerçekleştirmeye çalışıyorsunuz!!!',
                              5);
                        } else {
                          if (_hesapNo_ibanNo.text == _sonuc['hesapNo']) {
                            if (_paraMiktari.text.isEmpty) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Lütfen Yollamak İstadiğiniz Miktarı Gerekli Alanda Belirtiniz!',
                                  3);
                            } else if (int.parse(_paraMiktari.text) == 0) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Geçersiz İşlem Lütfen Nakit Miktarını Yükseltip Tekrar Deneyiniz.',
                                  4);
                            } else if (int.parse(_paraMiktari.text) % 5 != 0) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Yalnızca 5 veya 5 in katı için işlemler yapabilirsiniz!',
                                  3);
                            } else if (int.parse(_sonuc['toplamNakit']) +
                                    int.parse(_paraMiktari.text) >
                                6000) {
                              CustomSnackBar().snackbar(
                                  context,
                                  'Alıcının nakit miktarı 6000 i aşmakta olacağı için işleminizi gerçekleştiremiyoruz!\nLütfen göndermek istediğiniz miktarı azaltarak işlemi tekrar deneyiniz.',
                                  6);
                            } else {
                              if (_paraMiktari.text.compareTo(
                                      widget.userData['toplamNakit']) <=
                                  0) {
                                userMoney -= int.parse(_paraMiktari.text);

                                Map<String, dynamic> eftIslemi = {};
                                eftIslemi['islem tarihi'] = DateTime.now();
                                eftIslemi['tutar'] =
                                    '-' + _paraMiktari.text + " ₺";
                                eftIslemi['açıklama'] = 'EFT';
                                eftIslemi['bakiye'] = userMoney.toString();

                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('islemler')
                                    .doc()
                                    .set(eftIslemi);

                                Map<String, dynamic> paraMiktariDegisim =
                                    {}; // gonderenin para mik. değişim
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

                                Map<String, dynamic> gelenEft = {};
                                gelenEft['islem tarihi'] = DateTime.now();
                                gelenEft['tutar'] =
                                    '+' + _paraMiktari.text + " ₺";
                                gelenEft['açıklama'] = 'EFT';
                                gelenEft['bakiye'] =
                                    paraMiktariDegisimAlici['toplamNakit']
                                        .toString();
                                await _firestore
                                    .collection('bankaUygulamasi')
                                    .doc(docID)
                                    .collection('islemler')
                                    .doc()
                                    .set(gelenEft);

                                CustomSnackBar().snackbar(
                                    context,
                                    'Hesabınızdan ${_hesapNo_ibanNo.text} Nolu Hesaba\n${_paraMiktari.text} ₺ EFT Gerçekleşmiştir.',
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
                                context,
                                'Lütfen hesap numarasını tekrar kontrol ediniz!',
                                3);
                          }
                        }
                      }
                    }
                  }
                } catch (e) {
                  CustomSnackBar().snackbar(context,
                      'Hata!!!\nLütfen bilgileri tekrar kontrol ediniz.', 3);
                }
              },
              child: const Text('İşlemi Onayla'),
            )
          ],
        ),
      ),
    );
  }
}
