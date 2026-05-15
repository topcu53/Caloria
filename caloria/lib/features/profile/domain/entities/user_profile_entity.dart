class UserProfileEntity {
  final String id;
  final String email;
  final String? displayName;
  final double? weight;
  final double? height;
  final int? age;
  final String? gender;
  final String? activityLevel;
  final String? goal;
  final double dailyCalorieGoal;
  final double dailyProteinGoal;
  final double dailyCarbsGoal;
  final double dailyFatGoal;
  final double dailyWaterGoal;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.activityLevel,
    this.goal,
    this.dailyCalorieGoal = 2000,
    this.dailyProteinGoal = 150,
    this.dailyCarbsGoal = 250,
    this.dailyFatGoal = 65,
    this.dailyWaterGoal = 2500,
  });

  UserProfileEntity copyWith({
    String? displayName,
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    double? dailyCalorieGoal,
    double? dailyProteinGoal,
    double? dailyCarbsGoal,
    double? dailyFatGoal,
    double? dailyWaterGoal,
  }) {
    return UserProfileEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatGoal': dailyFatGoal,
      'dailyWaterGoal': dailyWaterGoal,
    };
  }

  factory UserProfileEntity.fromMap(Map<String, dynamic> map) {
    return UserProfileEntity(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      age: map['age'],
      gender: map['gender'],
      activityLevel: map['activityLevel'],
      goal: map['goal'],
      dailyCalorieGoal: map['dailyCalorieGoal']?.toDouble() ?? 2000,
      dailyProteinGoal: map['dailyProteinGoal']?.toDouble() ?? 150,
      dailyCarbsGoal: map['dailyCarbsGoal']?.toDouble() ?? 250,
      dailyFatGoal: map['dailyFatGoal']?.toDouble() ?? 65,
      dailyWaterGoal: map['dailyWaterGoal']?.toDouble() ?? 2500,
    );
  }
}