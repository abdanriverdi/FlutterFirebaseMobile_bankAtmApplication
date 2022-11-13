// ignore_for_file: deprecated_member_use, file_name

import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParaYatir extends StatefulWidget {
  ParaYatir({Key? key, required this.money}) : super(key: key);

  String money;
  @override
  State<ParaYatir> createState() => _ParaYatirState();
}

class _ParaYatirState extends State<ParaYatir> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String yatirilanPara = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Para Yatırma İşlemleri'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            child: ListView(
              children: [
                SizedBox(height: 150.0),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'para miktarı',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (value) {
                    yatirilanPara = value;
                  },
                ),
                SizedBox(height: 50.0),
                ElevatedButton(
                    onPressed: () {
                      int para = int.parse(widget.money);
                      if (yatirilanPara.isEmpty) {
                        CustomSnackBar().snackbar(
                            context,
                            'Lütfen Yatırmak İstadiğiniz Miktarı Gerekli Alanda Belirtiniz!',
                            3);
                      } else if (para + int.parse(yatirilanPara) > 6000) {
                        CustomSnackBar().snackbar(
                            context, 'Bakiyeniz Max 6000 aşamaz!!!', 3);
                      } else if (int.parse(yatirilanPara) == 0) {
                        CustomSnackBar().snackbar(
                            context,
                            'Geçersiz İşlem Lütfen Nakit Miktarını Yükseltip Tekrar Deneyiniz.',
                            3);
                      } else if (int.parse(yatirilanPara) % 5 != 0) {
                        CustomSnackBar().snackbar(
                            context,
                            'Yalnızca 5 veya 5 in katı için işlemler yapabilirsiniz!',
                            3);
                      } else if (yatirilanPara.isNotEmpty &&
                          int.parse(yatirilanPara) % 5 == 0) {
                        para += int.parse(yatirilanPara);

                        Map<String, dynamic> paraYatirma = {};
                        paraYatirma['islem tarihi'] = DateTime.now();
                        paraYatirma['tutar'] = '+' + yatirilanPara + " ₺";
                        paraYatirma['açıklama'] = 'Para Yatırma';
                        paraYatirma['bakiye'] = para.toString();
                        _firestore
                            .collection('bankaUygulamasi')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('islemler')
                            .doc()
                            .set(paraYatirma);

                        Map<String, dynamic> paraMiktariDegisim = {};
                        paraMiktariDegisim['toplamNakit'] = para.toString();
                        _firestore
                            .collection('bankaUygulamasi')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update(paraMiktariDegisim);

                        CustomSnackBar().snackbar(context,
                            'Hesabınıza ${yatirilanPara} ₺ yatmıştır.', 3);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnaSayfa(),
                            ),
                            (route) => false);
                      }
                    },
                    child: Text('para yatır'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
