class PetChatMessage {
  const PetChatMessage({
    required this.id,
    required this.text,
    required this.fromPet,
    required this.createdAt,
  });

  final String id;
  final String text;
  final bool fromPet;
  final DateTime createdAt;

  Map<String, Object> toJson() => {
    'id': id,
    'text': text,
    'fromPet': fromPet,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PetChatMessage.fromJson(Map<String, dynamic> json) => PetChatMessage(
    id:
        json['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    text: json['text'] as String? ?? '',
    fromPet: json['fromPet'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
