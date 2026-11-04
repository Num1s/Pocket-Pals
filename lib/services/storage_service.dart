import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_state.dart';

/// Small persistence boundary; the notifier does not know storage details.
class StorageService {
  StorageService([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _stateKey = 'capy_pal.pet_state.v1';
  final SharedPreferencesAsync _preferences;

  Future<PetState?> loadPet() async {
    final raw = await _preferences.getString(_stateKey);
    if (raw == null) return null;
    try {
      return PetState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      await _preferences.remove(_stateKey);
      return null;
    } on TypeError {
      await _preferences.remove(_stateKey);
      return null;
    }
  }

  Future<void> savePet(PetState pet) =>
      _preferences.setString(_stateKey, jsonEncode(pet.toJson()));
}
