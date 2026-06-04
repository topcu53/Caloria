class WeightLogEntity {
  final String dateKey;
  final double weightKg;
  final DateTime recordedAt;

  const WeightLogEntity({
    required this.dateKey,
    required this.weightKg,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'weightKg': weightKg,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory WeightLogEntity.fromMap(String dateKey, Map<String, dynamic> map) {
    return WeightLogEntity(
      dateKey: dateKey,
      weightKg: (map['weightKg'] as num).toDouble(),
      recordedAt: DateTime.parse(map['recordedAt'] as String),
    );
  }
}
