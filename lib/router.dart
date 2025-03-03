import 'package:flutter/material.dart';
import 'package:utang_core/screen/add_debt_screen.dart';
import 'package:utang_core/screen/home_screen.dart';
import 'package:utang_core/screen/auth/register_screen.dart';

Map<String, WidgetBuilder> routes = {
  // "/": (context) => LoginScreen(),
  "/home": (context) => const HomeScreen(),
  "/register": (context) => const RegisterScreen(),
  "/add-debt": (context) => AddDebtScreen()
};
