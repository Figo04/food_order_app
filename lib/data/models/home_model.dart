class HomeModel {
  final double pendapatanHariIni;
  final int jumlahTransaksi;
  final int pesananMasuk;
  final int dalamProses;
  final int selesai;
  final double persentaseSelesai;

  HomeModel({
    required this.pendapatanHariIni,
    required this.jumlahTransaksi,
    required this.pesananMasuk,
    required this.dalamProses,
    required this.selesai,
    required this.persentaseSelesai,
  });

  factory HomeModel.empty() {
    return HomeModel(
      pendapatanHariIni: 0,
      jumlahTransaksi: 0,
      pesananMasuk: 0,
      dalamProses: 0,
      selesai: 0,
      persentaseSelesai: 0,
    );
  }
}