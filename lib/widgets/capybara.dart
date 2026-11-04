import 'package:flutter/material.dart';

import '../models/pet_mood.dart';

/// A capybara assembled from simple shapes keeps the toy self-contained.
class Capybara extends StatelessWidget {
  const Capybara({super.key, required this.mood});
  final PetMood mood;

  @override
  Widget build(BuildContext context) {
    final sleeping = mood == PetMood.sleeping;
    final playing = mood == PetMood.playing;
    final eating = mood == PetMood.eating;
    return SizedBox(
      width: 178,
      height: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 9,
            child: Container(
              width: 145,
              height: 19,
              decoration: BoxDecoration(
                color: const Color(0xFF9EB993).withValues(alpha: .5),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            bottom: 17,
            child: Container(
              width: 130,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFB9794F),
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: const Color(0xFF96603F), width: 3),
              ),
            ),
          ),
          Positioned(bottom: 18, left: 41, child: _foot()),
          Positioned(bottom: 18, right: 41, child: _foot()),
          Positioned(
            top: 40,
            child: Container(
              width: 119,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFC98D61),
                borderRadius: BorderRadius.circular(42),
                border: Border.all(color: const Color(0xFF96603F), width: 3),
              ),
            ),
          ),
          Positioned(top: 28, left: 43, child: _ear()),
          Positioned(top: 28, right: 43, child: _ear()),
          Positioned(top: 57, left: 56, child: _eye(sleeping)),
          Positioned(top: 57, right: 56, child: _eye(sleeping)),
          Positioned(
            top: 77,
            child: Container(
              width: 50,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE2B18A),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            top: 84,
            child: Container(
              width: 14,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF65493B),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          if (!sleeping)
            Positioned(
              top: 96,
              child: Container(
                width: 10,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF815044),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          if (sleeping) ...[
            const Positioned(
              top: 3,
              right: 16,
              child: Text(
                'Z z',
                style: TextStyle(
                  color: Color(0xFF718EBD),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          if (playing) ...[
            const Positioned(
              top: 27,
              left: 15,
              child: Icon(Icons.star, color: Color(0xFFF1C764), size: 19),
            ),
            const Positioned(
              top: 12,
              right: 18,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFE89383),
                size: 18,
              ),
            ),
          ],
          if (eating)
            const Positioned(
              bottom: 28,
              right: 21,
              child: Text(
                '♥',
                style: TextStyle(color: Color(0xFFE78683), fontSize: 21),
              ),
            ),
        ],
      ),
    );
  }

  Widget _eye(bool closed) => Container(
    width: 9,
    height: closed ? 3 : 10,
    decoration: BoxDecoration(
      color: const Color(0xFF43372E),
      borderRadius: BorderRadius.circular(6),
    ),
  );
  Widget _ear() => Container(
    width: 22,
    height: 24,
    decoration: BoxDecoration(
      color: const Color(0xFFB9794F),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF96603F), width: 3),
    ),
  );
  Widget _foot() => Container(
    width: 28,
    height: 15,
    decoration: BoxDecoration(
      color: const Color(0xFFAD704B),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF96603F), width: 2),
    ),
  );
}
