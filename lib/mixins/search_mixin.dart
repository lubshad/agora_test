import 'dart:async';

import 'package:flutter/material.dart';

mixin SearchMixin {
  Duration debouneDuration = const Duration(milliseconds: 300);
  Timer? debouncer;

  final searchController = TextEditingController();

  addSearchListener(VoidCallback search) {
    searchController.addListener(() {
      debouncer?.cancel();
      debouncer = Timer(debouneDuration, () {
        search();
      });
    });
  }

  removeSearchListener() {
    searchController.removeListener(() {});
    searchController.dispose();
  }
}
