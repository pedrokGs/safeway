import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/features/test_page.dart'; // ajuste o caminho conforme sua estrutura

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const TestPage(), // ou sua tela principal
    ),
    GoRoute(
      path: '/test',
      name: 'test',
      builder: (context, state) => const TestPage(),
    ),
  ],
);
