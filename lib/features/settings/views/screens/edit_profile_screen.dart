import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}