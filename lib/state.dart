import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

final searchControllerProvider =
    StateProvider<TextEditingController>((ref) => TextEditingController());

final searchResultProvider = StateProvider<OwlBotResponse>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String>((ref) => '');
