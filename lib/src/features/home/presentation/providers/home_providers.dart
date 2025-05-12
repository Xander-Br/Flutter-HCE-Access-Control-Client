import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeCounterProvider = StateProvider<int>((ref) => 0);


final greetingProvider = Provider<String>((ref) {
  return 'Welcome to the Boilerplate!';
});