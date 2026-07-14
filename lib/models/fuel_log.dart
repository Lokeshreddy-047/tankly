class FuelLog {
  final int? id;
  final double? odometer;
  final double? litres;
  final double? pricePerLitre;
  final double totalAmount;
  final String date;
  final bool isFullTank; // NEW: Tracks partial vs full fills

  FuelLog({
    this.id,
    this.odometer,
    this.litres,
    this.pricePerLitre,
    required this.totalAmount,
    required this.date,
    this.isFullTank = true, // Defaults to true
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'odometer': odometer,
      'litres': litres,
      'pricePerLitre': pricePerLitre,
      'totalAmount': totalAmount,
      'date': date,
      'isFullTank': isFullTank ? 1 : 0, // Convert bool to int for SQLite
    };
  }

  factory FuelLog.fromMap(Map<String, dynamic> map) {
    return FuelLog(
      id: map['id'],
      odometer: map['odometer'],
      litres: map['litres'],
      pricePerLitre: map['pricePerLitre'],
      totalAmount: map['totalAmount'],
      date: map['date'],
      isFullTank: map['isFullTank'] == 1, // Convert int back to bool
    );
  }
}