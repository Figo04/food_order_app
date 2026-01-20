import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/data/models/home_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final homeProvider = StreamProvider<HomeModel>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('orders').snapshots().map((snapshot) {
    double totalPendapatan = 0;
    int totalTransaksi = 0;
    int pesananMasuk = 0;
    int dalamProses = 0;
    int selesai = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final total = data['total'] as num? ?? 0;
      final status = data['status'] as String? ?? '';

      totalPendapatan += total.toDouble();
      totalTransaksi++;

      if (status == 'pending') {
        pesananMasuk++;
      } else if (status == 'in_progress') {
        dalamProses++;
      } else if (status == 'completed') {
        selesai++;
      }
    }

    final totalPesanan = snapshot.docs.length;
    double persentase = 0;

    if (totalPesanan > 0) {
      int kemarin = 8;
      if (kemarin > 0) {
        persentase = ((selesai - kemarin) / kemarin) * 100;
      } else {
        persentase = selesai > 0 ? 100 : 0;
      }
    }

    final result = HomeModel(
      pendapatanHariIni: totalPendapatan,
      jumlahTransaksi: totalTransaksi,
      pesananMasuk: pesananMasuk,
      dalamProses: dalamProses,
      selesai: selesai,
      persentaseSelesai: persentase.clamp(-100, 1000),
    );

    return result;
  });
});
