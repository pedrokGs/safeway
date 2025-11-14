// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => AlertModel(
      uid: json['uid'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      tipo: $enumDecode(_$AlertTypeEnumMap, json['tipo']),
      risco: $enumDecode(_$AlertRiskEnumMap, json['risco']),
      data: const TimestampConverter().fromJson(json['data'] as Object),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$AlertModelToJson(AlertModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'tipo': _$AlertTypeEnumMap[instance.tipo]!,
      'risco': _$AlertRiskEnumMap[instance.risco]!,
      'data': const TimestampConverter().toJson(instance.data),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'userId': instance.userId,
    };

const _$AlertTypeEnumMap = {
  AlertType.crime: 'crime',
  AlertType.acidente: 'acidente',
  AlertType.incendio: 'incendio',
  AlertType.deslizamento: 'deslizamento',
  AlertType.enchente: 'enchente',
  AlertType.outro: 'outro',
};

const _$AlertRiskEnumMap = {
  AlertRisk.baixo: 'baixo',
  AlertRisk.medio: 'medio',
  AlertRisk.alto: 'alto',
  AlertRisk.critico: 'critico',
};
