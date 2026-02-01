import 'package:cloud_firestore/cloud_firestore.dart';

class OrderNumberGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate order number dengan format: ORD-YYYYMMDD-001
  /// Counter reset setiap hari (mulai dari 001 setiap hari baru)
  static Future<String> generate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Format tanggal: YYYYMMDD
    final dateStr = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    
    // Document ID berdasarkan tanggal
    final counterId = 'orders_$dateStr';
    final counterRef = _firestore.collection('counters').doc(counterId);

    try {
      // Gunakan transaction untuk atomic increment
      final result = await _firestore.runTransaction<int>(
        (transaction) async {
          final snapshot = await transaction.get(counterRef);

          // Get current number untuk hari ini
          int currentNumber = 0;
          if (snapshot.exists) {
            currentNumber = snapshot.data()?['lastNumber'] as int? ?? 0;
          }

          // Increment
          final newNumber = currentNumber + 1;

          // Update/Create counter untuk hari ini
          if (snapshot.exists) {
            transaction.update(counterRef, {
              'lastNumber': newNumber,
              'date': Timestamp.fromDate(today),
            });
          } else {
            // Buat document baru untuk hari ini (mulai dari 1)
            transaction.set(counterRef, {
              'lastNumber': newNumber,
              'date': Timestamp.fromDate(today),
            });
          }

          return newNumber;
        },
      );

      // Format order number: ORD-20250129-001
      final numberStr = result.toString().padLeft(3, '0');

      return 'ORD-$dateStr-$numberStr';
    } catch (e) {
      // Fallback jika transaction gagal
      print('Error generating order number: $e');
      
      // Hitung manual dari orders hari ini
      try {
        final snapshot = await _firestore
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
            .get();
        
        final todayCount = snapshot.docs.length + 1;
        final numberStr = todayCount.toString().padLeft(3, '0');
        
        return 'ORD-$dateStr-$numberStr';
      } catch (e2) {
        // Last fallback: timestamp
        final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
        return 'ORD-$dateStr-$timestamp';
      }
    }
  }

  /// Get current counter untuk hari ini (optional, untuk debug)
  static Future<int> getTodayNumber() async {
    final now = DateTime.now();
    final dateStr = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    
    final counterId = 'orders_$dateStr';
    final snapshot = await _firestore.collection('counters').doc(counterId).get();

    if (snapshot.exists) {
      return snapshot.data()?['lastNumber'] as int? ?? 0;
    }

    return 0;
  }

  /// Reset counter hari ini (optional, untuk testing)
  static Future<void> resetTodayCounter() async {
    final now = DateTime.now();
    final dateStr = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    
    final counterId = 'orders_$dateStr';
    await _firestore.collection('counters').doc(counterId).set({
      'lastNumber': 0,
      'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
    });
  }

  /// Cleanup old counters (optional, jalankan manual/scheduled)
  /// Hapus counter lebih dari 30 hari
  static Future<void> cleanupOldCounters() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final snapshot = await _firestore
        .collection('counters')
        .where('date', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();
    
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    
    print('Cleaned up ${snapshot.docs.length} old counters');
  }
}