import 'package:bankauygulamasi2/ana_sayfa.dart';
import 'package:bankauygulamasi2/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParaCek extends StatefulWidget {
  ParaCek({Key? key, required this.money}) : super(key: key);
  String money;

  @override
  State<ParaCek> createState() => _ParaCekState();
}

class _ParaCekState extends State<ParaCek> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String cekilenPara = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Para Çekme İşlemleri'),
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
                    cekilenPara = value;
                  },
                ),
                SizedBox(height: 50.0),
                ElevatedButton(
                    onPressed: () {
                      int para = int.parse(widget.money);
                      if (cekilenPara.isEmpty) {
                        CustomSnackBar().snackbar(
                            context,
                            'Lütfen Yatırmak İstadiğiniz Miktarı Gerekli Alanda Belirtiniz!',
                            3);
                      } else if (int.parse(cekilenPara) > para) {
                        CustomSnackBar()
                            .snackbar(context, 'Nakitinizi aştınız!!!', 3);
                      } else if (int.parse(cekilenPara) == 0) {
                        CustomSnackBar().snackbar(
                            context,
                            'Geçersiz İşlem Lütfen Nakit Miktarını Yükseltip Tekrar Deneyiniz.',
                            3);
                      } else if (int.parse(cekilenPara) % 5 != 0) {
                        CustomSnackBar().snackbar(
                            context,
                            'Yalnızca 5 veya 5 in katı için işlemler yapabilirsiniz!',
                            3);
                      } else if (cekilenPara.isNotEmpty &&
                          int.parse(cekilenPara) % 5 == 0) {
                        para -= int.parse(cekilenPara);

                        Map<String, dynamic> paraCekme = {};
                        paraCekme['islem tarihi'] = DateTime.now();
                        paraCekme['tutar'] = '-' + cekilenPara + " ₺";
                        paraCekme['açıklama'] = 'Para Çekme';
                        paraCekme['bakiye'] = para.toString();

                        _firestore
                            .collection('bankaUygulamasi')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('islemler')
                            .doc()
                            .set(paraCekme);

                        Map<String, dynamic> paraMiktariDegisim = {};
                        paraMiktariDegisim['toplamNakit'] = para.toString();
                        _firestore
                            .collection('bankaUygulamasi')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update(paraMiktariDegisim);

                        CustomSnackBar().snackbar(context,
                            'Hesabınızdan ${cekilenPara} ₺ çekilmiştir.', 3);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnaSayfa(),
                            ),
                            (route) => false);
                      }
                    },
                    child: Text('Para Çek'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
