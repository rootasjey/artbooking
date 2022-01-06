import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowUploadWindowNotifier extends StateNotifier<bool> {
  ShowUploadWindowNotifier(bool state) : super(state);

  void setVisibility(bool show) {
    state = show;
  }
}
