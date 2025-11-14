import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  HelpScreenState createState() => HelpScreenState();
}

class HelpScreenState extends ConsumerState<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
    );
  }
}
