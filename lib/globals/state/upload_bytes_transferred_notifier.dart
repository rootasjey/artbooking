import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadBytesTransferredNotifier extends StateNotifier<int> {
  UploadBytesTransferredNotifier(int state) : super(state);

  void add(int amount) {
    state += amount;
  }

  void clear() {
    state = 0;
  }

  void remove(int amount) {
    state -= amount;
  }
}
