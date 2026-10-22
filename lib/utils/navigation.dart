import 'package:flutter/material.dart';

void go(BuildContext c, Widget page) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => page));

/// Replaces the whole navigation stack (used after login / logout).
void goRoot(BuildContext c, Widget page) => Navigator.of(c)
    .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => page), (_) => false);
