import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';

class RiskVisualizationScreen extends ConsumerStatefulWidget {
  const RiskVisualizationScreen({super.key});

  @override
  RiskVisualizationScreenState createState() => RiskVisualizationScreenState();
}

class RiskVisualizationScreenState extends ConsumerState<RiskVisualizationScreen> {
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Visualização de Riscos', style: Theme.of(context).textTheme.titleMedium,),
        centerTitle: true,
      ),
    );
  }
}