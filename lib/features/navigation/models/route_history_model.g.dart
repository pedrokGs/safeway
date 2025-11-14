// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteHistoryModelAdapter extends TypeAdapter<RouteHistoryModel> {
  @override
  final int typeId = 1;

  @override
  RouteHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouteHistoryModel(
      routePoints: (fields[0] as List).cast<LatLng>(),
      etaSeconds: fields[1] as double,
      transportMode: fields[2] as String,
      createdAt: fields[3] as DateTime,
      origem: fields[4] as String,
      destino: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RouteHistoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.routePoints)
      ..writeByte(1)
      ..write(obj.etaSeconds)
      ..writeByte(2)
      ..write(obj.transportMode)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.origem)
      ..writeByte(5)
      ..write(obj.destino);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
