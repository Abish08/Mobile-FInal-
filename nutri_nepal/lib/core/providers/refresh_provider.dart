import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final refreshProvider = NotifierProvider<RefreshNotifier, int>(
  RefreshNotifier.new,
);
