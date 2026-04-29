class User {
  const User({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  // Additional fields will be added based on backend specifications.
}
