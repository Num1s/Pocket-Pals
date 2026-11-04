import '../models/pet_catalog.dart';
import '../models/pet_mood.dart';

/// Offline conversation for the demo. Replace this adapter with a secured
/// server-backed AI implementation when an endpoint is available.
class ChatService {
  String reply({
    required PetSpecies species,
    required String petName,
    required PetMood mood,
    required String message,
  }) {
    final text = message.toLowerCase();
    if (_containsAny(text, ['hello', 'hi', 'hey', 'привет', 'здравствуй'])) {
      return 'Hi! I’m $petName 🐾 I’m so glad you came to say hello.';
    }
    if (_containsAny(text, ['love', 'miss', 'люб', 'скуч'])) {
      return 'Aww, I love spending time with you too 💛';
    }
    if (_containsAny(text, ['food', 'hungry', 'eat', 'еда', 'голод'])) {
      return mood == PetMood.eating
          ? 'That snack was delicious! Do you have another one?'
          : 'My tummy is ready for a little treat 🌾';
    }
    if (_containsAny(text, ['play', 'игр', 'fun', 'весел'])) {
      return 'Yes, let’s play! I’ll bring my favourite toy 🎾';
    }
    if (_containsAny(text, ['sleep', 'tired', 'сон', 'устал'])) {
      return 'A tiny nap sounds perfect. Stay close while I dream ☁️';
    }
    if (_containsAny(text, ['sad', 'bad', 'груст', 'плохо'])) {
      return 'I’m right here with you. We can take a slow, cozy breath together 🌿';
    }
    final replies = switch (species.id) {
      'cat' => [
        'I found a very important sunbeam today ☀️',
        'I’m thinking about snacks. You too? 🐟',
        'Purrhaps we should explore the room!',
      ],
      'dog' => [
        'You’re my favourite adventure buddy! 🐾',
        'I would fetch that for you… probably! 🎾',
        'Every day is better when we hang out.',
      ],
      'bunny' => [
        'I did three happy hops just for you! 🥕',
        'The garden smells extra sweet today 🌷',
        'Can we make a cozy little burrow?',
      ],
      'fox' => [
        'I spotted a sparkling leaf on my walk 🍂',
        'Secret forest mission? I’m ready! 🦊',
        'You always know how to brighten my den.',
      ],
      _ => [
        'I’m having the coziest day with you 🌿',
        'Want to watch the clouds drift by together? ☁️',
        'I saved you my best little smile 🧡',
      ],
    };
    return replies[message.codeUnits.fold<int>(0, (sum, code) => sum + code) %
        replies.length];
  }

  bool _containsAny(String source, List<String> words) =>
      words.any(source.contains);
}
