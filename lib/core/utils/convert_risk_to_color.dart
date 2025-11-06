import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';

Color alertRiskToColor(AlertRisk risk){
  switch (risk){
    case AlertRisk.baixo:
      return Colors.yellow;
    case AlertRisk.medio:
      return Colors.orange;
    case AlertRisk.alto:
      return Colors.redAccent;
    case AlertRisk.critico:
      return Colors.purple;
  }
}