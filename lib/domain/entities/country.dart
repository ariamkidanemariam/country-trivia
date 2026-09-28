class Country {
  final String name;
  final String alpha2Code;
  final String flagUrl;

  const Country({
    required this.name,
    required this.alpha2Code,
    required this.flagUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          alpha2Code == other.alpha2Code;

  @override
  int get hashCode => alpha2Code.hashCode;

  @override
  String toString() => 'Country(name: $name, alpha2Code: $alpha2Code)';
}
