// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductosTableTable extends ProductosTable
    with TableInfo<$ProductosTableTable, ProductosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codigoBarrasMeta =
      const VerificationMeta('codigoBarras');
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
      'codigo_barras', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreComercialMeta =
      const VerificationMeta('nombreComercial');
  @override
  late final GeneratedColumn<String> nombreComercial = GeneratedColumn<String>(
      'nombre_comercial', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _principioActivoMeta =
      const VerificationMeta('principioActivo');
  @override
  late final GeneratedColumn<String> principioActivo = GeneratedColumn<String>(
      'principio_activo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _concentracionMeta =
      const VerificationMeta('concentracion');
  @override
  late final GeneratedColumn<String> concentracion = GeneratedColumn<String>(
      'concentracion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _laboratorioIdMeta =
      const VerificationMeta('laboratorioId');
  @override
  late final GeneratedColumn<int> laboratorioId = GeneratedColumn<int>(
      'laboratorio_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
      'categoria_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _requiereRecetaMeta =
      const VerificationMeta('requiereReceta');
  @override
  late final GeneratedColumn<bool> requiereReceta = GeneratedColumn<bool>(
      'requiere_receta', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requiere_receta" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _esPsicotropicoMeta =
      const VerificationMeta('esPsicotropico');
  @override
  late final GeneratedColumn<bool> esPsicotropico = GeneratedColumn<bool>(
      'es_psicotropico', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_psicotropico" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _esAntibioticoMeta =
      const VerificationMeta('esAntibiotico');
  @override
  late final GeneratedColumn<bool> esAntibiotico = GeneratedColumn<bool>(
      'es_antibiotico', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_antibiotico" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('activo'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        codigoBarras,
        nombreComercial,
        principioActivo,
        concentracion,
        laboratorioId,
        categoriaId,
        requiereReceta,
        esPsicotropico,
        esAntibiotico,
        estado,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(Insertable<ProductosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
          _codigoBarrasMeta,
          codigoBarras.isAcceptableOrUnknown(
              data['codigo_barras']!, _codigoBarrasMeta));
    }
    if (data.containsKey('nombre_comercial')) {
      context.handle(
          _nombreComercialMeta,
          nombreComercial.isAcceptableOrUnknown(
              data['nombre_comercial']!, _nombreComercialMeta));
    } else if (isInserting) {
      context.missing(_nombreComercialMeta);
    }
    if (data.containsKey('principio_activo')) {
      context.handle(
          _principioActivoMeta,
          principioActivo.isAcceptableOrUnknown(
              data['principio_activo']!, _principioActivoMeta));
    }
    if (data.containsKey('concentracion')) {
      context.handle(
          _concentracionMeta,
          concentracion.isAcceptableOrUnknown(
              data['concentracion']!, _concentracionMeta));
    }
    if (data.containsKey('laboratorio_id')) {
      context.handle(
          _laboratorioIdMeta,
          laboratorioId.isAcceptableOrUnknown(
              data['laboratorio_id']!, _laboratorioIdMeta));
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    }
    if (data.containsKey('requiere_receta')) {
      context.handle(
          _requiereRecetaMeta,
          requiereReceta.isAcceptableOrUnknown(
              data['requiere_receta']!, _requiereRecetaMeta));
    }
    if (data.containsKey('es_psicotropico')) {
      context.handle(
          _esPsicotropicoMeta,
          esPsicotropico.isAcceptableOrUnknown(
              data['es_psicotropico']!, _esPsicotropicoMeta));
    }
    if (data.containsKey('es_antibiotico')) {
      context.handle(
          _esAntibioticoMeta,
          esAntibiotico.isAcceptableOrUnknown(
              data['es_antibiotico']!, _esAntibioticoMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      codigoBarras: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo_barras']),
      nombreComercial: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nombre_comercial'])!,
      principioActivo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}principio_activo']),
      concentracion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concentracion']),
      laboratorioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}laboratorio_id']),
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id']),
      requiereReceta: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}requiere_receta'])!,
      esPsicotropico: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_psicotropico'])!,
      esAntibiotico: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_antibiotico'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ProductosTableTable createAlias(String alias) {
    return $ProductosTableTable(attachedDatabase, alias);
  }
}

class ProductosTableData extends DataClass
    implements Insertable<ProductosTableData> {
  final int id;
  final String? codigoBarras;
  final String nombreComercial;
  final String? principioActivo;
  final String? concentracion;
  final int? laboratorioId;
  final int? categoriaId;
  final bool requiereReceta;
  final bool esPsicotropico;
  final bool esAntibiotico;
  final String estado;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ProductosTableData(
      {required this.id,
      this.codigoBarras,
      required this.nombreComercial,
      this.principioActivo,
      this.concentracion,
      this.laboratorioId,
      this.categoriaId,
      required this.requiereReceta,
      required this.esPsicotropico,
      required this.esAntibiotico,
      required this.estado,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['nombre_comercial'] = Variable<String>(nombreComercial);
    if (!nullToAbsent || principioActivo != null) {
      map['principio_activo'] = Variable<String>(principioActivo);
    }
    if (!nullToAbsent || concentracion != null) {
      map['concentracion'] = Variable<String>(concentracion);
    }
    if (!nullToAbsent || laboratorioId != null) {
      map['laboratorio_id'] = Variable<int>(laboratorioId);
    }
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    map['requiere_receta'] = Variable<bool>(requiereReceta);
    map['es_psicotropico'] = Variable<bool>(esPsicotropico);
    map['es_antibiotico'] = Variable<bool>(esAntibiotico);
    map['estado'] = Variable<String>(estado);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ProductosTableCompanion toCompanion(bool nullToAbsent) {
    return ProductosTableCompanion(
      id: Value(id),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      nombreComercial: Value(nombreComercial),
      principioActivo: principioActivo == null && nullToAbsent
          ? const Value.absent()
          : Value(principioActivo),
      concentracion: concentracion == null && nullToAbsent
          ? const Value.absent()
          : Value(concentracion),
      laboratorioId: laboratorioId == null && nullToAbsent
          ? const Value.absent()
          : Value(laboratorioId),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      requiereReceta: Value(requiereReceta),
      esPsicotropico: Value(esPsicotropico),
      esAntibiotico: Value(esAntibiotico),
      estado: Value(estado),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProductosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductosTableData(
      id: serializer.fromJson<int>(json['id']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      nombreComercial: serializer.fromJson<String>(json['nombreComercial']),
      principioActivo: serializer.fromJson<String?>(json['principioActivo']),
      concentracion: serializer.fromJson<String?>(json['concentracion']),
      laboratorioId: serializer.fromJson<int?>(json['laboratorioId']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      requiereReceta: serializer.fromJson<bool>(json['requiereReceta']),
      esPsicotropico: serializer.fromJson<bool>(json['esPsicotropico']),
      esAntibiotico: serializer.fromJson<bool>(json['esAntibiotico']),
      estado: serializer.fromJson<String>(json['estado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'nombreComercial': serializer.toJson<String>(nombreComercial),
      'principioActivo': serializer.toJson<String?>(principioActivo),
      'concentracion': serializer.toJson<String?>(concentracion),
      'laboratorioId': serializer.toJson<int?>(laboratorioId),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'requiereReceta': serializer.toJson<bool>(requiereReceta),
      'esPsicotropico': serializer.toJson<bool>(esPsicotropico),
      'esAntibiotico': serializer.toJson<bool>(esAntibiotico),
      'estado': serializer.toJson<String>(estado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ProductosTableData copyWith(
          {int? id,
          Value<String?> codigoBarras = const Value.absent(),
          String? nombreComercial,
          Value<String?> principioActivo = const Value.absent(),
          Value<String?> concentracion = const Value.absent(),
          Value<int?> laboratorioId = const Value.absent(),
          Value<int?> categoriaId = const Value.absent(),
          bool? requiereReceta,
          bool? esPsicotropico,
          bool? esAntibiotico,
          String? estado,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ProductosTableData(
        id: id ?? this.id,
        codigoBarras:
            codigoBarras.present ? codigoBarras.value : this.codigoBarras,
        nombreComercial: nombreComercial ?? this.nombreComercial,
        principioActivo: principioActivo.present
            ? principioActivo.value
            : this.principioActivo,
        concentracion:
            concentracion.present ? concentracion.value : this.concentracion,
        laboratorioId:
            laboratorioId.present ? laboratorioId.value : this.laboratorioId,
        categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
        requiereReceta: requiereReceta ?? this.requiereReceta,
        esPsicotropico: esPsicotropico ?? this.esPsicotropico,
        esAntibiotico: esAntibiotico ?? this.esAntibiotico,
        estado: estado ?? this.estado,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ProductosTableData copyWithCompanion(ProductosTableCompanion data) {
    return ProductosTableData(
      id: data.id.present ? data.id.value : this.id,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      nombreComercial: data.nombreComercial.present
          ? data.nombreComercial.value
          : this.nombreComercial,
      principioActivo: data.principioActivo.present
          ? data.principioActivo.value
          : this.principioActivo,
      concentracion: data.concentracion.present
          ? data.concentracion.value
          : this.concentracion,
      laboratorioId: data.laboratorioId.present
          ? data.laboratorioId.value
          : this.laboratorioId,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
      requiereReceta: data.requiereReceta.present
          ? data.requiereReceta.value
          : this.requiereReceta,
      esPsicotropico: data.esPsicotropico.present
          ? data.esPsicotropico.value
          : this.esPsicotropico,
      esAntibiotico: data.esAntibiotico.present
          ? data.esAntibiotico.value
          : this.esAntibiotico,
      estado: data.estado.present ? data.estado.value : this.estado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductosTableData(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombreComercial: $nombreComercial, ')
          ..write('principioActivo: $principioActivo, ')
          ..write('concentracion: $concentracion, ')
          ..write('laboratorioId: $laboratorioId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('requiereReceta: $requiereReceta, ')
          ..write('esPsicotropico: $esPsicotropico, ')
          ..write('esAntibiotico: $esAntibiotico, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      codigoBarras,
      nombreComercial,
      principioActivo,
      concentracion,
      laboratorioId,
      categoriaId,
      requiereReceta,
      esPsicotropico,
      esAntibiotico,
      estado,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductosTableData &&
          other.id == this.id &&
          other.codigoBarras == this.codigoBarras &&
          other.nombreComercial == this.nombreComercial &&
          other.principioActivo == this.principioActivo &&
          other.concentracion == this.concentracion &&
          other.laboratorioId == this.laboratorioId &&
          other.categoriaId == this.categoriaId &&
          other.requiereReceta == this.requiereReceta &&
          other.esPsicotropico == this.esPsicotropico &&
          other.esAntibiotico == this.esAntibiotico &&
          other.estado == this.estado &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductosTableCompanion extends UpdateCompanion<ProductosTableData> {
  final Value<int> id;
  final Value<String?> codigoBarras;
  final Value<String> nombreComercial;
  final Value<String?> principioActivo;
  final Value<String?> concentracion;
  final Value<int?> laboratorioId;
  final Value<int?> categoriaId;
  final Value<bool> requiereReceta;
  final Value<bool> esPsicotropico;
  final Value<bool> esAntibiotico;
  final Value<String> estado;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const ProductosTableCompanion({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.nombreComercial = const Value.absent(),
    this.principioActivo = const Value.absent(),
    this.concentracion = const Value.absent(),
    this.laboratorioId = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.requiereReceta = const Value.absent(),
    this.esPsicotropico = const Value.absent(),
    this.esAntibiotico = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductosTableCompanion.insert({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    required String nombreComercial,
    this.principioActivo = const Value.absent(),
    this.concentracion = const Value.absent(),
    this.laboratorioId = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.requiereReceta = const Value.absent(),
    this.esPsicotropico = const Value.absent(),
    this.esAntibiotico = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : nombreComercial = Value(nombreComercial);
  static Insertable<ProductosTableData> custom({
    Expression<int>? id,
    Expression<String>? codigoBarras,
    Expression<String>? nombreComercial,
    Expression<String>? principioActivo,
    Expression<String>? concentracion,
    Expression<int>? laboratorioId,
    Expression<int>? categoriaId,
    Expression<bool>? requiereReceta,
    Expression<bool>? esPsicotropico,
    Expression<bool>? esAntibiotico,
    Expression<String>? estado,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (nombreComercial != null) 'nombre_comercial': nombreComercial,
      if (principioActivo != null) 'principio_activo': principioActivo,
      if (concentracion != null) 'concentracion': concentracion,
      if (laboratorioId != null) 'laboratorio_id': laboratorioId,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (requiereReceta != null) 'requiere_receta': requiereReceta,
      if (esPsicotropico != null) 'es_psicotropico': esPsicotropico,
      if (esAntibiotico != null) 'es_antibiotico': esAntibiotico,
      if (estado != null) 'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductosTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? codigoBarras,
      Value<String>? nombreComercial,
      Value<String?>? principioActivo,
      Value<String?>? concentracion,
      Value<int?>? laboratorioId,
      Value<int?>? categoriaId,
      Value<bool>? requiereReceta,
      Value<bool>? esPsicotropico,
      Value<bool>? esAntibiotico,
      Value<String>? estado,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return ProductosTableCompanion(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      principioActivo: principioActivo ?? this.principioActivo,
      concentracion: concentracion ?? this.concentracion,
      laboratorioId: laboratorioId ?? this.laboratorioId,
      categoriaId: categoriaId ?? this.categoriaId,
      requiereReceta: requiereReceta ?? this.requiereReceta,
      esPsicotropico: esPsicotropico ?? this.esPsicotropico,
      esAntibiotico: esAntibiotico ?? this.esAntibiotico,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (nombreComercial.present) {
      map['nombre_comercial'] = Variable<String>(nombreComercial.value);
    }
    if (principioActivo.present) {
      map['principio_activo'] = Variable<String>(principioActivo.value);
    }
    if (concentracion.present) {
      map['concentracion'] = Variable<String>(concentracion.value);
    }
    if (laboratorioId.present) {
      map['laboratorio_id'] = Variable<int>(laboratorioId.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (requiereReceta.present) {
      map['requiere_receta'] = Variable<bool>(requiereReceta.value);
    }
    if (esPsicotropico.present) {
      map['es_psicotropico'] = Variable<bool>(esPsicotropico.value);
    }
    if (esAntibiotico.present) {
      map['es_antibiotico'] = Variable<bool>(esAntibiotico.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosTableCompanion(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombreComercial: $nombreComercial, ')
          ..write('principioActivo: $principioActivo, ')
          ..write('concentracion: $concentracion, ')
          ..write('laboratorioId: $laboratorioId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('requiereReceta: $requiereReceta, ')
          ..write('esPsicotropico: $esPsicotropico, ')
          ..write('esAntibiotico: $esAntibiotico, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PresentacionesTableTable extends PresentacionesTable
    with TableInfo<$PresentacionesTableTable, PresentacionesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresentacionesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
      'producto_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nombreDescriptivoMeta =
      const VerificationMeta('nombreDescriptivo');
  @override
  late final GeneratedColumn<String> nombreDescriptivo =
      GeneratedColumn<String>('nombre_descriptivo', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 100),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _unidadesPorCajaMeta =
      const VerificationMeta('unidadesPorCaja');
  @override
  late final GeneratedColumn<int> unidadesPorCaja = GeneratedColumn<int>(
      'unidades_por_caja', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _precioCompraCajaMeta =
      const VerificationMeta('precioCompraCaja');
  @override
  late final GeneratedColumn<double> precioCompraCaja = GeneratedColumn<double>(
      'precio_compra_caja', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _precioVentaCajaMeta =
      const VerificationMeta('precioVentaCaja');
  @override
  late final GeneratedColumn<double> precioVentaCaja = GeneratedColumn<double>(
      'precio_venta_caja', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _precioVentaFraccionMeta =
      const VerificationMeta('precioVentaFraccion');
  @override
  late final GeneratedColumn<double> precioVentaFraccion =
      GeneratedColumn<double>('precio_venta_fraccion', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _stockMinimoMeta =
      const VerificationMeta('stockMinimo');
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
      'stock_minimo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _codigoBarrasMeta =
      const VerificationMeta('codigoBarras');
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
      'codigo_barras', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tieneIvaMeta =
      const VerificationMeta('tieneIva');
  @override
  late final GeneratedColumn<bool> tieneIva = GeneratedColumn<bool>(
      'tiene_iva', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("tiene_iva" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productoId,
        nombreDescriptivo,
        unidadesPorCaja,
        precioCompraCaja,
        precioVentaCaja,
        precioVentaFraccion,
        stockMinimo,
        codigoBarras,
        tieneIva
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presentaciones';
  @override
  VerificationContext validateIntegrity(
      Insertable<PresentacionesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_descriptivo')) {
      context.handle(
          _nombreDescriptivoMeta,
          nombreDescriptivo.isAcceptableOrUnknown(
              data['nombre_descriptivo']!, _nombreDescriptivoMeta));
    } else if (isInserting) {
      context.missing(_nombreDescriptivoMeta);
    }
    if (data.containsKey('unidades_por_caja')) {
      context.handle(
          _unidadesPorCajaMeta,
          unidadesPorCaja.isAcceptableOrUnknown(
              data['unidades_por_caja']!, _unidadesPorCajaMeta));
    }
    if (data.containsKey('precio_compra_caja')) {
      context.handle(
          _precioCompraCajaMeta,
          precioCompraCaja.isAcceptableOrUnknown(
              data['precio_compra_caja']!, _precioCompraCajaMeta));
    }
    if (data.containsKey('precio_venta_caja')) {
      context.handle(
          _precioVentaCajaMeta,
          precioVentaCaja.isAcceptableOrUnknown(
              data['precio_venta_caja']!, _precioVentaCajaMeta));
    }
    if (data.containsKey('precio_venta_fraccion')) {
      context.handle(
          _precioVentaFraccionMeta,
          precioVentaFraccion.isAcceptableOrUnknown(
              data['precio_venta_fraccion']!, _precioVentaFraccionMeta));
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
          _stockMinimoMeta,
          stockMinimo.isAcceptableOrUnknown(
              data['stock_minimo']!, _stockMinimoMeta));
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
          _codigoBarrasMeta,
          codigoBarras.isAcceptableOrUnknown(
              data['codigo_barras']!, _codigoBarrasMeta));
    }
    if (data.containsKey('tiene_iva')) {
      context.handle(_tieneIvaMeta,
          tieneIva.isAcceptableOrUnknown(data['tiene_iva']!, _tieneIvaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresentacionesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresentacionesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}producto_id'])!,
      nombreDescriptivo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nombre_descriptivo'])!,
      unidadesPorCaja: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unidades_por_caja'])!,
      precioCompraCaja: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}precio_compra_caja'])!,
      precioVentaCaja: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}precio_venta_caja'])!,
      precioVentaFraccion: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}precio_venta_fraccion'])!,
      stockMinimo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_minimo'])!,
      codigoBarras: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo_barras']),
      tieneIva: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}tiene_iva'])!,
    );
  }

  @override
  $PresentacionesTableTable createAlias(String alias) {
    return $PresentacionesTableTable(attachedDatabase, alias);
  }
}

class PresentacionesTableData extends DataClass
    implements Insertable<PresentacionesTableData> {
  final int id;
  final int productoId;
  final String nombreDescriptivo;
  final int unidadesPorCaja;
  final double precioCompraCaja;
  final double precioVentaCaja;
  final double precioVentaFraccion;
  final int stockMinimo;
  final String? codigoBarras;
  final bool tieneIva;
  const PresentacionesTableData(
      {required this.id,
      required this.productoId,
      required this.nombreDescriptivo,
      required this.unidadesPorCaja,
      required this.precioCompraCaja,
      required this.precioVentaCaja,
      required this.precioVentaFraccion,
      required this.stockMinimo,
      this.codigoBarras,
      required this.tieneIva});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre_descriptivo'] = Variable<String>(nombreDescriptivo);
    map['unidades_por_caja'] = Variable<int>(unidadesPorCaja);
    map['precio_compra_caja'] = Variable<double>(precioCompraCaja);
    map['precio_venta_caja'] = Variable<double>(precioVentaCaja);
    map['precio_venta_fraccion'] = Variable<double>(precioVentaFraccion);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['tiene_iva'] = Variable<bool>(tieneIva);
    return map;
  }

  PresentacionesTableCompanion toCompanion(bool nullToAbsent) {
    return PresentacionesTableCompanion(
      id: Value(id),
      productoId: Value(productoId),
      nombreDescriptivo: Value(nombreDescriptivo),
      unidadesPorCaja: Value(unidadesPorCaja),
      precioCompraCaja: Value(precioCompraCaja),
      precioVentaCaja: Value(precioVentaCaja),
      precioVentaFraccion: Value(precioVentaFraccion),
      stockMinimo: Value(stockMinimo),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      tieneIva: Value(tieneIva),
    );
  }

  factory PresentacionesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresentacionesTableData(
      id: serializer.fromJson<int>(json['id']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombreDescriptivo: serializer.fromJson<String>(json['nombreDescriptivo']),
      unidadesPorCaja: serializer.fromJson<int>(json['unidadesPorCaja']),
      precioCompraCaja: serializer.fromJson<double>(json['precioCompraCaja']),
      precioVentaCaja: serializer.fromJson<double>(json['precioVentaCaja']),
      precioVentaFraccion:
          serializer.fromJson<double>(json['precioVentaFraccion']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      tieneIva: serializer.fromJson<bool>(json['tieneIva']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productoId': serializer.toJson<int>(productoId),
      'nombreDescriptivo': serializer.toJson<String>(nombreDescriptivo),
      'unidadesPorCaja': serializer.toJson<int>(unidadesPorCaja),
      'precioCompraCaja': serializer.toJson<double>(precioCompraCaja),
      'precioVentaCaja': serializer.toJson<double>(precioVentaCaja),
      'precioVentaFraccion': serializer.toJson<double>(precioVentaFraccion),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'tieneIva': serializer.toJson<bool>(tieneIva),
    };
  }

  PresentacionesTableData copyWith(
          {int? id,
          int? productoId,
          String? nombreDescriptivo,
          int? unidadesPorCaja,
          double? precioCompraCaja,
          double? precioVentaCaja,
          double? precioVentaFraccion,
          int? stockMinimo,
          Value<String?> codigoBarras = const Value.absent(),
          bool? tieneIva}) =>
      PresentacionesTableData(
        id: id ?? this.id,
        productoId: productoId ?? this.productoId,
        nombreDescriptivo: nombreDescriptivo ?? this.nombreDescriptivo,
        unidadesPorCaja: unidadesPorCaja ?? this.unidadesPorCaja,
        precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
        precioVentaCaja: precioVentaCaja ?? this.precioVentaCaja,
        precioVentaFraccion: precioVentaFraccion ?? this.precioVentaFraccion,
        stockMinimo: stockMinimo ?? this.stockMinimo,
        codigoBarras:
            codigoBarras.present ? codigoBarras.value : this.codigoBarras,
        tieneIva: tieneIva ?? this.tieneIva,
      );
  PresentacionesTableData copyWithCompanion(PresentacionesTableCompanion data) {
    return PresentacionesTableData(
      id: data.id.present ? data.id.value : this.id,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      nombreDescriptivo: data.nombreDescriptivo.present
          ? data.nombreDescriptivo.value
          : this.nombreDescriptivo,
      unidadesPorCaja: data.unidadesPorCaja.present
          ? data.unidadesPorCaja.value
          : this.unidadesPorCaja,
      precioCompraCaja: data.precioCompraCaja.present
          ? data.precioCompraCaja.value
          : this.precioCompraCaja,
      precioVentaCaja: data.precioVentaCaja.present
          ? data.precioVentaCaja.value
          : this.precioVentaCaja,
      precioVentaFraccion: data.precioVentaFraccion.present
          ? data.precioVentaFraccion.value
          : this.precioVentaFraccion,
      stockMinimo:
          data.stockMinimo.present ? data.stockMinimo.value : this.stockMinimo,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      tieneIva: data.tieneIva.present ? data.tieneIva.value : this.tieneIva,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresentacionesTableData(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('nombreDescriptivo: $nombreDescriptivo, ')
          ..write('unidadesPorCaja: $unidadesPorCaja, ')
          ..write('precioCompraCaja: $precioCompraCaja, ')
          ..write('precioVentaCaja: $precioVentaCaja, ')
          ..write('precioVentaFraccion: $precioVentaFraccion, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('tieneIva: $tieneIva')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productoId,
      nombreDescriptivo,
      unidadesPorCaja,
      precioCompraCaja,
      precioVentaCaja,
      precioVentaFraccion,
      stockMinimo,
      codigoBarras,
      tieneIva);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresentacionesTableData &&
          other.id == this.id &&
          other.productoId == this.productoId &&
          other.nombreDescriptivo == this.nombreDescriptivo &&
          other.unidadesPorCaja == this.unidadesPorCaja &&
          other.precioCompraCaja == this.precioCompraCaja &&
          other.precioVentaCaja == this.precioVentaCaja &&
          other.precioVentaFraccion == this.precioVentaFraccion &&
          other.stockMinimo == this.stockMinimo &&
          other.codigoBarras == this.codigoBarras &&
          other.tieneIva == this.tieneIva);
}

class PresentacionesTableCompanion
    extends UpdateCompanion<PresentacionesTableData> {
  final Value<int> id;
  final Value<int> productoId;
  final Value<String> nombreDescriptivo;
  final Value<int> unidadesPorCaja;
  final Value<double> precioCompraCaja;
  final Value<double> precioVentaCaja;
  final Value<double> precioVentaFraccion;
  final Value<int> stockMinimo;
  final Value<String?> codigoBarras;
  final Value<bool> tieneIva;
  const PresentacionesTableCompanion({
    this.id = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreDescriptivo = const Value.absent(),
    this.unidadesPorCaja = const Value.absent(),
    this.precioCompraCaja = const Value.absent(),
    this.precioVentaCaja = const Value.absent(),
    this.precioVentaFraccion = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.tieneIva = const Value.absent(),
  });
  PresentacionesTableCompanion.insert({
    this.id = const Value.absent(),
    required int productoId,
    required String nombreDescriptivo,
    this.unidadesPorCaja = const Value.absent(),
    this.precioCompraCaja = const Value.absent(),
    this.precioVentaCaja = const Value.absent(),
    this.precioVentaFraccion = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.tieneIva = const Value.absent(),
  })  : productoId = Value(productoId),
        nombreDescriptivo = Value(nombreDescriptivo);
  static Insertable<PresentacionesTableData> custom({
    Expression<int>? id,
    Expression<int>? productoId,
    Expression<String>? nombreDescriptivo,
    Expression<int>? unidadesPorCaja,
    Expression<double>? precioCompraCaja,
    Expression<double>? precioVentaCaja,
    Expression<double>? precioVentaFraccion,
    Expression<int>? stockMinimo,
    Expression<String>? codigoBarras,
    Expression<bool>? tieneIva,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productoId != null) 'producto_id': productoId,
      if (nombreDescriptivo != null) 'nombre_descriptivo': nombreDescriptivo,
      if (unidadesPorCaja != null) 'unidades_por_caja': unidadesPorCaja,
      if (precioCompraCaja != null) 'precio_compra_caja': precioCompraCaja,
      if (precioVentaCaja != null) 'precio_venta_caja': precioVentaCaja,
      if (precioVentaFraccion != null)
        'precio_venta_fraccion': precioVentaFraccion,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (tieneIva != null) 'tiene_iva': tieneIva,
    });
  }

  PresentacionesTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? productoId,
      Value<String>? nombreDescriptivo,
      Value<int>? unidadesPorCaja,
      Value<double>? precioCompraCaja,
      Value<double>? precioVentaCaja,
      Value<double>? precioVentaFraccion,
      Value<int>? stockMinimo,
      Value<String?>? codigoBarras,
      Value<bool>? tieneIva}) {
    return PresentacionesTableCompanion(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombreDescriptivo: nombreDescriptivo ?? this.nombreDescriptivo,
      unidadesPorCaja: unidadesPorCaja ?? this.unidadesPorCaja,
      precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
      precioVentaCaja: precioVentaCaja ?? this.precioVentaCaja,
      precioVentaFraccion: precioVentaFraccion ?? this.precioVentaFraccion,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      tieneIva: tieneIva ?? this.tieneIva,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreDescriptivo.present) {
      map['nombre_descriptivo'] = Variable<String>(nombreDescriptivo.value);
    }
    if (unidadesPorCaja.present) {
      map['unidades_por_caja'] = Variable<int>(unidadesPorCaja.value);
    }
    if (precioCompraCaja.present) {
      map['precio_compra_caja'] = Variable<double>(precioCompraCaja.value);
    }
    if (precioVentaCaja.present) {
      map['precio_venta_caja'] = Variable<double>(precioVentaCaja.value);
    }
    if (precioVentaFraccion.present) {
      map['precio_venta_fraccion'] =
          Variable<double>(precioVentaFraccion.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (tieneIva.present) {
      map['tiene_iva'] = Variable<bool>(tieneIva.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresentacionesTableCompanion(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('nombreDescriptivo: $nombreDescriptivo, ')
          ..write('unidadesPorCaja: $unidadesPorCaja, ')
          ..write('precioCompraCaja: $precioCompraCaja, ')
          ..write('precioVentaCaja: $precioVentaCaja, ')
          ..write('precioVentaFraccion: $precioVentaFraccion, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('tieneIva: $tieneIva')
          ..write(')'))
        .toString();
  }
}

class $LotesTableTable extends LotesTable
    with TableInfo<$LotesTableTable, LotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _presentacionIdMeta =
      const VerificationMeta('presentacionId');
  @override
  late final GeneratedColumn<int> presentacionId = GeneratedColumn<int>(
      'presentacion_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
      'lote', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fechaVencimientoMeta =
      const VerificationMeta('fechaVencimiento');
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>('fecha_vencimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaIngresoMeta =
      const VerificationMeta('fechaIngreso');
  @override
  late final GeneratedColumn<DateTime> fechaIngreso = GeneratedColumn<DateTime>(
      'fecha_ingreso', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _stockActualMeta =
      const VerificationMeta('stockActual');
  @override
  late final GeneratedColumn<double> stockActual = GeneratedColumn<double>(
      'stock_actual', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _precioCompraCajaMeta =
      const VerificationMeta('precioCompraCaja');
  @override
  late final GeneratedColumn<double> precioCompraCaja = GeneratedColumn<double>(
      'precio_compra_caja', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _precioCompraUnitarioMeta =
      const VerificationMeta('precioCompraUnitario');
  @override
  late final GeneratedColumn<double> precioCompraUnitario =
      GeneratedColumn<double>('precio_compra_unitario', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _ubicacionMeta =
      const VerificationMeta('ubicacion');
  @override
  late final GeneratedColumn<String> ubicacion = GeneratedColumn<String>(
      'ubicacion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        presentacionId,
        lote,
        fechaVencimiento,
        fechaIngreso,
        stockActual,
        precioCompraCaja,
        precioCompraUnitario,
        ubicacion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(Insertable<LotesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('presentacion_id')) {
      context.handle(
          _presentacionIdMeta,
          presentacionId.isAcceptableOrUnknown(
              data['presentacion_id']!, _presentacionIdMeta));
    } else if (isInserting) {
      context.missing(_presentacionIdMeta);
    }
    if (data.containsKey('lote')) {
      context.handle(
          _loteMeta, lote.isAcceptableOrUnknown(data['lote']!, _loteMeta));
    } else if (isInserting) {
      context.missing(_loteMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
          _fechaVencimientoMeta,
          fechaVencimiento.isAcceptableOrUnknown(
              data['fecha_vencimiento']!, _fechaVencimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('fecha_ingreso')) {
      context.handle(
          _fechaIngresoMeta,
          fechaIngreso.isAcceptableOrUnknown(
              data['fecha_ingreso']!, _fechaIngresoMeta));
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
          _stockActualMeta,
          stockActual.isAcceptableOrUnknown(
              data['stock_actual']!, _stockActualMeta));
    }
    if (data.containsKey('precio_compra_caja')) {
      context.handle(
          _precioCompraCajaMeta,
          precioCompraCaja.isAcceptableOrUnknown(
              data['precio_compra_caja']!, _precioCompraCajaMeta));
    }
    if (data.containsKey('precio_compra_unitario')) {
      context.handle(
          _precioCompraUnitarioMeta,
          precioCompraUnitario.isAcceptableOrUnknown(
              data['precio_compra_unitario']!, _precioCompraUnitarioMeta));
    }
    if (data.containsKey('ubicacion')) {
      context.handle(_ubicacionMeta,
          ubicacion.isAcceptableOrUnknown(data['ubicacion']!, _ubicacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LotesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      presentacionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}presentacion_id'])!,
      lote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote'])!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_vencimiento'])!,
      fechaIngreso: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_ingreso'])!,
      stockActual: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stock_actual'])!,
      precioCompraCaja: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}precio_compra_caja'])!,
      precioCompraUnitario: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}precio_compra_unitario'])!,
      ubicacion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ubicacion']),
    );
  }

  @override
  $LotesTableTable createAlias(String alias) {
    return $LotesTableTable(attachedDatabase, alias);
  }
}

class LotesTableData extends DataClass implements Insertable<LotesTableData> {
  final int id;
  final int presentacionId;
  final String lote;
  final DateTime fechaVencimiento;
  final DateTime fechaIngreso;
  final double stockActual;
  final double precioCompraCaja;
  final double precioCompraUnitario;
  final String? ubicacion;
  const LotesTableData(
      {required this.id,
      required this.presentacionId,
      required this.lote,
      required this.fechaVencimiento,
      required this.fechaIngreso,
      required this.stockActual,
      required this.precioCompraCaja,
      required this.precioCompraUnitario,
      this.ubicacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['presentacion_id'] = Variable<int>(presentacionId);
    map['lote'] = Variable<String>(lote);
    map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso);
    map['stock_actual'] = Variable<double>(stockActual);
    map['precio_compra_caja'] = Variable<double>(precioCompraCaja);
    map['precio_compra_unitario'] = Variable<double>(precioCompraUnitario);
    if (!nullToAbsent || ubicacion != null) {
      map['ubicacion'] = Variable<String>(ubicacion);
    }
    return map;
  }

  LotesTableCompanion toCompanion(bool nullToAbsent) {
    return LotesTableCompanion(
      id: Value(id),
      presentacionId: Value(presentacionId),
      lote: Value(lote),
      fechaVencimiento: Value(fechaVencimiento),
      fechaIngreso: Value(fechaIngreso),
      stockActual: Value(stockActual),
      precioCompraCaja: Value(precioCompraCaja),
      precioCompraUnitario: Value(precioCompraUnitario),
      ubicacion: ubicacion == null && nullToAbsent
          ? const Value.absent()
          : Value(ubicacion),
    );
  }

  factory LotesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LotesTableData(
      id: serializer.fromJson<int>(json['id']),
      presentacionId: serializer.fromJson<int>(json['presentacionId']),
      lote: serializer.fromJson<String>(json['lote']),
      fechaVencimiento: serializer.fromJson<DateTime>(json['fechaVencimiento']),
      fechaIngreso: serializer.fromJson<DateTime>(json['fechaIngreso']),
      stockActual: serializer.fromJson<double>(json['stockActual']),
      precioCompraCaja: serializer.fromJson<double>(json['precioCompraCaja']),
      precioCompraUnitario:
          serializer.fromJson<double>(json['precioCompraUnitario']),
      ubicacion: serializer.fromJson<String?>(json['ubicacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'presentacionId': serializer.toJson<int>(presentacionId),
      'lote': serializer.toJson<String>(lote),
      'fechaVencimiento': serializer.toJson<DateTime>(fechaVencimiento),
      'fechaIngreso': serializer.toJson<DateTime>(fechaIngreso),
      'stockActual': serializer.toJson<double>(stockActual),
      'precioCompraCaja': serializer.toJson<double>(precioCompraCaja),
      'precioCompraUnitario': serializer.toJson<double>(precioCompraUnitario),
      'ubicacion': serializer.toJson<String?>(ubicacion),
    };
  }

  LotesTableData copyWith(
          {int? id,
          int? presentacionId,
          String? lote,
          DateTime? fechaVencimiento,
          DateTime? fechaIngreso,
          double? stockActual,
          double? precioCompraCaja,
          double? precioCompraUnitario,
          Value<String?> ubicacion = const Value.absent()}) =>
      LotesTableData(
        id: id ?? this.id,
        presentacionId: presentacionId ?? this.presentacionId,
        lote: lote ?? this.lote,
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
        fechaIngreso: fechaIngreso ?? this.fechaIngreso,
        stockActual: stockActual ?? this.stockActual,
        precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
        precioCompraUnitario: precioCompraUnitario ?? this.precioCompraUnitario,
        ubicacion: ubicacion.present ? ubicacion.value : this.ubicacion,
      );
  LotesTableData copyWithCompanion(LotesTableCompanion data) {
    return LotesTableData(
      id: data.id.present ? data.id.value : this.id,
      presentacionId: data.presentacionId.present
          ? data.presentacionId.value
          : this.presentacionId,
      lote: data.lote.present ? data.lote.value : this.lote,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      fechaIngreso: data.fechaIngreso.present
          ? data.fechaIngreso.value
          : this.fechaIngreso,
      stockActual:
          data.stockActual.present ? data.stockActual.value : this.stockActual,
      precioCompraCaja: data.precioCompraCaja.present
          ? data.precioCompraCaja.value
          : this.precioCompraCaja,
      precioCompraUnitario: data.precioCompraUnitario.present
          ? data.precioCompraUnitario.value
          : this.precioCompraUnitario,
      ubicacion: data.ubicacion.present ? data.ubicacion.value : this.ubicacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LotesTableData(')
          ..write('id: $id, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('lote: $lote, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('stockActual: $stockActual, ')
          ..write('precioCompraCaja: $precioCompraCaja, ')
          ..write('precioCompraUnitario: $precioCompraUnitario, ')
          ..write('ubicacion: $ubicacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      presentacionId,
      lote,
      fechaVencimiento,
      fechaIngreso,
      stockActual,
      precioCompraCaja,
      precioCompraUnitario,
      ubicacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LotesTableData &&
          other.id == this.id &&
          other.presentacionId == this.presentacionId &&
          other.lote == this.lote &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.fechaIngreso == this.fechaIngreso &&
          other.stockActual == this.stockActual &&
          other.precioCompraCaja == this.precioCompraCaja &&
          other.precioCompraUnitario == this.precioCompraUnitario &&
          other.ubicacion == this.ubicacion);
}

class LotesTableCompanion extends UpdateCompanion<LotesTableData> {
  final Value<int> id;
  final Value<int> presentacionId;
  final Value<String> lote;
  final Value<DateTime> fechaVencimiento;
  final Value<DateTime> fechaIngreso;
  final Value<double> stockActual;
  final Value<double> precioCompraCaja;
  final Value<double> precioCompraUnitario;
  final Value<String?> ubicacion;
  const LotesTableCompanion({
    this.id = const Value.absent(),
    this.presentacionId = const Value.absent(),
    this.lote = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.fechaIngreso = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.precioCompraCaja = const Value.absent(),
    this.precioCompraUnitario = const Value.absent(),
    this.ubicacion = const Value.absent(),
  });
  LotesTableCompanion.insert({
    this.id = const Value.absent(),
    required int presentacionId,
    required String lote,
    required DateTime fechaVencimiento,
    this.fechaIngreso = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.precioCompraCaja = const Value.absent(),
    this.precioCompraUnitario = const Value.absent(),
    this.ubicacion = const Value.absent(),
  })  : presentacionId = Value(presentacionId),
        lote = Value(lote),
        fechaVencimiento = Value(fechaVencimiento);
  static Insertable<LotesTableData> custom({
    Expression<int>? id,
    Expression<int>? presentacionId,
    Expression<String>? lote,
    Expression<DateTime>? fechaVencimiento,
    Expression<DateTime>? fechaIngreso,
    Expression<double>? stockActual,
    Expression<double>? precioCompraCaja,
    Expression<double>? precioCompraUnitario,
    Expression<String>? ubicacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presentacionId != null) 'presentacion_id': presentacionId,
      if (lote != null) 'lote': lote,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (fechaIngreso != null) 'fecha_ingreso': fechaIngreso,
      if (stockActual != null) 'stock_actual': stockActual,
      if (precioCompraCaja != null) 'precio_compra_caja': precioCompraCaja,
      if (precioCompraUnitario != null)
        'precio_compra_unitario': precioCompraUnitario,
      if (ubicacion != null) 'ubicacion': ubicacion,
    });
  }

  LotesTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? presentacionId,
      Value<String>? lote,
      Value<DateTime>? fechaVencimiento,
      Value<DateTime>? fechaIngreso,
      Value<double>? stockActual,
      Value<double>? precioCompraCaja,
      Value<double>? precioCompraUnitario,
      Value<String?>? ubicacion}) {
    return LotesTableCompanion(
      id: id ?? this.id,
      presentacionId: presentacionId ?? this.presentacionId,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      stockActual: stockActual ?? this.stockActual,
      precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
      precioCompraUnitario: precioCompraUnitario ?? this.precioCompraUnitario,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (presentacionId.present) {
      map['presentacion_id'] = Variable<int>(presentacionId.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (fechaIngreso.present) {
      map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<double>(stockActual.value);
    }
    if (precioCompraCaja.present) {
      map['precio_compra_caja'] = Variable<double>(precioCompraCaja.value);
    }
    if (precioCompraUnitario.present) {
      map['precio_compra_unitario'] =
          Variable<double>(precioCompraUnitario.value);
    }
    if (ubicacion.present) {
      map['ubicacion'] = Variable<String>(ubicacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesTableCompanion(')
          ..write('id: $id, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('lote: $lote, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('stockActual: $stockActual, ')
          ..write('precioCompraCaja: $precioCompraCaja, ')
          ..write('precioCompraUnitario: $precioCompraUnitario, ')
          ..write('ubicacion: $ubicacion')
          ..write(')'))
        .toString();
  }
}

class $MovimientosStockTableTable extends MovimientosStockTable
    with TableInfo<$MovimientosStockTableTable, MovimientosStockTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosStockTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<int> loteId = GeneratedColumn<int>(
      'lote_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _documentoReferenciaMeta =
      const VerificationMeta('documentoReferencia');
  @override
  late final GeneratedColumn<String> documentoReferencia =
      GeneratedColumn<String>('documento_referencia', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaMovimientoMeta =
      const VerificationMeta('fechaMovimiento');
  @override
  late final GeneratedColumn<DateTime> fechaMovimiento =
      GeneratedColumn<DateTime>('fecha_movimiento', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>(
      'usuario_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tipo,
        loteId,
        cantidad,
        documentoReferencia,
        fechaMovimiento,
        usuarioId,
        observaciones
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_stock';
  @override
  VerificationContext validateIntegrity(
      Insertable<MovimientosStockTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('documento_referencia')) {
      context.handle(
          _documentoReferenciaMeta,
          documentoReferencia.isAcceptableOrUnknown(
              data['documento_referencia']!, _documentoReferenciaMeta));
    }
    if (data.containsKey('fecha_movimiento')) {
      context.handle(
          _fechaMovimientoMeta,
          fechaMovimiento.isAcceptableOrUnknown(
              data['fecha_movimiento']!, _fechaMovimientoMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientosStockTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosStockTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lote_id'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cantidad'])!,
      documentoReferencia: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}documento_referencia']),
      fechaMovimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_movimiento'])!,
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usuario_id']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
    );
  }

  @override
  $MovimientosStockTableTable createAlias(String alias) {
    return $MovimientosStockTableTable(attachedDatabase, alias);
  }
}

class MovimientosStockTableData extends DataClass
    implements Insertable<MovimientosStockTableData> {
  final int id;
  final String tipo;
  final int loteId;
  final double cantidad;
  final String? documentoReferencia;
  final DateTime fechaMovimiento;
  final int? usuarioId;
  final String? observaciones;
  const MovimientosStockTableData(
      {required this.id,
      required this.tipo,
      required this.loteId,
      required this.cantidad,
      this.documentoReferencia,
      required this.fechaMovimiento,
      this.usuarioId,
      this.observaciones});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['lote_id'] = Variable<int>(loteId);
    map['cantidad'] = Variable<double>(cantidad);
    if (!nullToAbsent || documentoReferencia != null) {
      map['documento_referencia'] = Variable<String>(documentoReferencia);
    }
    map['fecha_movimiento'] = Variable<DateTime>(fechaMovimiento);
    if (!nullToAbsent || usuarioId != null) {
      map['usuario_id'] = Variable<int>(usuarioId);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  MovimientosStockTableCompanion toCompanion(bool nullToAbsent) {
    return MovimientosStockTableCompanion(
      id: Value(id),
      tipo: Value(tipo),
      loteId: Value(loteId),
      cantidad: Value(cantidad),
      documentoReferencia: documentoReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(documentoReferencia),
      fechaMovimiento: Value(fechaMovimiento),
      usuarioId: usuarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioId),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory MovimientosStockTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosStockTableData(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      loteId: serializer.fromJson<int>(json['loteId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      documentoReferencia:
          serializer.fromJson<String?>(json['documentoReferencia']),
      fechaMovimiento: serializer.fromJson<DateTime>(json['fechaMovimiento']),
      usuarioId: serializer.fromJson<int?>(json['usuarioId']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'loteId': serializer.toJson<int>(loteId),
      'cantidad': serializer.toJson<double>(cantidad),
      'documentoReferencia': serializer.toJson<String?>(documentoReferencia),
      'fechaMovimiento': serializer.toJson<DateTime>(fechaMovimiento),
      'usuarioId': serializer.toJson<int?>(usuarioId),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  MovimientosStockTableData copyWith(
          {int? id,
          String? tipo,
          int? loteId,
          double? cantidad,
          Value<String?> documentoReferencia = const Value.absent(),
          DateTime? fechaMovimiento,
          Value<int?> usuarioId = const Value.absent(),
          Value<String?> observaciones = const Value.absent()}) =>
      MovimientosStockTableData(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        loteId: loteId ?? this.loteId,
        cantidad: cantidad ?? this.cantidad,
        documentoReferencia: documentoReferencia.present
            ? documentoReferencia.value
            : this.documentoReferencia,
        fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
        usuarioId: usuarioId.present ? usuarioId.value : this.usuarioId,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
      );
  MovimientosStockTableData copyWithCompanion(
      MovimientosStockTableCompanion data) {
    return MovimientosStockTableData(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      documentoReferencia: data.documentoReferencia.present
          ? data.documentoReferencia.value
          : this.documentoReferencia,
      fechaMovimiento: data.fechaMovimiento.present
          ? data.fechaMovimiento.value
          : this.fechaMovimiento,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosStockTableData(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('loteId: $loteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('documentoReferencia: $documentoReferencia, ')
          ..write('fechaMovimiento: $fechaMovimiento, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipo, loteId, cantidad,
      documentoReferencia, fechaMovimiento, usuarioId, observaciones);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosStockTableData &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.loteId == this.loteId &&
          other.cantidad == this.cantidad &&
          other.documentoReferencia == this.documentoReferencia &&
          other.fechaMovimiento == this.fechaMovimiento &&
          other.usuarioId == this.usuarioId &&
          other.observaciones == this.observaciones);
}

class MovimientosStockTableCompanion
    extends UpdateCompanion<MovimientosStockTableData> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<int> loteId;
  final Value<double> cantidad;
  final Value<String?> documentoReferencia;
  final Value<DateTime> fechaMovimiento;
  final Value<int?> usuarioId;
  final Value<String?> observaciones;
  const MovimientosStockTableCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.loteId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.documentoReferencia = const Value.absent(),
    this.fechaMovimiento = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  MovimientosStockTableCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required int loteId,
    required double cantidad,
    this.documentoReferencia = const Value.absent(),
    this.fechaMovimiento = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.observaciones = const Value.absent(),
  })  : tipo = Value(tipo),
        loteId = Value(loteId),
        cantidad = Value(cantidad);
  static Insertable<MovimientosStockTableData> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<int>? loteId,
    Expression<double>? cantidad,
    Expression<String>? documentoReferencia,
    Expression<DateTime>? fechaMovimiento,
    Expression<int>? usuarioId,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (loteId != null) 'lote_id': loteId,
      if (cantidad != null) 'cantidad': cantidad,
      if (documentoReferencia != null)
        'documento_referencia': documentoReferencia,
      if (fechaMovimiento != null) 'fecha_movimiento': fechaMovimiento,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  MovimientosStockTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? tipo,
      Value<int>? loteId,
      Value<double>? cantidad,
      Value<String?>? documentoReferencia,
      Value<DateTime>? fechaMovimiento,
      Value<int?>? usuarioId,
      Value<String?>? observaciones}) {
    return MovimientosStockTableCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      loteId: loteId ?? this.loteId,
      cantidad: cantidad ?? this.cantidad,
      documentoReferencia: documentoReferencia ?? this.documentoReferencia,
      fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
      usuarioId: usuarioId ?? this.usuarioId,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<int>(loteId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (documentoReferencia.present) {
      map['documento_referencia'] = Variable<String>(documentoReferencia.value);
    }
    if (fechaMovimiento.present) {
      map['fecha_movimiento'] = Variable<DateTime>(fechaMovimiento.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<int>(usuarioId.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosStockTableCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('loteId: $loteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('documentoReferencia: $documentoReferencia, ')
          ..write('fechaMovimiento: $fechaMovimiento, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $VentasTableTable extends VentasTable
    with TableInfo<$VentasTableTable, VentasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sesionCajaIdMeta =
      const VerificationMeta('sesionCajaId');
  @override
  late final GeneratedColumn<int> sesionCajaId = GeneratedColumn<int>(
      'sesion_caja_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fechaVentaMeta =
      const VerificationMeta('fechaVenta');
  @override
  late final GeneratedColumn<DateTime> fechaVenta = GeneratedColumn<DateTime>(
      'fecha_venta', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _subtotal0Meta =
      const VerificationMeta('subtotal0');
  @override
  late final GeneratedColumn<double> subtotal0 = GeneratedColumn<double>(
      'subtotal0', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _subtotal15Meta =
      const VerificationMeta('subtotal15');
  @override
  late final GeneratedColumn<double> subtotal15 = GeneratedColumn<double>(
      'subtotal15', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _descuentoTotalMeta =
      const VerificationMeta('descuentoTotal');
  @override
  late final GeneratedColumn<double> descuentoTotal = GeneratedColumn<double>(
      'descuento_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _impuestoTotalMeta =
      const VerificationMeta('impuestoTotal');
  @override
  late final GeneratedColumn<double> impuestoTotal = GeneratedColumn<double>(
      'impuesto_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _metodoPagoMeta =
      const VerificationMeta('metodoPago');
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
      'metodo_pago', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('efectivo'));
  static const VerificationMeta _claveAccesoMeta =
      const VerificationMeta('claveAcceso');
  @override
  late final GeneratedColumn<String> claveAcceso = GeneratedColumn<String>(
      'clave_acceso', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoSriMeta =
      const VerificationMeta('estadoSri');
  @override
  late final GeneratedColumn<String> estadoSri = GeneratedColumn<String>(
      'estado_sri', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendiente'));
  static const VerificationMeta _mensajeSriMeta =
      const VerificationMeta('mensajeSri');
  @override
  late final GeneratedColumn<String> mensajeSri = GeneratedColumn<String>(
      'mensaje_sri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clienteId,
        usuarioId,
        sesionCajaId,
        fechaVenta,
        subtotal0,
        subtotal15,
        descuentoTotal,
        impuestoTotal,
        total,
        metodoPago,
        claveAcceso,
        estadoSri,
        mensajeSri
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(Insertable<VentasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('sesion_caja_id')) {
      context.handle(
          _sesionCajaIdMeta,
          sesionCajaId.isAcceptableOrUnknown(
              data['sesion_caja_id']!, _sesionCajaIdMeta));
    } else if (isInserting) {
      context.missing(_sesionCajaIdMeta);
    }
    if (data.containsKey('fecha_venta')) {
      context.handle(
          _fechaVentaMeta,
          fechaVenta.isAcceptableOrUnknown(
              data['fecha_venta']!, _fechaVentaMeta));
    }
    if (data.containsKey('subtotal0')) {
      context.handle(_subtotal0Meta,
          subtotal0.isAcceptableOrUnknown(data['subtotal0']!, _subtotal0Meta));
    }
    if (data.containsKey('subtotal15')) {
      context.handle(
          _subtotal15Meta,
          subtotal15.isAcceptableOrUnknown(
              data['subtotal15']!, _subtotal15Meta));
    }
    if (data.containsKey('descuento_total')) {
      context.handle(
          _descuentoTotalMeta,
          descuentoTotal.isAcceptableOrUnknown(
              data['descuento_total']!, _descuentoTotalMeta));
    }
    if (data.containsKey('impuesto_total')) {
      context.handle(
          _impuestoTotalMeta,
          impuestoTotal.isAcceptableOrUnknown(
              data['impuesto_total']!, _impuestoTotalMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
          _metodoPagoMeta,
          metodoPago.isAcceptableOrUnknown(
              data['metodo_pago']!, _metodoPagoMeta));
    }
    if (data.containsKey('clave_acceso')) {
      context.handle(
          _claveAccesoMeta,
          claveAcceso.isAcceptableOrUnknown(
              data['clave_acceso']!, _claveAccesoMeta));
    }
    if (data.containsKey('estado_sri')) {
      context.handle(_estadoSriMeta,
          estadoSri.isAcceptableOrUnknown(data['estado_sri']!, _estadoSriMeta));
    }
    if (data.containsKey('mensaje_sri')) {
      context.handle(
          _mensajeSriMeta,
          mensajeSri.isAcceptableOrUnknown(
              data['mensaje_sri']!, _mensajeSriMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentasTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id']),
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usuario_id'])!,
      sesionCajaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sesion_caja_id'])!,
      fechaVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_venta'])!,
      subtotal0: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal0'])!,
      subtotal15: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal15'])!,
      descuentoTotal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}descuento_total'])!,
      impuestoTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}impuesto_total'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      metodoPago: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo_pago'])!,
      claveAcceso: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clave_acceso']),
      estadoSri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado_sri'])!,
      mensajeSri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mensaje_sri']),
    );
  }

  @override
  $VentasTableTable createAlias(String alias) {
    return $VentasTableTable(attachedDatabase, alias);
  }
}

class VentasTableData extends DataClass implements Insertable<VentasTableData> {
  final int id;
  final int? clienteId;
  final int usuarioId;
  final int sesionCajaId;
  final DateTime fechaVenta;
  final double subtotal0;
  final double subtotal15;
  final double descuentoTotal;
  final double impuestoTotal;
  final double total;
  final String metodoPago;
  final String? claveAcceso;
  final String estadoSri;
  final String? mensajeSri;
  const VentasTableData(
      {required this.id,
      this.clienteId,
      required this.usuarioId,
      required this.sesionCajaId,
      required this.fechaVenta,
      required this.subtotal0,
      required this.subtotal15,
      required this.descuentoTotal,
      required this.impuestoTotal,
      required this.total,
      required this.metodoPago,
      this.claveAcceso,
      required this.estadoSri,
      this.mensajeSri});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    map['usuario_id'] = Variable<int>(usuarioId);
    map['sesion_caja_id'] = Variable<int>(sesionCajaId);
    map['fecha_venta'] = Variable<DateTime>(fechaVenta);
    map['subtotal0'] = Variable<double>(subtotal0);
    map['subtotal15'] = Variable<double>(subtotal15);
    map['descuento_total'] = Variable<double>(descuentoTotal);
    map['impuesto_total'] = Variable<double>(impuestoTotal);
    map['total'] = Variable<double>(total);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || claveAcceso != null) {
      map['clave_acceso'] = Variable<String>(claveAcceso);
    }
    map['estado_sri'] = Variable<String>(estadoSri);
    if (!nullToAbsent || mensajeSri != null) {
      map['mensaje_sri'] = Variable<String>(mensajeSri);
    }
    return map;
  }

  VentasTableCompanion toCompanion(bool nullToAbsent) {
    return VentasTableCompanion(
      id: Value(id),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      usuarioId: Value(usuarioId),
      sesionCajaId: Value(sesionCajaId),
      fechaVenta: Value(fechaVenta),
      subtotal0: Value(subtotal0),
      subtotal15: Value(subtotal15),
      descuentoTotal: Value(descuentoTotal),
      impuestoTotal: Value(impuestoTotal),
      total: Value(total),
      metodoPago: Value(metodoPago),
      claveAcceso: claveAcceso == null && nullToAbsent
          ? const Value.absent()
          : Value(claveAcceso),
      estadoSri: Value(estadoSri),
      mensajeSri: mensajeSri == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeSri),
    );
  }

  factory VentasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentasTableData(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      usuarioId: serializer.fromJson<int>(json['usuarioId']),
      sesionCajaId: serializer.fromJson<int>(json['sesionCajaId']),
      fechaVenta: serializer.fromJson<DateTime>(json['fechaVenta']),
      subtotal0: serializer.fromJson<double>(json['subtotal0']),
      subtotal15: serializer.fromJson<double>(json['subtotal15']),
      descuentoTotal: serializer.fromJson<double>(json['descuentoTotal']),
      impuestoTotal: serializer.fromJson<double>(json['impuestoTotal']),
      total: serializer.fromJson<double>(json['total']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      claveAcceso: serializer.fromJson<String?>(json['claveAcceso']),
      estadoSri: serializer.fromJson<String>(json['estadoSri']),
      mensajeSri: serializer.fromJson<String?>(json['mensajeSri']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int?>(clienteId),
      'usuarioId': serializer.toJson<int>(usuarioId),
      'sesionCajaId': serializer.toJson<int>(sesionCajaId),
      'fechaVenta': serializer.toJson<DateTime>(fechaVenta),
      'subtotal0': serializer.toJson<double>(subtotal0),
      'subtotal15': serializer.toJson<double>(subtotal15),
      'descuentoTotal': serializer.toJson<double>(descuentoTotal),
      'impuestoTotal': serializer.toJson<double>(impuestoTotal),
      'total': serializer.toJson<double>(total),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'claveAcceso': serializer.toJson<String?>(claveAcceso),
      'estadoSri': serializer.toJson<String>(estadoSri),
      'mensajeSri': serializer.toJson<String?>(mensajeSri),
    };
  }

  VentasTableData copyWith(
          {int? id,
          Value<int?> clienteId = const Value.absent(),
          int? usuarioId,
          int? sesionCajaId,
          DateTime? fechaVenta,
          double? subtotal0,
          double? subtotal15,
          double? descuentoTotal,
          double? impuestoTotal,
          double? total,
          String? metodoPago,
          Value<String?> claveAcceso = const Value.absent(),
          String? estadoSri,
          Value<String?> mensajeSri = const Value.absent()}) =>
      VentasTableData(
        id: id ?? this.id,
        clienteId: clienteId.present ? clienteId.value : this.clienteId,
        usuarioId: usuarioId ?? this.usuarioId,
        sesionCajaId: sesionCajaId ?? this.sesionCajaId,
        fechaVenta: fechaVenta ?? this.fechaVenta,
        subtotal0: subtotal0 ?? this.subtotal0,
        subtotal15: subtotal15 ?? this.subtotal15,
        descuentoTotal: descuentoTotal ?? this.descuentoTotal,
        impuestoTotal: impuestoTotal ?? this.impuestoTotal,
        total: total ?? this.total,
        metodoPago: metodoPago ?? this.metodoPago,
        claveAcceso: claveAcceso.present ? claveAcceso.value : this.claveAcceso,
        estadoSri: estadoSri ?? this.estadoSri,
        mensajeSri: mensajeSri.present ? mensajeSri.value : this.mensajeSri,
      );
  VentasTableData copyWithCompanion(VentasTableCompanion data) {
    return VentasTableData(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      sesionCajaId: data.sesionCajaId.present
          ? data.sesionCajaId.value
          : this.sesionCajaId,
      fechaVenta:
          data.fechaVenta.present ? data.fechaVenta.value : this.fechaVenta,
      subtotal0: data.subtotal0.present ? data.subtotal0.value : this.subtotal0,
      subtotal15:
          data.subtotal15.present ? data.subtotal15.value : this.subtotal15,
      descuentoTotal: data.descuentoTotal.present
          ? data.descuentoTotal.value
          : this.descuentoTotal,
      impuestoTotal: data.impuestoTotal.present
          ? data.impuestoTotal.value
          : this.impuestoTotal,
      total: data.total.present ? data.total.value : this.total,
      metodoPago:
          data.metodoPago.present ? data.metodoPago.value : this.metodoPago,
      claveAcceso:
          data.claveAcceso.present ? data.claveAcceso.value : this.claveAcceso,
      estadoSri: data.estadoSri.present ? data.estadoSri.value : this.estadoSri,
      mensajeSri:
          data.mensajeSri.present ? data.mensajeSri.value : this.mensajeSri,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentasTableData(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('sesionCajaId: $sesionCajaId, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('subtotal0: $subtotal0, ')
          ..write('subtotal15: $subtotal15, ')
          ..write('descuentoTotal: $descuentoTotal, ')
          ..write('impuestoTotal: $impuestoTotal, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('claveAcceso: $claveAcceso, ')
          ..write('estadoSri: $estadoSri, ')
          ..write('mensajeSri: $mensajeSri')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clienteId,
      usuarioId,
      sesionCajaId,
      fechaVenta,
      subtotal0,
      subtotal15,
      descuentoTotal,
      impuestoTotal,
      total,
      metodoPago,
      claveAcceso,
      estadoSri,
      mensajeSri);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentasTableData &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.usuarioId == this.usuarioId &&
          other.sesionCajaId == this.sesionCajaId &&
          other.fechaVenta == this.fechaVenta &&
          other.subtotal0 == this.subtotal0 &&
          other.subtotal15 == this.subtotal15 &&
          other.descuentoTotal == this.descuentoTotal &&
          other.impuestoTotal == this.impuestoTotal &&
          other.total == this.total &&
          other.metodoPago == this.metodoPago &&
          other.claveAcceso == this.claveAcceso &&
          other.estadoSri == this.estadoSri &&
          other.mensajeSri == this.mensajeSri);
}

class VentasTableCompanion extends UpdateCompanion<VentasTableData> {
  final Value<int> id;
  final Value<int?> clienteId;
  final Value<int> usuarioId;
  final Value<int> sesionCajaId;
  final Value<DateTime> fechaVenta;
  final Value<double> subtotal0;
  final Value<double> subtotal15;
  final Value<double> descuentoTotal;
  final Value<double> impuestoTotal;
  final Value<double> total;
  final Value<String> metodoPago;
  final Value<String?> claveAcceso;
  final Value<String> estadoSri;
  final Value<String?> mensajeSri;
  const VentasTableCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.sesionCajaId = const Value.absent(),
    this.fechaVenta = const Value.absent(),
    this.subtotal0 = const Value.absent(),
    this.subtotal15 = const Value.absent(),
    this.descuentoTotal = const Value.absent(),
    this.impuestoTotal = const Value.absent(),
    this.total = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.claveAcceso = const Value.absent(),
    this.estadoSri = const Value.absent(),
    this.mensajeSri = const Value.absent(),
  });
  VentasTableCompanion.insert({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    required int usuarioId,
    required int sesionCajaId,
    this.fechaVenta = const Value.absent(),
    this.subtotal0 = const Value.absent(),
    this.subtotal15 = const Value.absent(),
    this.descuentoTotal = const Value.absent(),
    this.impuestoTotal = const Value.absent(),
    required double total,
    this.metodoPago = const Value.absent(),
    this.claveAcceso = const Value.absent(),
    this.estadoSri = const Value.absent(),
    this.mensajeSri = const Value.absent(),
  })  : usuarioId = Value(usuarioId),
        sesionCajaId = Value(sesionCajaId),
        total = Value(total);
  static Insertable<VentasTableData> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? usuarioId,
    Expression<int>? sesionCajaId,
    Expression<DateTime>? fechaVenta,
    Expression<double>? subtotal0,
    Expression<double>? subtotal15,
    Expression<double>? descuentoTotal,
    Expression<double>? impuestoTotal,
    Expression<double>? total,
    Expression<String>? metodoPago,
    Expression<String>? claveAcceso,
    Expression<String>? estadoSri,
    Expression<String>? mensajeSri,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (sesionCajaId != null) 'sesion_caja_id': sesionCajaId,
      if (fechaVenta != null) 'fecha_venta': fechaVenta,
      if (subtotal0 != null) 'subtotal0': subtotal0,
      if (subtotal15 != null) 'subtotal15': subtotal15,
      if (descuentoTotal != null) 'descuento_total': descuentoTotal,
      if (impuestoTotal != null) 'impuesto_total': impuestoTotal,
      if (total != null) 'total': total,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (claveAcceso != null) 'clave_acceso': claveAcceso,
      if (estadoSri != null) 'estado_sri': estadoSri,
      if (mensajeSri != null) 'mensaje_sri': mensajeSri,
    });
  }

  VentasTableCompanion copyWith(
      {Value<int>? id,
      Value<int?>? clienteId,
      Value<int>? usuarioId,
      Value<int>? sesionCajaId,
      Value<DateTime>? fechaVenta,
      Value<double>? subtotal0,
      Value<double>? subtotal15,
      Value<double>? descuentoTotal,
      Value<double>? impuestoTotal,
      Value<double>? total,
      Value<String>? metodoPago,
      Value<String?>? claveAcceso,
      Value<String>? estadoSri,
      Value<String?>? mensajeSri}) {
    return VentasTableCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      usuarioId: usuarioId ?? this.usuarioId,
      sesionCajaId: sesionCajaId ?? this.sesionCajaId,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      subtotal0: subtotal0 ?? this.subtotal0,
      subtotal15: subtotal15 ?? this.subtotal15,
      descuentoTotal: descuentoTotal ?? this.descuentoTotal,
      impuestoTotal: impuestoTotal ?? this.impuestoTotal,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      claveAcceso: claveAcceso ?? this.claveAcceso,
      estadoSri: estadoSri ?? this.estadoSri,
      mensajeSri: mensajeSri ?? this.mensajeSri,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<int>(usuarioId.value);
    }
    if (sesionCajaId.present) {
      map['sesion_caja_id'] = Variable<int>(sesionCajaId.value);
    }
    if (fechaVenta.present) {
      map['fecha_venta'] = Variable<DateTime>(fechaVenta.value);
    }
    if (subtotal0.present) {
      map['subtotal0'] = Variable<double>(subtotal0.value);
    }
    if (subtotal15.present) {
      map['subtotal15'] = Variable<double>(subtotal15.value);
    }
    if (descuentoTotal.present) {
      map['descuento_total'] = Variable<double>(descuentoTotal.value);
    }
    if (impuestoTotal.present) {
      map['impuesto_total'] = Variable<double>(impuestoTotal.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (claveAcceso.present) {
      map['clave_acceso'] = Variable<String>(claveAcceso.value);
    }
    if (estadoSri.present) {
      map['estado_sri'] = Variable<String>(estadoSri.value);
    }
    if (mensajeSri.present) {
      map['mensaje_sri'] = Variable<String>(mensajeSri.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasTableCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('sesionCajaId: $sesionCajaId, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('subtotal0: $subtotal0, ')
          ..write('subtotal15: $subtotal15, ')
          ..write('descuentoTotal: $descuentoTotal, ')
          ..write('impuestoTotal: $impuestoTotal, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('claveAcceso: $claveAcceso, ')
          ..write('estadoSri: $estadoSri, ')
          ..write('mensajeSri: $mensajeSri')
          ..write(')'))
        .toString();
  }
}

class $DetallesVentaTableTable extends DetallesVentaTable
    with TableInfo<$DetallesVentaTableTable, DetallesVentaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetallesVentaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ventaIdMeta =
      const VerificationMeta('ventaId');
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
      'venta_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _presentacionIdMeta =
      const VerificationMeta('presentacionId');
  @override
  late final GeneratedColumn<int> presentacionId = GeneratedColumn<int>(
      'presentacion_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<int> loteId = GeneratedColumn<int>(
      'lote_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _esFraccionMeta =
      const VerificationMeta('esFraccion');
  @override
  late final GeneratedColumn<bool> esFraccion = GeneratedColumn<bool>(
      'es_fraccion', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("es_fraccion" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _precioUnitarioMeta =
      const VerificationMeta('precioUnitario');
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
      'precio_unitario', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descuentoMeta =
      const VerificationMeta('descuento');
  @override
  late final GeneratedColumn<double> descuento = GeneratedColumn<double>(
      'descuento', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _ivaTotalMeta =
      const VerificationMeta('ivaTotal');
  @override
  late final GeneratedColumn<double> ivaTotal = GeneratedColumn<double>(
      'iva_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ventaId,
        presentacionId,
        loteId,
        cantidad,
        esFraccion,
        precioUnitario,
        descuento,
        subtotal,
        ivaTotal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalles_venta';
  @override
  VerificationContext validateIntegrity(
      Insertable<DetallesVentaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(_ventaIdMeta,
          ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta));
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('presentacion_id')) {
      context.handle(
          _presentacionIdMeta,
          presentacionId.isAcceptableOrUnknown(
              data['presentacion_id']!, _presentacionIdMeta));
    } else if (isInserting) {
      context.missing(_presentacionIdMeta);
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('es_fraccion')) {
      context.handle(
          _esFraccionMeta,
          esFraccion.isAcceptableOrUnknown(
              data['es_fraccion']!, _esFraccionMeta));
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
          _precioUnitarioMeta,
          precioUnitario.isAcceptableOrUnknown(
              data['precio_unitario']!, _precioUnitarioMeta));
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('descuento')) {
      context.handle(_descuentoMeta,
          descuento.isAcceptableOrUnknown(data['descuento']!, _descuentoMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('iva_total')) {
      context.handle(_ivaTotalMeta,
          ivaTotal.isAcceptableOrUnknown(data['iva_total']!, _ivaTotalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetallesVentaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetallesVentaTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ventaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}venta_id'])!,
      presentacionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}presentacion_id'])!,
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lote_id'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cantidad'])!,
      esFraccion: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_fraccion'])!,
      precioUnitario: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}precio_unitario'])!,
      descuento: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}descuento'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      ivaTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}iva_total'])!,
    );
  }

  @override
  $DetallesVentaTableTable createAlias(String alias) {
    return $DetallesVentaTableTable(attachedDatabase, alias);
  }
}

class DetallesVentaTableData extends DataClass
    implements Insertable<DetallesVentaTableData> {
  final int id;
  final int ventaId;
  final int presentacionId;
  final int loteId;
  final double cantidad;
  final bool esFraccion;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final double ivaTotal;
  const DetallesVentaTableData(
      {required this.id,
      required this.ventaId,
      required this.presentacionId,
      required this.loteId,
      required this.cantidad,
      required this.esFraccion,
      required this.precioUnitario,
      required this.descuento,
      required this.subtotal,
      required this.ivaTotal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['presentacion_id'] = Variable<int>(presentacionId);
    map['lote_id'] = Variable<int>(loteId);
    map['cantidad'] = Variable<double>(cantidad);
    map['es_fraccion'] = Variable<bool>(esFraccion);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['descuento'] = Variable<double>(descuento);
    map['subtotal'] = Variable<double>(subtotal);
    map['iva_total'] = Variable<double>(ivaTotal);
    return map;
  }

  DetallesVentaTableCompanion toCompanion(bool nullToAbsent) {
    return DetallesVentaTableCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      presentacionId: Value(presentacionId),
      loteId: Value(loteId),
      cantidad: Value(cantidad),
      esFraccion: Value(esFraccion),
      precioUnitario: Value(precioUnitario),
      descuento: Value(descuento),
      subtotal: Value(subtotal),
      ivaTotal: Value(ivaTotal),
    );
  }

  factory DetallesVentaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetallesVentaTableData(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      presentacionId: serializer.fromJson<int>(json['presentacionId']),
      loteId: serializer.fromJson<int>(json['loteId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      esFraccion: serializer.fromJson<bool>(json['esFraccion']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      descuento: serializer.fromJson<double>(json['descuento']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      ivaTotal: serializer.fromJson<double>(json['ivaTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'presentacionId': serializer.toJson<int>(presentacionId),
      'loteId': serializer.toJson<int>(loteId),
      'cantidad': serializer.toJson<double>(cantidad),
      'esFraccion': serializer.toJson<bool>(esFraccion),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'descuento': serializer.toJson<double>(descuento),
      'subtotal': serializer.toJson<double>(subtotal),
      'ivaTotal': serializer.toJson<double>(ivaTotal),
    };
  }

  DetallesVentaTableData copyWith(
          {int? id,
          int? ventaId,
          int? presentacionId,
          int? loteId,
          double? cantidad,
          bool? esFraccion,
          double? precioUnitario,
          double? descuento,
          double? subtotal,
          double? ivaTotal}) =>
      DetallesVentaTableData(
        id: id ?? this.id,
        ventaId: ventaId ?? this.ventaId,
        presentacionId: presentacionId ?? this.presentacionId,
        loteId: loteId ?? this.loteId,
        cantidad: cantidad ?? this.cantidad,
        esFraccion: esFraccion ?? this.esFraccion,
        precioUnitario: precioUnitario ?? this.precioUnitario,
        descuento: descuento ?? this.descuento,
        subtotal: subtotal ?? this.subtotal,
        ivaTotal: ivaTotal ?? this.ivaTotal,
      );
  DetallesVentaTableData copyWithCompanion(DetallesVentaTableCompanion data) {
    return DetallesVentaTableData(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      presentacionId: data.presentacionId.present
          ? data.presentacionId.value
          : this.presentacionId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      esFraccion:
          data.esFraccion.present ? data.esFraccion.value : this.esFraccion,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      descuento: data.descuento.present ? data.descuento.value : this.descuento,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      ivaTotal: data.ivaTotal.present ? data.ivaTotal.value : this.ivaTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetallesVentaTableData(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('loteId: $loteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('esFraccion: $esFraccion, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('descuento: $descuento, ')
          ..write('subtotal: $subtotal, ')
          ..write('ivaTotal: $ivaTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ventaId, presentacionId, loteId, cantidad,
      esFraccion, precioUnitario, descuento, subtotal, ivaTotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetallesVentaTableData &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.presentacionId == this.presentacionId &&
          other.loteId == this.loteId &&
          other.cantidad == this.cantidad &&
          other.esFraccion == this.esFraccion &&
          other.precioUnitario == this.precioUnitario &&
          other.descuento == this.descuento &&
          other.subtotal == this.subtotal &&
          other.ivaTotal == this.ivaTotal);
}

class DetallesVentaTableCompanion
    extends UpdateCompanion<DetallesVentaTableData> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> presentacionId;
  final Value<int> loteId;
  final Value<double> cantidad;
  final Value<bool> esFraccion;
  final Value<double> precioUnitario;
  final Value<double> descuento;
  final Value<double> subtotal;
  final Value<double> ivaTotal;
  const DetallesVentaTableCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.presentacionId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.esFraccion = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.descuento = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.ivaTotal = const Value.absent(),
  });
  DetallesVentaTableCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int presentacionId,
    required int loteId,
    required double cantidad,
    this.esFraccion = const Value.absent(),
    required double precioUnitario,
    this.descuento = const Value.absent(),
    required double subtotal,
    this.ivaTotal = const Value.absent(),
  })  : ventaId = Value(ventaId),
        presentacionId = Value(presentacionId),
        loteId = Value(loteId),
        cantidad = Value(cantidad),
        precioUnitario = Value(precioUnitario),
        subtotal = Value(subtotal);
  static Insertable<DetallesVentaTableData> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? presentacionId,
    Expression<int>? loteId,
    Expression<double>? cantidad,
    Expression<bool>? esFraccion,
    Expression<double>? precioUnitario,
    Expression<double>? descuento,
    Expression<double>? subtotal,
    Expression<double>? ivaTotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (presentacionId != null) 'presentacion_id': presentacionId,
      if (loteId != null) 'lote_id': loteId,
      if (cantidad != null) 'cantidad': cantidad,
      if (esFraccion != null) 'es_fraccion': esFraccion,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (descuento != null) 'descuento': descuento,
      if (subtotal != null) 'subtotal': subtotal,
      if (ivaTotal != null) 'iva_total': ivaTotal,
    });
  }

  DetallesVentaTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? ventaId,
      Value<int>? presentacionId,
      Value<int>? loteId,
      Value<double>? cantidad,
      Value<bool>? esFraccion,
      Value<double>? precioUnitario,
      Value<double>? descuento,
      Value<double>? subtotal,
      Value<double>? ivaTotal}) {
    return DetallesVentaTableCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      presentacionId: presentacionId ?? this.presentacionId,
      loteId: loteId ?? this.loteId,
      cantidad: cantidad ?? this.cantidad,
      esFraccion: esFraccion ?? this.esFraccion,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuento: descuento ?? this.descuento,
      subtotal: subtotal ?? this.subtotal,
      ivaTotal: ivaTotal ?? this.ivaTotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (presentacionId.present) {
      map['presentacion_id'] = Variable<int>(presentacionId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<int>(loteId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (esFraccion.present) {
      map['es_fraccion'] = Variable<bool>(esFraccion.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (descuento.present) {
      map['descuento'] = Variable<double>(descuento.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (ivaTotal.present) {
      map['iva_total'] = Variable<double>(ivaTotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetallesVentaTableCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('loteId: $loteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('esFraccion: $esFraccion, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('descuento: $descuento, ')
          ..write('subtotal: $subtotal, ')
          ..write('ivaTotal: $ivaTotal')
          ..write(')'))
        .toString();
  }
}

class $ClientesTableTable extends ClientesTable
    with TableInfo<$ClientesTableTable, ClientesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _documentoMeta =
      const VerificationMeta('documento');
  @override
  late final GeneratedColumn<String> documento = GeneratedColumn<String>(
      'documento', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 13),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tipoDocumentoMeta =
      const VerificationMeta('tipoDocumento');
  @override
  late final GeneratedColumn<String> tipoDocumento = GeneratedColumn<String>(
      'tipo_documento', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('05'));
  static const VerificationMeta _nombreCompletoMeta =
      const VerificationMeta('nombreCompleto');
  @override
  late final GeneratedColumn<String> nombreCompleto = GeneratedColumn<String>(
      'nombre_completo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        documento,
        tipoDocumento,
        nombreCompleto,
        telefono,
        email,
        direccion,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<ClientesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('documento')) {
      context.handle(_documentoMeta,
          documento.isAcceptableOrUnknown(data['documento']!, _documentoMeta));
    } else if (isInserting) {
      context.missing(_documentoMeta);
    }
    if (data.containsKey('tipo_documento')) {
      context.handle(
          _tipoDocumentoMeta,
          tipoDocumento.isAcceptableOrUnknown(
              data['tipo_documento']!, _tipoDocumentoMeta));
    }
    if (data.containsKey('nombre_completo')) {
      context.handle(
          _nombreCompletoMeta,
          nombreCompleto.isAcceptableOrUnknown(
              data['nombre_completo']!, _nombreCompletoMeta));
    } else if (isInserting) {
      context.missing(_nombreCompletoMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      documento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}documento'])!,
      tipoDocumento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_documento'])!,
      nombreCompleto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nombre_completo'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ClientesTableTable createAlias(String alias) {
    return $ClientesTableTable(attachedDatabase, alias);
  }
}

class ClientesTableData extends DataClass
    implements Insertable<ClientesTableData> {
  final int id;
  final String documento;
  final String tipoDocumento;
  final String nombreCompleto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final DateTime createdAt;
  const ClientesTableData(
      {required this.id,
      required this.documento,
      required this.tipoDocumento,
      required this.nombreCompleto,
      this.telefono,
      this.email,
      this.direccion,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['documento'] = Variable<String>(documento);
    map['tipo_documento'] = Variable<String>(tipoDocumento);
    map['nombre_completo'] = Variable<String>(nombreCompleto);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientesTableCompanion toCompanion(bool nullToAbsent) {
    return ClientesTableCompanion(
      id: Value(id),
      documento: Value(documento),
      tipoDocumento: Value(tipoDocumento),
      nombreCompleto: Value(nombreCompleto),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      createdAt: Value(createdAt),
    );
  }

  factory ClientesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientesTableData(
      id: serializer.fromJson<int>(json['id']),
      documento: serializer.fromJson<String>(json['documento']),
      tipoDocumento: serializer.fromJson<String>(json['tipoDocumento']),
      nombreCompleto: serializer.fromJson<String>(json['nombreCompleto']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documento': serializer.toJson<String>(documento),
      'tipoDocumento': serializer.toJson<String>(tipoDocumento),
      'nombreCompleto': serializer.toJson<String>(nombreCompleto),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'direccion': serializer.toJson<String?>(direccion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClientesTableData copyWith(
          {int? id,
          String? documento,
          String? tipoDocumento,
          String? nombreCompleto,
          Value<String?> telefono = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> direccion = const Value.absent(),
          DateTime? createdAt}) =>
      ClientesTableData(
        id: id ?? this.id,
        documento: documento ?? this.documento,
        tipoDocumento: tipoDocumento ?? this.tipoDocumento,
        nombreCompleto: nombreCompleto ?? this.nombreCompleto,
        telefono: telefono.present ? telefono.value : this.telefono,
        email: email.present ? email.value : this.email,
        direccion: direccion.present ? direccion.value : this.direccion,
        createdAt: createdAt ?? this.createdAt,
      );
  ClientesTableData copyWithCompanion(ClientesTableCompanion data) {
    return ClientesTableData(
      id: data.id.present ? data.id.value : this.id,
      documento: data.documento.present ? data.documento.value : this.documento,
      tipoDocumento: data.tipoDocumento.present
          ? data.tipoDocumento.value
          : this.tipoDocumento,
      nombreCompleto: data.nombreCompleto.present
          ? data.nombreCompleto.value
          : this.nombreCompleto,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientesTableData(')
          ..write('id: $id, ')
          ..write('documento: $documento, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, documento, tipoDocumento, nombreCompleto,
      telefono, email, direccion, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientesTableData &&
          other.id == this.id &&
          other.documento == this.documento &&
          other.tipoDocumento == this.tipoDocumento &&
          other.nombreCompleto == this.nombreCompleto &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.direccion == this.direccion &&
          other.createdAt == this.createdAt);
}

class ClientesTableCompanion extends UpdateCompanion<ClientesTableData> {
  final Value<int> id;
  final Value<String> documento;
  final Value<String> tipoDocumento;
  final Value<String> nombreCompleto;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> direccion;
  final Value<DateTime> createdAt;
  const ClientesTableCompanion({
    this.id = const Value.absent(),
    this.documento = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.nombreCompleto = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientesTableCompanion.insert({
    this.id = const Value.absent(),
    required String documento,
    this.tipoDocumento = const Value.absent(),
    required String nombreCompleto,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : documento = Value(documento),
        nombreCompleto = Value(nombreCompleto);
  static Insertable<ClientesTableData> custom({
    Expression<int>? id,
    Expression<String>? documento,
    Expression<String>? tipoDocumento,
    Expression<String>? nombreCompleto,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? direccion,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documento != null) 'documento': documento,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (direccion != null) 'direccion': direccion,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? documento,
      Value<String>? tipoDocumento,
      Value<String>? nombreCompleto,
      Value<String?>? telefono,
      Value<String?>? email,
      Value<String?>? direccion,
      Value<DateTime>? createdAt}) {
    return ClientesTableCompanion(
      id: id ?? this.id,
      documento: documento ?? this.documento,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documento.present) {
      map['documento'] = Variable<String>(documento.value);
    }
    if (tipoDocumento.present) {
      map['tipo_documento'] = Variable<String>(tipoDocumento.value);
    }
    if (nombreCompleto.present) {
      map['nombre_completo'] = Variable<String>(nombreCompleto.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesTableCompanion(')
          ..write('id: $id, ')
          ..write('documento: $documento, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProveedoresTableTable extends ProveedoresTable
    with TableInfo<$ProveedoresTableTable, ProveedoresTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProveedoresTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
      'ruc', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 13, maxTextLength: 13),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nombreEmpresaMeta =
      const VerificationMeta('nombreEmpresa');
  @override
  late final GeneratedColumn<String> nombreEmpresa = GeneratedColumn<String>(
      'nombre_empresa', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefonoEmpresaMeta =
      const VerificationMeta('telefonoEmpresa');
  @override
  late final GeneratedColumn<String> telefonoEmpresa = GeneratedColumn<String>(
      'telefono_empresa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailEmpresaMeta =
      const VerificationMeta('emailEmpresa');
  @override
  late final GeneratedColumn<String> emailEmpresa = GeneratedColumn<String>(
      'email_empresa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreContactoMeta =
      const VerificationMeta('nombreContacto');
  @override
  late final GeneratedColumn<String> nombreContacto = GeneratedColumn<String>(
      'nombre_contacto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefonoContactoMeta =
      const VerificationMeta('telefonoContacto');
  @override
  late final GeneratedColumn<String> telefonoContacto = GeneratedColumn<String>(
      'telefono_contacto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailContactoMeta =
      const VerificationMeta('emailContacto');
  @override
  late final GeneratedColumn<String> emailContacto = GeneratedColumn<String>(
      'email_contacto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('activo'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ruc,
        nombreEmpresa,
        direccion,
        telefonoEmpresa,
        emailEmpresa,
        nombreContacto,
        telefonoContacto,
        emailContacto,
        estado,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedores';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProveedoresTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ruc')) {
      context.handle(
          _rucMeta, ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta));
    } else if (isInserting) {
      context.missing(_rucMeta);
    }
    if (data.containsKey('nombre_empresa')) {
      context.handle(
          _nombreEmpresaMeta,
          nombreEmpresa.isAcceptableOrUnknown(
              data['nombre_empresa']!, _nombreEmpresaMeta));
    } else if (isInserting) {
      context.missing(_nombreEmpresaMeta);
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('telefono_empresa')) {
      context.handle(
          _telefonoEmpresaMeta,
          telefonoEmpresa.isAcceptableOrUnknown(
              data['telefono_empresa']!, _telefonoEmpresaMeta));
    }
    if (data.containsKey('email_empresa')) {
      context.handle(
          _emailEmpresaMeta,
          emailEmpresa.isAcceptableOrUnknown(
              data['email_empresa']!, _emailEmpresaMeta));
    }
    if (data.containsKey('nombre_contacto')) {
      context.handle(
          _nombreContactoMeta,
          nombreContacto.isAcceptableOrUnknown(
              data['nombre_contacto']!, _nombreContactoMeta));
    }
    if (data.containsKey('telefono_contacto')) {
      context.handle(
          _telefonoContactoMeta,
          telefonoContacto.isAcceptableOrUnknown(
              data['telefono_contacto']!, _telefonoContactoMeta));
    }
    if (data.containsKey('email_contacto')) {
      context.handle(
          _emailContactoMeta,
          emailContacto.isAcceptableOrUnknown(
              data['email_contacto']!, _emailContactoMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProveedoresTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProveedoresTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ruc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ruc'])!,
      nombreEmpresa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_empresa'])!,
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      telefonoEmpresa: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}telefono_empresa']),
      emailEmpresa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_empresa']),
      nombreContacto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_contacto']),
      telefonoContacto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}telefono_contacto']),
      emailContacto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_contacto']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProveedoresTableTable createAlias(String alias) {
    return $ProveedoresTableTable(attachedDatabase, alias);
  }
}

class ProveedoresTableData extends DataClass
    implements Insertable<ProveedoresTableData> {
  final int id;
  final String ruc;
  final String nombreEmpresa;
  final String? direccion;
  final String? telefonoEmpresa;
  final String? emailEmpresa;
  final String? nombreContacto;
  final String? telefonoContacto;
  final String? emailContacto;
  final String estado;
  final DateTime createdAt;
  const ProveedoresTableData(
      {required this.id,
      required this.ruc,
      required this.nombreEmpresa,
      this.direccion,
      this.telefonoEmpresa,
      this.emailEmpresa,
      this.nombreContacto,
      this.telefonoContacto,
      this.emailContacto,
      required this.estado,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ruc'] = Variable<String>(ruc);
    map['nombre_empresa'] = Variable<String>(nombreEmpresa);
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || telefonoEmpresa != null) {
      map['telefono_empresa'] = Variable<String>(telefonoEmpresa);
    }
    if (!nullToAbsent || emailEmpresa != null) {
      map['email_empresa'] = Variable<String>(emailEmpresa);
    }
    if (!nullToAbsent || nombreContacto != null) {
      map['nombre_contacto'] = Variable<String>(nombreContacto);
    }
    if (!nullToAbsent || telefonoContacto != null) {
      map['telefono_contacto'] = Variable<String>(telefonoContacto);
    }
    if (!nullToAbsent || emailContacto != null) {
      map['email_contacto'] = Variable<String>(emailContacto);
    }
    map['estado'] = Variable<String>(estado);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProveedoresTableCompanion toCompanion(bool nullToAbsent) {
    return ProveedoresTableCompanion(
      id: Value(id),
      ruc: Value(ruc),
      nombreEmpresa: Value(nombreEmpresa),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      telefonoEmpresa: telefonoEmpresa == null && nullToAbsent
          ? const Value.absent()
          : Value(telefonoEmpresa),
      emailEmpresa: emailEmpresa == null && nullToAbsent
          ? const Value.absent()
          : Value(emailEmpresa),
      nombreContacto: nombreContacto == null && nullToAbsent
          ? const Value.absent()
          : Value(nombreContacto),
      telefonoContacto: telefonoContacto == null && nullToAbsent
          ? const Value.absent()
          : Value(telefonoContacto),
      emailContacto: emailContacto == null && nullToAbsent
          ? const Value.absent()
          : Value(emailContacto),
      estado: Value(estado),
      createdAt: Value(createdAt),
    );
  }

  factory ProveedoresTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProveedoresTableData(
      id: serializer.fromJson<int>(json['id']),
      ruc: serializer.fromJson<String>(json['ruc']),
      nombreEmpresa: serializer.fromJson<String>(json['nombreEmpresa']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      telefonoEmpresa: serializer.fromJson<String?>(json['telefonoEmpresa']),
      emailEmpresa: serializer.fromJson<String?>(json['emailEmpresa']),
      nombreContacto: serializer.fromJson<String?>(json['nombreContacto']),
      telefonoContacto: serializer.fromJson<String?>(json['telefonoContacto']),
      emailContacto: serializer.fromJson<String?>(json['emailContacto']),
      estado: serializer.fromJson<String>(json['estado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruc': serializer.toJson<String>(ruc),
      'nombreEmpresa': serializer.toJson<String>(nombreEmpresa),
      'direccion': serializer.toJson<String?>(direccion),
      'telefonoEmpresa': serializer.toJson<String?>(telefonoEmpresa),
      'emailEmpresa': serializer.toJson<String?>(emailEmpresa),
      'nombreContacto': serializer.toJson<String?>(nombreContacto),
      'telefonoContacto': serializer.toJson<String?>(telefonoContacto),
      'emailContacto': serializer.toJson<String?>(emailContacto),
      'estado': serializer.toJson<String>(estado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProveedoresTableData copyWith(
          {int? id,
          String? ruc,
          String? nombreEmpresa,
          Value<String?> direccion = const Value.absent(),
          Value<String?> telefonoEmpresa = const Value.absent(),
          Value<String?> emailEmpresa = const Value.absent(),
          Value<String?> nombreContacto = const Value.absent(),
          Value<String?> telefonoContacto = const Value.absent(),
          Value<String?> emailContacto = const Value.absent(),
          String? estado,
          DateTime? createdAt}) =>
      ProveedoresTableData(
        id: id ?? this.id,
        ruc: ruc ?? this.ruc,
        nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
        direccion: direccion.present ? direccion.value : this.direccion,
        telefonoEmpresa: telefonoEmpresa.present
            ? telefonoEmpresa.value
            : this.telefonoEmpresa,
        emailEmpresa:
            emailEmpresa.present ? emailEmpresa.value : this.emailEmpresa,
        nombreContacto:
            nombreContacto.present ? nombreContacto.value : this.nombreContacto,
        telefonoContacto: telefonoContacto.present
            ? telefonoContacto.value
            : this.telefonoContacto,
        emailContacto:
            emailContacto.present ? emailContacto.value : this.emailContacto,
        estado: estado ?? this.estado,
        createdAt: createdAt ?? this.createdAt,
      );
  ProveedoresTableData copyWithCompanion(ProveedoresTableCompanion data) {
    return ProveedoresTableData(
      id: data.id.present ? data.id.value : this.id,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      nombreEmpresa: data.nombreEmpresa.present
          ? data.nombreEmpresa.value
          : this.nombreEmpresa,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      telefonoEmpresa: data.telefonoEmpresa.present
          ? data.telefonoEmpresa.value
          : this.telefonoEmpresa,
      emailEmpresa: data.emailEmpresa.present
          ? data.emailEmpresa.value
          : this.emailEmpresa,
      nombreContacto: data.nombreContacto.present
          ? data.nombreContacto.value
          : this.nombreContacto,
      telefonoContacto: data.telefonoContacto.present
          ? data.telefonoContacto.value
          : this.telefonoContacto,
      emailContacto: data.emailContacto.present
          ? data.emailContacto.value
          : this.emailContacto,
      estado: data.estado.present ? data.estado.value : this.estado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresTableData(')
          ..write('id: $id, ')
          ..write('ruc: $ruc, ')
          ..write('nombreEmpresa: $nombreEmpresa, ')
          ..write('direccion: $direccion, ')
          ..write('telefonoEmpresa: $telefonoEmpresa, ')
          ..write('emailEmpresa: $emailEmpresa, ')
          ..write('nombreContacto: $nombreContacto, ')
          ..write('telefonoContacto: $telefonoContacto, ')
          ..write('emailContacto: $emailContacto, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ruc,
      nombreEmpresa,
      direccion,
      telefonoEmpresa,
      emailEmpresa,
      nombreContacto,
      telefonoContacto,
      emailContacto,
      estado,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProveedoresTableData &&
          other.id == this.id &&
          other.ruc == this.ruc &&
          other.nombreEmpresa == this.nombreEmpresa &&
          other.direccion == this.direccion &&
          other.telefonoEmpresa == this.telefonoEmpresa &&
          other.emailEmpresa == this.emailEmpresa &&
          other.nombreContacto == this.nombreContacto &&
          other.telefonoContacto == this.telefonoContacto &&
          other.emailContacto == this.emailContacto &&
          other.estado == this.estado &&
          other.createdAt == this.createdAt);
}

class ProveedoresTableCompanion extends UpdateCompanion<ProveedoresTableData> {
  final Value<int> id;
  final Value<String> ruc;
  final Value<String> nombreEmpresa;
  final Value<String?> direccion;
  final Value<String?> telefonoEmpresa;
  final Value<String?> emailEmpresa;
  final Value<String?> nombreContacto;
  final Value<String?> telefonoContacto;
  final Value<String?> emailContacto;
  final Value<String> estado;
  final Value<DateTime> createdAt;
  const ProveedoresTableCompanion({
    this.id = const Value.absent(),
    this.ruc = const Value.absent(),
    this.nombreEmpresa = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefonoEmpresa = const Value.absent(),
    this.emailEmpresa = const Value.absent(),
    this.nombreContacto = const Value.absent(),
    this.telefonoContacto = const Value.absent(),
    this.emailContacto = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProveedoresTableCompanion.insert({
    this.id = const Value.absent(),
    required String ruc,
    required String nombreEmpresa,
    this.direccion = const Value.absent(),
    this.telefonoEmpresa = const Value.absent(),
    this.emailEmpresa = const Value.absent(),
    this.nombreContacto = const Value.absent(),
    this.telefonoContacto = const Value.absent(),
    this.emailContacto = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : ruc = Value(ruc),
        nombreEmpresa = Value(nombreEmpresa);
  static Insertable<ProveedoresTableData> custom({
    Expression<int>? id,
    Expression<String>? ruc,
    Expression<String>? nombreEmpresa,
    Expression<String>? direccion,
    Expression<String>? telefonoEmpresa,
    Expression<String>? emailEmpresa,
    Expression<String>? nombreContacto,
    Expression<String>? telefonoContacto,
    Expression<String>? emailContacto,
    Expression<String>? estado,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruc != null) 'ruc': ruc,
      if (nombreEmpresa != null) 'nombre_empresa': nombreEmpresa,
      if (direccion != null) 'direccion': direccion,
      if (telefonoEmpresa != null) 'telefono_empresa': telefonoEmpresa,
      if (emailEmpresa != null) 'email_empresa': emailEmpresa,
      if (nombreContacto != null) 'nombre_contacto': nombreContacto,
      if (telefonoContacto != null) 'telefono_contacto': telefonoContacto,
      if (emailContacto != null) 'email_contacto': emailContacto,
      if (estado != null) 'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProveedoresTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? ruc,
      Value<String>? nombreEmpresa,
      Value<String?>? direccion,
      Value<String?>? telefonoEmpresa,
      Value<String?>? emailEmpresa,
      Value<String?>? nombreContacto,
      Value<String?>? telefonoContacto,
      Value<String?>? emailContacto,
      Value<String>? estado,
      Value<DateTime>? createdAt}) {
    return ProveedoresTableCompanion(
      id: id ?? this.id,
      ruc: ruc ?? this.ruc,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      direccion: direccion ?? this.direccion,
      telefonoEmpresa: telefonoEmpresa ?? this.telefonoEmpresa,
      emailEmpresa: emailEmpresa ?? this.emailEmpresa,
      nombreContacto: nombreContacto ?? this.nombreContacto,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      emailContacto: emailContacto ?? this.emailContacto,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (nombreEmpresa.present) {
      map['nombre_empresa'] = Variable<String>(nombreEmpresa.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (telefonoEmpresa.present) {
      map['telefono_empresa'] = Variable<String>(telefonoEmpresa.value);
    }
    if (emailEmpresa.present) {
      map['email_empresa'] = Variable<String>(emailEmpresa.value);
    }
    if (nombreContacto.present) {
      map['nombre_contacto'] = Variable<String>(nombreContacto.value);
    }
    if (telefonoContacto.present) {
      map['telefono_contacto'] = Variable<String>(telefonoContacto.value);
    }
    if (emailContacto.present) {
      map['email_contacto'] = Variable<String>(emailContacto.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresTableCompanion(')
          ..write('id: $id, ')
          ..write('ruc: $ruc, ')
          ..write('nombreEmpresa: $nombreEmpresa, ')
          ..write('direccion: $direccion, ')
          ..write('telefonoEmpresa: $telefonoEmpresa, ')
          ..write('emailEmpresa: $emailEmpresa, ')
          ..write('nombreContacto: $nombreContacto, ')
          ..write('telefonoContacto: $telefonoContacto, ')
          ..write('emailContacto: $emailContacto, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CajasSesionesTableTable extends CajasSesionesTable
    with TableInfo<$CajasSesionesTableTable, CajasSesionesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajasSesionesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fechaAperturaMeta =
      const VerificationMeta('fechaApertura');
  @override
  late final GeneratedColumn<DateTime> fechaApertura =
      GeneratedColumn<DateTime>('fecha_apertura', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fechaCierreMeta =
      const VerificationMeta('fechaCierre');
  @override
  late final GeneratedColumn<DateTime> fechaCierre = GeneratedColumn<DateTime>(
      'fecha_cierre', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _montoInicialMeta =
      const VerificationMeta('montoInicial');
  @override
  late final GeneratedColumn<double> montoInicial = GeneratedColumn<double>(
      'monto_inicial', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _montoEsperadoEfectivoMeta =
      const VerificationMeta('montoEsperadoEfectivo');
  @override
  late final GeneratedColumn<double> montoEsperadoEfectivo =
      GeneratedColumn<double>('monto_esperado_efectivo', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _montoFinalEfectivoMeta =
      const VerificationMeta('montoFinalEfectivo');
  @override
  late final GeneratedColumn<double> montoFinalEfectivo =
      GeneratedColumn<double>('monto_final_efectivo', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _montoFinalTarjetaMeta =
      const VerificationMeta('montoFinalTarjeta');
  @override
  late final GeneratedColumn<double> montoFinalTarjeta =
      GeneratedColumn<double>('monto_final_tarjeta', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _montoFinalTransferenciaMeta =
      const VerificationMeta('montoFinalTransferencia');
  @override
  late final GeneratedColumn<double> montoFinalTransferencia =
      GeneratedColumn<double>('monto_final_transferencia', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('abierta'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        usuarioId,
        fechaApertura,
        fechaCierre,
        montoInicial,
        montoEsperadoEfectivo,
        montoFinalEfectivo,
        montoFinalTarjeta,
        montoFinalTransferencia,
        observaciones,
        estado
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cajas_sesiones';
  @override
  VerificationContext validateIntegrity(
      Insertable<CajasSesionesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
          _fechaAperturaMeta,
          fechaApertura.isAcceptableOrUnknown(
              data['fecha_apertura']!, _fechaAperturaMeta));
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
          _fechaCierreMeta,
          fechaCierre.isAcceptableOrUnknown(
              data['fecha_cierre']!, _fechaCierreMeta));
    }
    if (data.containsKey('monto_inicial')) {
      context.handle(
          _montoInicialMeta,
          montoInicial.isAcceptableOrUnknown(
              data['monto_inicial']!, _montoInicialMeta));
    }
    if (data.containsKey('monto_esperado_efectivo')) {
      context.handle(
          _montoEsperadoEfectivoMeta,
          montoEsperadoEfectivo.isAcceptableOrUnknown(
              data['monto_esperado_efectivo']!, _montoEsperadoEfectivoMeta));
    }
    if (data.containsKey('monto_final_efectivo')) {
      context.handle(
          _montoFinalEfectivoMeta,
          montoFinalEfectivo.isAcceptableOrUnknown(
              data['monto_final_efectivo']!, _montoFinalEfectivoMeta));
    }
    if (data.containsKey('monto_final_tarjeta')) {
      context.handle(
          _montoFinalTarjetaMeta,
          montoFinalTarjeta.isAcceptableOrUnknown(
              data['monto_final_tarjeta']!, _montoFinalTarjetaMeta));
    }
    if (data.containsKey('monto_final_transferencia')) {
      context.handle(
          _montoFinalTransferenciaMeta,
          montoFinalTransferencia.isAcceptableOrUnknown(
              data['monto_final_transferencia']!,
              _montoFinalTransferenciaMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CajasSesionesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CajasSesionesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usuario_id'])!,
      fechaApertura: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_apertura'])!,
      fechaCierre: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_cierre']),
      montoInicial: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_inicial'])!,
      montoEsperadoEfectivo: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}monto_esperado_efectivo'])!,
      montoFinalEfectivo: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}monto_final_efectivo']),
      montoFinalTarjeta: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}monto_final_tarjeta']),
      montoFinalTransferencia: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}monto_final_transferencia']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
    );
  }

  @override
  $CajasSesionesTableTable createAlias(String alias) {
    return $CajasSesionesTableTable(attachedDatabase, alias);
  }
}

class CajasSesionesTableData extends DataClass
    implements Insertable<CajasSesionesTableData> {
  final int id;
  final int usuarioId;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final double montoInicial;
  final double montoEsperadoEfectivo;
  final double? montoFinalEfectivo;
  final double? montoFinalTarjeta;
  final double? montoFinalTransferencia;
  final String? observaciones;
  final String estado;
  const CajasSesionesTableData(
      {required this.id,
      required this.usuarioId,
      required this.fechaApertura,
      this.fechaCierre,
      required this.montoInicial,
      required this.montoEsperadoEfectivo,
      this.montoFinalEfectivo,
      this.montoFinalTarjeta,
      this.montoFinalTransferencia,
      this.observaciones,
      required this.estado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['usuario_id'] = Variable<int>(usuarioId);
    map['fecha_apertura'] = Variable<DateTime>(fechaApertura);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre);
    }
    map['monto_inicial'] = Variable<double>(montoInicial);
    map['monto_esperado_efectivo'] = Variable<double>(montoEsperadoEfectivo);
    if (!nullToAbsent || montoFinalEfectivo != null) {
      map['monto_final_efectivo'] = Variable<double>(montoFinalEfectivo);
    }
    if (!nullToAbsent || montoFinalTarjeta != null) {
      map['monto_final_tarjeta'] = Variable<double>(montoFinalTarjeta);
    }
    if (!nullToAbsent || montoFinalTransferencia != null) {
      map['monto_final_transferencia'] =
          Variable<double>(montoFinalTransferencia);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['estado'] = Variable<String>(estado);
    return map;
  }

  CajasSesionesTableCompanion toCompanion(bool nullToAbsent) {
    return CajasSesionesTableCompanion(
      id: Value(id),
      usuarioId: Value(usuarioId),
      fechaApertura: Value(fechaApertura),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      montoInicial: Value(montoInicial),
      montoEsperadoEfectivo: Value(montoEsperadoEfectivo),
      montoFinalEfectivo: montoFinalEfectivo == null && nullToAbsent
          ? const Value.absent()
          : Value(montoFinalEfectivo),
      montoFinalTarjeta: montoFinalTarjeta == null && nullToAbsent
          ? const Value.absent()
          : Value(montoFinalTarjeta),
      montoFinalTransferencia: montoFinalTransferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(montoFinalTransferencia),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      estado: Value(estado),
    );
  }

  factory CajasSesionesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CajasSesionesTableData(
      id: serializer.fromJson<int>(json['id']),
      usuarioId: serializer.fromJson<int>(json['usuarioId']),
      fechaApertura: serializer.fromJson<DateTime>(json['fechaApertura']),
      fechaCierre: serializer.fromJson<DateTime?>(json['fechaCierre']),
      montoInicial: serializer.fromJson<double>(json['montoInicial']),
      montoEsperadoEfectivo:
          serializer.fromJson<double>(json['montoEsperadoEfectivo']),
      montoFinalEfectivo:
          serializer.fromJson<double?>(json['montoFinalEfectivo']),
      montoFinalTarjeta:
          serializer.fromJson<double?>(json['montoFinalTarjeta']),
      montoFinalTransferencia:
          serializer.fromJson<double?>(json['montoFinalTransferencia']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'usuarioId': serializer.toJson<int>(usuarioId),
      'fechaApertura': serializer.toJson<DateTime>(fechaApertura),
      'fechaCierre': serializer.toJson<DateTime?>(fechaCierre),
      'montoInicial': serializer.toJson<double>(montoInicial),
      'montoEsperadoEfectivo': serializer.toJson<double>(montoEsperadoEfectivo),
      'montoFinalEfectivo': serializer.toJson<double?>(montoFinalEfectivo),
      'montoFinalTarjeta': serializer.toJson<double?>(montoFinalTarjeta),
      'montoFinalTransferencia':
          serializer.toJson<double?>(montoFinalTransferencia),
      'observaciones': serializer.toJson<String?>(observaciones),
      'estado': serializer.toJson<String>(estado),
    };
  }

  CajasSesionesTableData copyWith(
          {int? id,
          int? usuarioId,
          DateTime? fechaApertura,
          Value<DateTime?> fechaCierre = const Value.absent(),
          double? montoInicial,
          double? montoEsperadoEfectivo,
          Value<double?> montoFinalEfectivo = const Value.absent(),
          Value<double?> montoFinalTarjeta = const Value.absent(),
          Value<double?> montoFinalTransferencia = const Value.absent(),
          Value<String?> observaciones = const Value.absent(),
          String? estado}) =>
      CajasSesionesTableData(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        fechaApertura: fechaApertura ?? this.fechaApertura,
        fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
        montoInicial: montoInicial ?? this.montoInicial,
        montoEsperadoEfectivo:
            montoEsperadoEfectivo ?? this.montoEsperadoEfectivo,
        montoFinalEfectivo: montoFinalEfectivo.present
            ? montoFinalEfectivo.value
            : this.montoFinalEfectivo,
        montoFinalTarjeta: montoFinalTarjeta.present
            ? montoFinalTarjeta.value
            : this.montoFinalTarjeta,
        montoFinalTransferencia: montoFinalTransferencia.present
            ? montoFinalTransferencia.value
            : this.montoFinalTransferencia,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        estado: estado ?? this.estado,
      );
  CajasSesionesTableData copyWithCompanion(CajasSesionesTableCompanion data) {
    return CajasSesionesTableData(
      id: data.id.present ? data.id.value : this.id,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      fechaCierre:
          data.fechaCierre.present ? data.fechaCierre.value : this.fechaCierre,
      montoInicial: data.montoInicial.present
          ? data.montoInicial.value
          : this.montoInicial,
      montoEsperadoEfectivo: data.montoEsperadoEfectivo.present
          ? data.montoEsperadoEfectivo.value
          : this.montoEsperadoEfectivo,
      montoFinalEfectivo: data.montoFinalEfectivo.present
          ? data.montoFinalEfectivo.value
          : this.montoFinalEfectivo,
      montoFinalTarjeta: data.montoFinalTarjeta.present
          ? data.montoFinalTarjeta.value
          : this.montoFinalTarjeta,
      montoFinalTransferencia: data.montoFinalTransferencia.present
          ? data.montoFinalTransferencia.value
          : this.montoFinalTransferencia,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CajasSesionesTableData(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoInicial: $montoInicial, ')
          ..write('montoEsperadoEfectivo: $montoEsperadoEfectivo, ')
          ..write('montoFinalEfectivo: $montoFinalEfectivo, ')
          ..write('montoFinalTarjeta: $montoFinalTarjeta, ')
          ..write('montoFinalTransferencia: $montoFinalTransferencia, ')
          ..write('observaciones: $observaciones, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      usuarioId,
      fechaApertura,
      fechaCierre,
      montoInicial,
      montoEsperadoEfectivo,
      montoFinalEfectivo,
      montoFinalTarjeta,
      montoFinalTransferencia,
      observaciones,
      estado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CajasSesionesTableData &&
          other.id == this.id &&
          other.usuarioId == this.usuarioId &&
          other.fechaApertura == this.fechaApertura &&
          other.fechaCierre == this.fechaCierre &&
          other.montoInicial == this.montoInicial &&
          other.montoEsperadoEfectivo == this.montoEsperadoEfectivo &&
          other.montoFinalEfectivo == this.montoFinalEfectivo &&
          other.montoFinalTarjeta == this.montoFinalTarjeta &&
          other.montoFinalTransferencia == this.montoFinalTransferencia &&
          other.observaciones == this.observaciones &&
          other.estado == this.estado);
}

class CajasSesionesTableCompanion
    extends UpdateCompanion<CajasSesionesTableData> {
  final Value<int> id;
  final Value<int> usuarioId;
  final Value<DateTime> fechaApertura;
  final Value<DateTime?> fechaCierre;
  final Value<double> montoInicial;
  final Value<double> montoEsperadoEfectivo;
  final Value<double?> montoFinalEfectivo;
  final Value<double?> montoFinalTarjeta;
  final Value<double?> montoFinalTransferencia;
  final Value<String?> observaciones;
  final Value<String> estado;
  const CajasSesionesTableCompanion({
    this.id = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.montoInicial = const Value.absent(),
    this.montoEsperadoEfectivo = const Value.absent(),
    this.montoFinalEfectivo = const Value.absent(),
    this.montoFinalTarjeta = const Value.absent(),
    this.montoFinalTransferencia = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.estado = const Value.absent(),
  });
  CajasSesionesTableCompanion.insert({
    this.id = const Value.absent(),
    required int usuarioId,
    this.fechaApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.montoInicial = const Value.absent(),
    this.montoEsperadoEfectivo = const Value.absent(),
    this.montoFinalEfectivo = const Value.absent(),
    this.montoFinalTarjeta = const Value.absent(),
    this.montoFinalTransferencia = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.estado = const Value.absent(),
  }) : usuarioId = Value(usuarioId);
  static Insertable<CajasSesionesTableData> custom({
    Expression<int>? id,
    Expression<int>? usuarioId,
    Expression<DateTime>? fechaApertura,
    Expression<DateTime>? fechaCierre,
    Expression<double>? montoInicial,
    Expression<double>? montoEsperadoEfectivo,
    Expression<double>? montoFinalEfectivo,
    Expression<double>? montoFinalTarjeta,
    Expression<double>? montoFinalTransferencia,
    Expression<String>? observaciones,
    Expression<String>? estado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (montoInicial != null) 'monto_inicial': montoInicial,
      if (montoEsperadoEfectivo != null)
        'monto_esperado_efectivo': montoEsperadoEfectivo,
      if (montoFinalEfectivo != null)
        'monto_final_efectivo': montoFinalEfectivo,
      if (montoFinalTarjeta != null) 'monto_final_tarjeta': montoFinalTarjeta,
      if (montoFinalTransferencia != null)
        'monto_final_transferencia': montoFinalTransferencia,
      if (observaciones != null) 'observaciones': observaciones,
      if (estado != null) 'estado': estado,
    });
  }

  CajasSesionesTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? usuarioId,
      Value<DateTime>? fechaApertura,
      Value<DateTime?>? fechaCierre,
      Value<double>? montoInicial,
      Value<double>? montoEsperadoEfectivo,
      Value<double?>? montoFinalEfectivo,
      Value<double?>? montoFinalTarjeta,
      Value<double?>? montoFinalTransferencia,
      Value<String?>? observaciones,
      Value<String>? estado}) {
    return CajasSesionesTableCompanion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      montoInicial: montoInicial ?? this.montoInicial,
      montoEsperadoEfectivo:
          montoEsperadoEfectivo ?? this.montoEsperadoEfectivo,
      montoFinalEfectivo: montoFinalEfectivo ?? this.montoFinalEfectivo,
      montoFinalTarjeta: montoFinalTarjeta ?? this.montoFinalTarjeta,
      montoFinalTransferencia:
          montoFinalTransferencia ?? this.montoFinalTransferencia,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<int>(usuarioId.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<DateTime>(fechaApertura.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre.value);
    }
    if (montoInicial.present) {
      map['monto_inicial'] = Variable<double>(montoInicial.value);
    }
    if (montoEsperadoEfectivo.present) {
      map['monto_esperado_efectivo'] =
          Variable<double>(montoEsperadoEfectivo.value);
    }
    if (montoFinalEfectivo.present) {
      map['monto_final_efectivo'] = Variable<double>(montoFinalEfectivo.value);
    }
    if (montoFinalTarjeta.present) {
      map['monto_final_tarjeta'] = Variable<double>(montoFinalTarjeta.value);
    }
    if (montoFinalTransferencia.present) {
      map['monto_final_transferencia'] =
          Variable<double>(montoFinalTransferencia.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajasSesionesTableCompanion(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoInicial: $montoInicial, ')
          ..write('montoEsperadoEfectivo: $montoEsperadoEfectivo, ')
          ..write('montoFinalEfectivo: $montoFinalEfectivo, ')
          ..write('montoFinalTarjeta: $montoFinalTarjeta, ')
          ..write('montoFinalTransferencia: $montoFinalTransferencia, ')
          ..write('observaciones: $observaciones, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }
}

class $ComprasTableTable extends ComprasTable
    with TableInfo<$ComprasTableTable, ComprasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _proveedorIdMeta =
      const VerificationMeta('proveedorId');
  @override
  late final GeneratedColumn<int> proveedorId = GeneratedColumn<int>(
      'proveedor_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _numeroFacturaMeta =
      const VerificationMeta('numeroFactura');
  @override
  late final GeneratedColumn<String> numeroFactura = GeneratedColumn<String>(
      'numero_factura', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 25),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _numeroAutorizacionSriMeta =
      const VerificationMeta('numeroAutorizacionSri');
  @override
  late final GeneratedColumn<String> numeroAutorizacionSri =
      GeneratedColumn<String>('numero_autorizacion_sri', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaEmisionMeta =
      const VerificationMeta('fechaEmision');
  @override
  late final GeneratedColumn<DateTime> fechaEmision = GeneratedColumn<DateTime>(
      'fecha_emision', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaRecepcionMeta =
      const VerificationMeta('fechaRecepcion');
  @override
  late final GeneratedColumn<DateTime> fechaRecepcion =
      GeneratedColumn<DateTime>('fecha_recepcion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _subtotalDoceMeta =
      const VerificationMeta('subtotalDoce');
  @override
  late final GeneratedColumn<double> subtotalDoce = GeneratedColumn<double>(
      'subtotal_doce', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _subtotalCeroMeta =
      const VerificationMeta('subtotalCero');
  @override
  late final GeneratedColumn<double> subtotalCero = GeneratedColumn<double>(
      'subtotal_cero', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _ivaMeta = const VerificationMeta('iva');
  @override
  late final GeneratedColumn<double> iva = GeneratedColumn<double>(
      'iva', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ingresada'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        proveedorId,
        numeroFactura,
        numeroAutorizacionSri,
        fechaEmision,
        fechaRecepcion,
        subtotalDoce,
        subtotalCero,
        iva,
        total,
        observaciones,
        estado
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(Insertable<ComprasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('proveedor_id')) {
      context.handle(
          _proveedorIdMeta,
          proveedorId.isAcceptableOrUnknown(
              data['proveedor_id']!, _proveedorIdMeta));
    } else if (isInserting) {
      context.missing(_proveedorIdMeta);
    }
    if (data.containsKey('numero_factura')) {
      context.handle(
          _numeroFacturaMeta,
          numeroFactura.isAcceptableOrUnknown(
              data['numero_factura']!, _numeroFacturaMeta));
    } else if (isInserting) {
      context.missing(_numeroFacturaMeta);
    }
    if (data.containsKey('numero_autorizacion_sri')) {
      context.handle(
          _numeroAutorizacionSriMeta,
          numeroAutorizacionSri.isAcceptableOrUnknown(
              data['numero_autorizacion_sri']!, _numeroAutorizacionSriMeta));
    }
    if (data.containsKey('fecha_emision')) {
      context.handle(
          _fechaEmisionMeta,
          fechaEmision.isAcceptableOrUnknown(
              data['fecha_emision']!, _fechaEmisionMeta));
    } else if (isInserting) {
      context.missing(_fechaEmisionMeta);
    }
    if (data.containsKey('fecha_recepcion')) {
      context.handle(
          _fechaRecepcionMeta,
          fechaRecepcion.isAcceptableOrUnknown(
              data['fecha_recepcion']!, _fechaRecepcionMeta));
    }
    if (data.containsKey('subtotal_doce')) {
      context.handle(
          _subtotalDoceMeta,
          subtotalDoce.isAcceptableOrUnknown(
              data['subtotal_doce']!, _subtotalDoceMeta));
    }
    if (data.containsKey('subtotal_cero')) {
      context.handle(
          _subtotalCeroMeta,
          subtotalCero.isAcceptableOrUnknown(
              data['subtotal_cero']!, _subtotalCeroMeta));
    }
    if (data.containsKey('iva')) {
      context.handle(
          _ivaMeta, iva.isAcceptableOrUnknown(data['iva']!, _ivaMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComprasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComprasTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      proveedorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}proveedor_id'])!,
      numeroFactura: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numero_factura'])!,
      numeroAutorizacionSri: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}numero_autorizacion_sri']),
      fechaEmision: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_emision'])!,
      fechaRecepcion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_recepcion'])!,
      subtotalDoce: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal_doce'])!,
      subtotalCero: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal_cero'])!,
      iva: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}iva'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
    );
  }

  @override
  $ComprasTableTable createAlias(String alias) {
    return $ComprasTableTable(attachedDatabase, alias);
  }
}

class ComprasTableData extends DataClass
    implements Insertable<ComprasTableData> {
  final int id;
  final int proveedorId;
  final String numeroFactura;
  final String? numeroAutorizacionSri;
  final DateTime fechaEmision;
  final DateTime fechaRecepcion;
  final double subtotalDoce;
  final double subtotalCero;
  final double iva;
  final double total;
  final String? observaciones;
  final String estado;
  const ComprasTableData(
      {required this.id,
      required this.proveedorId,
      required this.numeroFactura,
      this.numeroAutorizacionSri,
      required this.fechaEmision,
      required this.fechaRecepcion,
      required this.subtotalDoce,
      required this.subtotalCero,
      required this.iva,
      required this.total,
      this.observaciones,
      required this.estado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['proveedor_id'] = Variable<int>(proveedorId);
    map['numero_factura'] = Variable<String>(numeroFactura);
    if (!nullToAbsent || numeroAutorizacionSri != null) {
      map['numero_autorizacion_sri'] = Variable<String>(numeroAutorizacionSri);
    }
    map['fecha_emision'] = Variable<DateTime>(fechaEmision);
    map['fecha_recepcion'] = Variable<DateTime>(fechaRecepcion);
    map['subtotal_doce'] = Variable<double>(subtotalDoce);
    map['subtotal_cero'] = Variable<double>(subtotalCero);
    map['iva'] = Variable<double>(iva);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['estado'] = Variable<String>(estado);
    return map;
  }

  ComprasTableCompanion toCompanion(bool nullToAbsent) {
    return ComprasTableCompanion(
      id: Value(id),
      proveedorId: Value(proveedorId),
      numeroFactura: Value(numeroFactura),
      numeroAutorizacionSri: numeroAutorizacionSri == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroAutorizacionSri),
      fechaEmision: Value(fechaEmision),
      fechaRecepcion: Value(fechaRecepcion),
      subtotalDoce: Value(subtotalDoce),
      subtotalCero: Value(subtotalCero),
      iva: Value(iva),
      total: Value(total),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      estado: Value(estado),
    );
  }

  factory ComprasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComprasTableData(
      id: serializer.fromJson<int>(json['id']),
      proveedorId: serializer.fromJson<int>(json['proveedorId']),
      numeroFactura: serializer.fromJson<String>(json['numeroFactura']),
      numeroAutorizacionSri:
          serializer.fromJson<String?>(json['numeroAutorizacionSri']),
      fechaEmision: serializer.fromJson<DateTime>(json['fechaEmision']),
      fechaRecepcion: serializer.fromJson<DateTime>(json['fechaRecepcion']),
      subtotalDoce: serializer.fromJson<double>(json['subtotalDoce']),
      subtotalCero: serializer.fromJson<double>(json['subtotalCero']),
      iva: serializer.fromJson<double>(json['iva']),
      total: serializer.fromJson<double>(json['total']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'proveedorId': serializer.toJson<int>(proveedorId),
      'numeroFactura': serializer.toJson<String>(numeroFactura),
      'numeroAutorizacionSri':
          serializer.toJson<String?>(numeroAutorizacionSri),
      'fechaEmision': serializer.toJson<DateTime>(fechaEmision),
      'fechaRecepcion': serializer.toJson<DateTime>(fechaRecepcion),
      'subtotalDoce': serializer.toJson<double>(subtotalDoce),
      'subtotalCero': serializer.toJson<double>(subtotalCero),
      'iva': serializer.toJson<double>(iva),
      'total': serializer.toJson<double>(total),
      'observaciones': serializer.toJson<String?>(observaciones),
      'estado': serializer.toJson<String>(estado),
    };
  }

  ComprasTableData copyWith(
          {int? id,
          int? proveedorId,
          String? numeroFactura,
          Value<String?> numeroAutorizacionSri = const Value.absent(),
          DateTime? fechaEmision,
          DateTime? fechaRecepcion,
          double? subtotalDoce,
          double? subtotalCero,
          double? iva,
          double? total,
          Value<String?> observaciones = const Value.absent(),
          String? estado}) =>
      ComprasTableData(
        id: id ?? this.id,
        proveedorId: proveedorId ?? this.proveedorId,
        numeroFactura: numeroFactura ?? this.numeroFactura,
        numeroAutorizacionSri: numeroAutorizacionSri.present
            ? numeroAutorizacionSri.value
            : this.numeroAutorizacionSri,
        fechaEmision: fechaEmision ?? this.fechaEmision,
        fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
        subtotalDoce: subtotalDoce ?? this.subtotalDoce,
        subtotalCero: subtotalCero ?? this.subtotalCero,
        iva: iva ?? this.iva,
        total: total ?? this.total,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        estado: estado ?? this.estado,
      );
  ComprasTableData copyWithCompanion(ComprasTableCompanion data) {
    return ComprasTableData(
      id: data.id.present ? data.id.value : this.id,
      proveedorId:
          data.proveedorId.present ? data.proveedorId.value : this.proveedorId,
      numeroFactura: data.numeroFactura.present
          ? data.numeroFactura.value
          : this.numeroFactura,
      numeroAutorizacionSri: data.numeroAutorizacionSri.present
          ? data.numeroAutorizacionSri.value
          : this.numeroAutorizacionSri,
      fechaEmision: data.fechaEmision.present
          ? data.fechaEmision.value
          : this.fechaEmision,
      fechaRecepcion: data.fechaRecepcion.present
          ? data.fechaRecepcion.value
          : this.fechaRecepcion,
      subtotalDoce: data.subtotalDoce.present
          ? data.subtotalDoce.value
          : this.subtotalDoce,
      subtotalCero: data.subtotalCero.present
          ? data.subtotalCero.value
          : this.subtotalCero,
      iva: data.iva.present ? data.iva.value : this.iva,
      total: data.total.present ? data.total.value : this.total,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComprasTableData(')
          ..write('id: $id, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('numeroFactura: $numeroFactura, ')
          ..write('numeroAutorizacionSri: $numeroAutorizacionSri, ')
          ..write('fechaEmision: $fechaEmision, ')
          ..write('fechaRecepcion: $fechaRecepcion, ')
          ..write('subtotalDoce: $subtotalDoce, ')
          ..write('subtotalCero: $subtotalCero, ')
          ..write('iva: $iva, ')
          ..write('total: $total, ')
          ..write('observaciones: $observaciones, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      proveedorId,
      numeroFactura,
      numeroAutorizacionSri,
      fechaEmision,
      fechaRecepcion,
      subtotalDoce,
      subtotalCero,
      iva,
      total,
      observaciones,
      estado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComprasTableData &&
          other.id == this.id &&
          other.proveedorId == this.proveedorId &&
          other.numeroFactura == this.numeroFactura &&
          other.numeroAutorizacionSri == this.numeroAutorizacionSri &&
          other.fechaEmision == this.fechaEmision &&
          other.fechaRecepcion == this.fechaRecepcion &&
          other.subtotalDoce == this.subtotalDoce &&
          other.subtotalCero == this.subtotalCero &&
          other.iva == this.iva &&
          other.total == this.total &&
          other.observaciones == this.observaciones &&
          other.estado == this.estado);
}

class ComprasTableCompanion extends UpdateCompanion<ComprasTableData> {
  final Value<int> id;
  final Value<int> proveedorId;
  final Value<String> numeroFactura;
  final Value<String?> numeroAutorizacionSri;
  final Value<DateTime> fechaEmision;
  final Value<DateTime> fechaRecepcion;
  final Value<double> subtotalDoce;
  final Value<double> subtotalCero;
  final Value<double> iva;
  final Value<double> total;
  final Value<String?> observaciones;
  final Value<String> estado;
  const ComprasTableCompanion({
    this.id = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.numeroFactura = const Value.absent(),
    this.numeroAutorizacionSri = const Value.absent(),
    this.fechaEmision = const Value.absent(),
    this.fechaRecepcion = const Value.absent(),
    this.subtotalDoce = const Value.absent(),
    this.subtotalCero = const Value.absent(),
    this.iva = const Value.absent(),
    this.total = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.estado = const Value.absent(),
  });
  ComprasTableCompanion.insert({
    this.id = const Value.absent(),
    required int proveedorId,
    required String numeroFactura,
    this.numeroAutorizacionSri = const Value.absent(),
    required DateTime fechaEmision,
    this.fechaRecepcion = const Value.absent(),
    this.subtotalDoce = const Value.absent(),
    this.subtotalCero = const Value.absent(),
    this.iva = const Value.absent(),
    this.total = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.estado = const Value.absent(),
  })  : proveedorId = Value(proveedorId),
        numeroFactura = Value(numeroFactura),
        fechaEmision = Value(fechaEmision);
  static Insertable<ComprasTableData> custom({
    Expression<int>? id,
    Expression<int>? proveedorId,
    Expression<String>? numeroFactura,
    Expression<String>? numeroAutorizacionSri,
    Expression<DateTime>? fechaEmision,
    Expression<DateTime>? fechaRecepcion,
    Expression<double>? subtotalDoce,
    Expression<double>? subtotalCero,
    Expression<double>? iva,
    Expression<double>? total,
    Expression<String>? observaciones,
    Expression<String>? estado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (proveedorId != null) 'proveedor_id': proveedorId,
      if (numeroFactura != null) 'numero_factura': numeroFactura,
      if (numeroAutorizacionSri != null)
        'numero_autorizacion_sri': numeroAutorizacionSri,
      if (fechaEmision != null) 'fecha_emision': fechaEmision,
      if (fechaRecepcion != null) 'fecha_recepcion': fechaRecepcion,
      if (subtotalDoce != null) 'subtotal_doce': subtotalDoce,
      if (subtotalCero != null) 'subtotal_cero': subtotalCero,
      if (iva != null) 'iva': iva,
      if (total != null) 'total': total,
      if (observaciones != null) 'observaciones': observaciones,
      if (estado != null) 'estado': estado,
    });
  }

  ComprasTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? proveedorId,
      Value<String>? numeroFactura,
      Value<String?>? numeroAutorizacionSri,
      Value<DateTime>? fechaEmision,
      Value<DateTime>? fechaRecepcion,
      Value<double>? subtotalDoce,
      Value<double>? subtotalCero,
      Value<double>? iva,
      Value<double>? total,
      Value<String?>? observaciones,
      Value<String>? estado}) {
    return ComprasTableCompanion(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      numeroAutorizacionSri:
          numeroAutorizacionSri ?? this.numeroAutorizacionSri,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      subtotalDoce: subtotalDoce ?? this.subtotalDoce,
      subtotalCero: subtotalCero ?? this.subtotalCero,
      iva: iva ?? this.iva,
      total: total ?? this.total,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (proveedorId.present) {
      map['proveedor_id'] = Variable<int>(proveedorId.value);
    }
    if (numeroFactura.present) {
      map['numero_factura'] = Variable<String>(numeroFactura.value);
    }
    if (numeroAutorizacionSri.present) {
      map['numero_autorizacion_sri'] =
          Variable<String>(numeroAutorizacionSri.value);
    }
    if (fechaEmision.present) {
      map['fecha_emision'] = Variable<DateTime>(fechaEmision.value);
    }
    if (fechaRecepcion.present) {
      map['fecha_recepcion'] = Variable<DateTime>(fechaRecepcion.value);
    }
    if (subtotalDoce.present) {
      map['subtotal_doce'] = Variable<double>(subtotalDoce.value);
    }
    if (subtotalCero.present) {
      map['subtotal_cero'] = Variable<double>(subtotalCero.value);
    }
    if (iva.present) {
      map['iva'] = Variable<double>(iva.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasTableCompanion(')
          ..write('id: $id, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('numeroFactura: $numeroFactura, ')
          ..write('numeroAutorizacionSri: $numeroAutorizacionSri, ')
          ..write('fechaEmision: $fechaEmision, ')
          ..write('fechaRecepcion: $fechaRecepcion, ')
          ..write('subtotalDoce: $subtotalDoce, ')
          ..write('subtotalCero: $subtotalCero, ')
          ..write('iva: $iva, ')
          ..write('total: $total, ')
          ..write('observaciones: $observaciones, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }
}

class $DetallesCompraTableTable extends DetallesCompraTable
    with TableInfo<$DetallesCompraTableTable, DetallesCompraTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetallesCompraTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _compraIdMeta =
      const VerificationMeta('compraId');
  @override
  late final GeneratedColumn<int> compraId = GeneratedColumn<int>(
      'compra_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _presentacionIdMeta =
      const VerificationMeta('presentacionId');
  @override
  late final GeneratedColumn<int> presentacionId = GeneratedColumn<int>(
      'presentacion_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
      'lote', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fechaVencimientoMeta =
      const VerificationMeta('fechaVencimiento');
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>('fecha_vencimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cantidadCajasMeta =
      const VerificationMeta('cantidadCajas');
  @override
  late final GeneratedColumn<double> cantidadCajas = GeneratedColumn<double>(
      'cantidad_cajas', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cantidadUnidadesMeta =
      const VerificationMeta('cantidadUnidades');
  @override
  late final GeneratedColumn<double> cantidadUnidades = GeneratedColumn<double>(
      'cantidad_unidades', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costoCajaMeta =
      const VerificationMeta('costoCaja');
  @override
  late final GeneratedColumn<double> costoCaja = GeneratedColumn<double>(
      'costo_caja', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costoUnitarioMeta =
      const VerificationMeta('costoUnitario');
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
      'costo_unitario', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cumpleRegistroSanitarioMeta =
      const VerificationMeta('cumpleRegistroSanitario');
  @override
  late final GeneratedColumn<bool> cumpleRegistroSanitario =
      GeneratedColumn<bool>('cumple_registro_sanitario', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("cumple_registro_sanitario" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _cumpleEmpaqueMeta =
      const VerificationMeta('cumpleEmpaque');
  @override
  late final GeneratedColumn<bool> cumpleEmpaque = GeneratedColumn<bool>(
      'cumple_empaque', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cumple_empaque" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _temperaturaRecepcionMeta =
      const VerificationMeta('temperaturaRecepcion');
  @override
  late final GeneratedColumn<double> temperaturaRecepcion =
      GeneratedColumn<double>('temperatura_recepcion', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        compraId,
        presentacionId,
        lote,
        fechaVencimiento,
        cantidadCajas,
        cantidadUnidades,
        costoCaja,
        costoUnitario,
        subtotal,
        cumpleRegistroSanitario,
        cumpleEmpaque,
        temperaturaRecepcion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalles_compra';
  @override
  VerificationContext validateIntegrity(
      Insertable<DetallesCompraTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('compra_id')) {
      context.handle(_compraIdMeta,
          compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta));
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('presentacion_id')) {
      context.handle(
          _presentacionIdMeta,
          presentacionId.isAcceptableOrUnknown(
              data['presentacion_id']!, _presentacionIdMeta));
    } else if (isInserting) {
      context.missing(_presentacionIdMeta);
    }
    if (data.containsKey('lote')) {
      context.handle(
          _loteMeta, lote.isAcceptableOrUnknown(data['lote']!, _loteMeta));
    } else if (isInserting) {
      context.missing(_loteMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
          _fechaVencimientoMeta,
          fechaVencimiento.isAcceptableOrUnknown(
              data['fecha_vencimiento']!, _fechaVencimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('cantidad_cajas')) {
      context.handle(
          _cantidadCajasMeta,
          cantidadCajas.isAcceptableOrUnknown(
              data['cantidad_cajas']!, _cantidadCajasMeta));
    }
    if (data.containsKey('cantidad_unidades')) {
      context.handle(
          _cantidadUnidadesMeta,
          cantidadUnidades.isAcceptableOrUnknown(
              data['cantidad_unidades']!, _cantidadUnidadesMeta));
    }
    if (data.containsKey('costo_caja')) {
      context.handle(_costoCajaMeta,
          costoCaja.isAcceptableOrUnknown(data['costo_caja']!, _costoCajaMeta));
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
          _costoUnitarioMeta,
          costoUnitario.isAcceptableOrUnknown(
              data['costo_unitario']!, _costoUnitarioMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('cumple_registro_sanitario')) {
      context.handle(
          _cumpleRegistroSanitarioMeta,
          cumpleRegistroSanitario.isAcceptableOrUnknown(
              data['cumple_registro_sanitario']!,
              _cumpleRegistroSanitarioMeta));
    }
    if (data.containsKey('cumple_empaque')) {
      context.handle(
          _cumpleEmpaqueMeta,
          cumpleEmpaque.isAcceptableOrUnknown(
              data['cumple_empaque']!, _cumpleEmpaqueMeta));
    }
    if (data.containsKey('temperatura_recepcion')) {
      context.handle(
          _temperaturaRecepcionMeta,
          temperaturaRecepcion.isAcceptableOrUnknown(
              data['temperatura_recepcion']!, _temperaturaRecepcionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetallesCompraTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetallesCompraTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      compraId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}compra_id'])!,
      presentacionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}presentacion_id'])!,
      lote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote'])!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_vencimiento'])!,
      cantidadCajas: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cantidad_cajas'])!,
      cantidadUnidades: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}cantidad_unidades'])!,
      costoCaja: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}costo_caja'])!,
      costoUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}costo_unitario'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      cumpleRegistroSanitario: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}cumple_registro_sanitario'])!,
      cumpleEmpaque: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cumple_empaque'])!,
      temperaturaRecepcion: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}temperatura_recepcion']),
    );
  }

  @override
  $DetallesCompraTableTable createAlias(String alias) {
    return $DetallesCompraTableTable(attachedDatabase, alias);
  }
}

class DetallesCompraTableData extends DataClass
    implements Insertable<DetallesCompraTableData> {
  final int id;
  final int compraId;
  final int presentacionId;
  final String lote;
  final DateTime fechaVencimiento;
  final double cantidadCajas;
  final double cantidadUnidades;
  final double costoCaja;
  final double costoUnitario;
  final double subtotal;
  final bool cumpleRegistroSanitario;
  final bool cumpleEmpaque;
  final double? temperaturaRecepcion;
  const DetallesCompraTableData(
      {required this.id,
      required this.compraId,
      required this.presentacionId,
      required this.lote,
      required this.fechaVencimiento,
      required this.cantidadCajas,
      required this.cantidadUnidades,
      required this.costoCaja,
      required this.costoUnitario,
      required this.subtotal,
      required this.cumpleRegistroSanitario,
      required this.cumpleEmpaque,
      this.temperaturaRecepcion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['compra_id'] = Variable<int>(compraId);
    map['presentacion_id'] = Variable<int>(presentacionId);
    map['lote'] = Variable<String>(lote);
    map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    map['cantidad_cajas'] = Variable<double>(cantidadCajas);
    map['cantidad_unidades'] = Variable<double>(cantidadUnidades);
    map['costo_caja'] = Variable<double>(costoCaja);
    map['costo_unitario'] = Variable<double>(costoUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    map['cumple_registro_sanitario'] = Variable<bool>(cumpleRegistroSanitario);
    map['cumple_empaque'] = Variable<bool>(cumpleEmpaque);
    if (!nullToAbsent || temperaturaRecepcion != null) {
      map['temperatura_recepcion'] = Variable<double>(temperaturaRecepcion);
    }
    return map;
  }

  DetallesCompraTableCompanion toCompanion(bool nullToAbsent) {
    return DetallesCompraTableCompanion(
      id: Value(id),
      compraId: Value(compraId),
      presentacionId: Value(presentacionId),
      lote: Value(lote),
      fechaVencimiento: Value(fechaVencimiento),
      cantidadCajas: Value(cantidadCajas),
      cantidadUnidades: Value(cantidadUnidades),
      costoCaja: Value(costoCaja),
      costoUnitario: Value(costoUnitario),
      subtotal: Value(subtotal),
      cumpleRegistroSanitario: Value(cumpleRegistroSanitario),
      cumpleEmpaque: Value(cumpleEmpaque),
      temperaturaRecepcion: temperaturaRecepcion == null && nullToAbsent
          ? const Value.absent()
          : Value(temperaturaRecepcion),
    );
  }

  factory DetallesCompraTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetallesCompraTableData(
      id: serializer.fromJson<int>(json['id']),
      compraId: serializer.fromJson<int>(json['compraId']),
      presentacionId: serializer.fromJson<int>(json['presentacionId']),
      lote: serializer.fromJson<String>(json['lote']),
      fechaVencimiento: serializer.fromJson<DateTime>(json['fechaVencimiento']),
      cantidadCajas: serializer.fromJson<double>(json['cantidadCajas']),
      cantidadUnidades: serializer.fromJson<double>(json['cantidadUnidades']),
      costoCaja: serializer.fromJson<double>(json['costoCaja']),
      costoUnitario: serializer.fromJson<double>(json['costoUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      cumpleRegistroSanitario:
          serializer.fromJson<bool>(json['cumpleRegistroSanitario']),
      cumpleEmpaque: serializer.fromJson<bool>(json['cumpleEmpaque']),
      temperaturaRecepcion:
          serializer.fromJson<double?>(json['temperaturaRecepcion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'compraId': serializer.toJson<int>(compraId),
      'presentacionId': serializer.toJson<int>(presentacionId),
      'lote': serializer.toJson<String>(lote),
      'fechaVencimiento': serializer.toJson<DateTime>(fechaVencimiento),
      'cantidadCajas': serializer.toJson<double>(cantidadCajas),
      'cantidadUnidades': serializer.toJson<double>(cantidadUnidades),
      'costoCaja': serializer.toJson<double>(costoCaja),
      'costoUnitario': serializer.toJson<double>(costoUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
      'cumpleRegistroSanitario':
          serializer.toJson<bool>(cumpleRegistroSanitario),
      'cumpleEmpaque': serializer.toJson<bool>(cumpleEmpaque),
      'temperaturaRecepcion': serializer.toJson<double?>(temperaturaRecepcion),
    };
  }

  DetallesCompraTableData copyWith(
          {int? id,
          int? compraId,
          int? presentacionId,
          String? lote,
          DateTime? fechaVencimiento,
          double? cantidadCajas,
          double? cantidadUnidades,
          double? costoCaja,
          double? costoUnitario,
          double? subtotal,
          bool? cumpleRegistroSanitario,
          bool? cumpleEmpaque,
          Value<double?> temperaturaRecepcion = const Value.absent()}) =>
      DetallesCompraTableData(
        id: id ?? this.id,
        compraId: compraId ?? this.compraId,
        presentacionId: presentacionId ?? this.presentacionId,
        lote: lote ?? this.lote,
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
        cantidadCajas: cantidadCajas ?? this.cantidadCajas,
        cantidadUnidades: cantidadUnidades ?? this.cantidadUnidades,
        costoCaja: costoCaja ?? this.costoCaja,
        costoUnitario: costoUnitario ?? this.costoUnitario,
        subtotal: subtotal ?? this.subtotal,
        cumpleRegistroSanitario:
            cumpleRegistroSanitario ?? this.cumpleRegistroSanitario,
        cumpleEmpaque: cumpleEmpaque ?? this.cumpleEmpaque,
        temperaturaRecepcion: temperaturaRecepcion.present
            ? temperaturaRecepcion.value
            : this.temperaturaRecepcion,
      );
  DetallesCompraTableData copyWithCompanion(DetallesCompraTableCompanion data) {
    return DetallesCompraTableData(
      id: data.id.present ? data.id.value : this.id,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      presentacionId: data.presentacionId.present
          ? data.presentacionId.value
          : this.presentacionId,
      lote: data.lote.present ? data.lote.value : this.lote,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      cantidadCajas: data.cantidadCajas.present
          ? data.cantidadCajas.value
          : this.cantidadCajas,
      cantidadUnidades: data.cantidadUnidades.present
          ? data.cantidadUnidades.value
          : this.cantidadUnidades,
      costoCaja: data.costoCaja.present ? data.costoCaja.value : this.costoCaja,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      cumpleRegistroSanitario: data.cumpleRegistroSanitario.present
          ? data.cumpleRegistroSanitario.value
          : this.cumpleRegistroSanitario,
      cumpleEmpaque: data.cumpleEmpaque.present
          ? data.cumpleEmpaque.value
          : this.cumpleEmpaque,
      temperaturaRecepcion: data.temperaturaRecepcion.present
          ? data.temperaturaRecepcion.value
          : this.temperaturaRecepcion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetallesCompraTableData(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('lote: $lote, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('cantidadCajas: $cantidadCajas, ')
          ..write('cantidadUnidades: $cantidadUnidades, ')
          ..write('costoCaja: $costoCaja, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('cumpleRegistroSanitario: $cumpleRegistroSanitario, ')
          ..write('cumpleEmpaque: $cumpleEmpaque, ')
          ..write('temperaturaRecepcion: $temperaturaRecepcion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      compraId,
      presentacionId,
      lote,
      fechaVencimiento,
      cantidadCajas,
      cantidadUnidades,
      costoCaja,
      costoUnitario,
      subtotal,
      cumpleRegistroSanitario,
      cumpleEmpaque,
      temperaturaRecepcion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetallesCompraTableData &&
          other.id == this.id &&
          other.compraId == this.compraId &&
          other.presentacionId == this.presentacionId &&
          other.lote == this.lote &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.cantidadCajas == this.cantidadCajas &&
          other.cantidadUnidades == this.cantidadUnidades &&
          other.costoCaja == this.costoCaja &&
          other.costoUnitario == this.costoUnitario &&
          other.subtotal == this.subtotal &&
          other.cumpleRegistroSanitario == this.cumpleRegistroSanitario &&
          other.cumpleEmpaque == this.cumpleEmpaque &&
          other.temperaturaRecepcion == this.temperaturaRecepcion);
}

class DetallesCompraTableCompanion
    extends UpdateCompanion<DetallesCompraTableData> {
  final Value<int> id;
  final Value<int> compraId;
  final Value<int> presentacionId;
  final Value<String> lote;
  final Value<DateTime> fechaVencimiento;
  final Value<double> cantidadCajas;
  final Value<double> cantidadUnidades;
  final Value<double> costoCaja;
  final Value<double> costoUnitario;
  final Value<double> subtotal;
  final Value<bool> cumpleRegistroSanitario;
  final Value<bool> cumpleEmpaque;
  final Value<double?> temperaturaRecepcion;
  const DetallesCompraTableCompanion({
    this.id = const Value.absent(),
    this.compraId = const Value.absent(),
    this.presentacionId = const Value.absent(),
    this.lote = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.cantidadCajas = const Value.absent(),
    this.cantidadUnidades = const Value.absent(),
    this.costoCaja = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.cumpleRegistroSanitario = const Value.absent(),
    this.cumpleEmpaque = const Value.absent(),
    this.temperaturaRecepcion = const Value.absent(),
  });
  DetallesCompraTableCompanion.insert({
    this.id = const Value.absent(),
    required int compraId,
    required int presentacionId,
    required String lote,
    required DateTime fechaVencimiento,
    this.cantidadCajas = const Value.absent(),
    this.cantidadUnidades = const Value.absent(),
    this.costoCaja = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.cumpleRegistroSanitario = const Value.absent(),
    this.cumpleEmpaque = const Value.absent(),
    this.temperaturaRecepcion = const Value.absent(),
  })  : compraId = Value(compraId),
        presentacionId = Value(presentacionId),
        lote = Value(lote),
        fechaVencimiento = Value(fechaVencimiento);
  static Insertable<DetallesCompraTableData> custom({
    Expression<int>? id,
    Expression<int>? compraId,
    Expression<int>? presentacionId,
    Expression<String>? lote,
    Expression<DateTime>? fechaVencimiento,
    Expression<double>? cantidadCajas,
    Expression<double>? cantidadUnidades,
    Expression<double>? costoCaja,
    Expression<double>? costoUnitario,
    Expression<double>? subtotal,
    Expression<bool>? cumpleRegistroSanitario,
    Expression<bool>? cumpleEmpaque,
    Expression<double>? temperaturaRecepcion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compraId != null) 'compra_id': compraId,
      if (presentacionId != null) 'presentacion_id': presentacionId,
      if (lote != null) 'lote': lote,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (cantidadCajas != null) 'cantidad_cajas': cantidadCajas,
      if (cantidadUnidades != null) 'cantidad_unidades': cantidadUnidades,
      if (costoCaja != null) 'costo_caja': costoCaja,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (subtotal != null) 'subtotal': subtotal,
      if (cumpleRegistroSanitario != null)
        'cumple_registro_sanitario': cumpleRegistroSanitario,
      if (cumpleEmpaque != null) 'cumple_empaque': cumpleEmpaque,
      if (temperaturaRecepcion != null)
        'temperatura_recepcion': temperaturaRecepcion,
    });
  }

  DetallesCompraTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? compraId,
      Value<int>? presentacionId,
      Value<String>? lote,
      Value<DateTime>? fechaVencimiento,
      Value<double>? cantidadCajas,
      Value<double>? cantidadUnidades,
      Value<double>? costoCaja,
      Value<double>? costoUnitario,
      Value<double>? subtotal,
      Value<bool>? cumpleRegistroSanitario,
      Value<bool>? cumpleEmpaque,
      Value<double?>? temperaturaRecepcion}) {
    return DetallesCompraTableCompanion(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      presentacionId: presentacionId ?? this.presentacionId,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      cantidadCajas: cantidadCajas ?? this.cantidadCajas,
      cantidadUnidades: cantidadUnidades ?? this.cantidadUnidades,
      costoCaja: costoCaja ?? this.costoCaja,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      subtotal: subtotal ?? this.subtotal,
      cumpleRegistroSanitario:
          cumpleRegistroSanitario ?? this.cumpleRegistroSanitario,
      cumpleEmpaque: cumpleEmpaque ?? this.cumpleEmpaque,
      temperaturaRecepcion: temperaturaRecepcion ?? this.temperaturaRecepcion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<int>(compraId.value);
    }
    if (presentacionId.present) {
      map['presentacion_id'] = Variable<int>(presentacionId.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (cantidadCajas.present) {
      map['cantidad_cajas'] = Variable<double>(cantidadCajas.value);
    }
    if (cantidadUnidades.present) {
      map['cantidad_unidades'] = Variable<double>(cantidadUnidades.value);
    }
    if (costoCaja.present) {
      map['costo_caja'] = Variable<double>(costoCaja.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (cumpleRegistroSanitario.present) {
      map['cumple_registro_sanitario'] =
          Variable<bool>(cumpleRegistroSanitario.value);
    }
    if (cumpleEmpaque.present) {
      map['cumple_empaque'] = Variable<bool>(cumpleEmpaque.value);
    }
    if (temperaturaRecepcion.present) {
      map['temperatura_recepcion'] =
          Variable<double>(temperaturaRecepcion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetallesCompraTableCompanion(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('presentacionId: $presentacionId, ')
          ..write('lote: $lote, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('cantidadCajas: $cantidadCajas, ')
          ..write('cantidadUnidades: $cantidadUnidades, ')
          ..write('costoCaja: $costoCaja, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('cumpleRegistroSanitario: $cumpleRegistroSanitario, ')
          ..write('cumpleEmpaque: $cumpleEmpaque, ')
          ..write('temperaturaRecepcion: $temperaturaRecepcion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTableTable productosTable = $ProductosTableTable(this);
  late final $PresentacionesTableTable presentacionesTable =
      $PresentacionesTableTable(this);
  late final $LotesTableTable lotesTable = $LotesTableTable(this);
  late final $MovimientosStockTableTable movimientosStockTable =
      $MovimientosStockTableTable(this);
  late final $VentasTableTable ventasTable = $VentasTableTable(this);
  late final $DetallesVentaTableTable detallesVentaTable =
      $DetallesVentaTableTable(this);
  late final $ClientesTableTable clientesTable = $ClientesTableTable(this);
  late final $ProveedoresTableTable proveedoresTable =
      $ProveedoresTableTable(this);
  late final $CajasSesionesTableTable cajasSesionesTable =
      $CajasSesionesTableTable(this);
  late final $ComprasTableTable comprasTable = $ComprasTableTable(this);
  late final $DetallesCompraTableTable detallesCompraTable =
      $DetallesCompraTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        productosTable,
        presentacionesTable,
        lotesTable,
        movimientosStockTable,
        ventasTable,
        detallesVentaTable,
        clientesTable,
        proveedoresTable,
        cajasSesionesTable,
        comprasTable,
        detallesCompraTable
      ];
}

typedef $$ProductosTableTableCreateCompanionBuilder = ProductosTableCompanion
    Function({
  Value<int> id,
  Value<String?> codigoBarras,
  required String nombreComercial,
  Value<String?> principioActivo,
  Value<String?> concentracion,
  Value<int?> laboratorioId,
  Value<int?> categoriaId,
  Value<bool> requiereReceta,
  Value<bool> esPsicotropico,
  Value<bool> esAntibiotico,
  Value<String> estado,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$ProductosTableTableUpdateCompanionBuilder = ProductosTableCompanion
    Function({
  Value<int> id,
  Value<String?> codigoBarras,
  Value<String> nombreComercial,
  Value<String?> principioActivo,
  Value<String?> concentracion,
  Value<int?> laboratorioId,
  Value<int?> categoriaId,
  Value<bool> requiereReceta,
  Value<bool> esPsicotropico,
  Value<bool> esAntibiotico,
  Value<String> estado,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});

class $$ProductosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreComercial => $composableBuilder(
      column: $table.nombreComercial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get principioActivo => $composableBuilder(
      column: $table.principioActivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concentracion => $composableBuilder(
      column: $table.concentracion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get laboratorioId => $composableBuilder(
      column: $table.laboratorioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiereReceta => $composableBuilder(
      column: $table.requiereReceta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esPsicotropico => $composableBuilder(
      column: $table.esPsicotropico,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esAntibiotico => $composableBuilder(
      column: $table.esAntibiotico, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreComercial => $composableBuilder(
      column: $table.nombreComercial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get principioActivo => $composableBuilder(
      column: $table.principioActivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concentracion => $composableBuilder(
      column: $table.concentracion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get laboratorioId => $composableBuilder(
      column: $table.laboratorioId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiereReceta => $composableBuilder(
      column: $table.requiereReceta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esPsicotropico => $composableBuilder(
      column: $table.esPsicotropico,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esAntibiotico => $composableBuilder(
      column: $table.esAntibiotico,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => column);

  GeneratedColumn<String> get nombreComercial => $composableBuilder(
      column: $table.nombreComercial, builder: (column) => column);

  GeneratedColumn<String> get principioActivo => $composableBuilder(
      column: $table.principioActivo, builder: (column) => column);

  GeneratedColumn<String> get concentracion => $composableBuilder(
      column: $table.concentracion, builder: (column) => column);

  GeneratedColumn<int> get laboratorioId => $composableBuilder(
      column: $table.laboratorioId, builder: (column) => column);

  GeneratedColumn<int> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => column);

  GeneratedColumn<bool> get requiereReceta => $composableBuilder(
      column: $table.requiereReceta, builder: (column) => column);

  GeneratedColumn<bool> get esPsicotropico => $composableBuilder(
      column: $table.esPsicotropico, builder: (column) => column);

  GeneratedColumn<bool> get esAntibiotico => $composableBuilder(
      column: $table.esAntibiotico, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductosTableTable,
    ProductosTableData,
    $$ProductosTableTableFilterComposer,
    $$ProductosTableTableOrderingComposer,
    $$ProductosTableTableAnnotationComposer,
    $$ProductosTableTableCreateCompanionBuilder,
    $$ProductosTableTableUpdateCompanionBuilder,
    (
      ProductosTableData,
      BaseReferences<_$AppDatabase, $ProductosTableTable, ProductosTableData>
    ),
    ProductosTableData,
    PrefetchHooks Function()> {
  $$ProductosTableTableTableManager(
      _$AppDatabase db, $ProductosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            Value<String> nombreComercial = const Value.absent(),
            Value<String?> principioActivo = const Value.absent(),
            Value<String?> concentracion = const Value.absent(),
            Value<int?> laboratorioId = const Value.absent(),
            Value<int?> categoriaId = const Value.absent(),
            Value<bool> requiereReceta = const Value.absent(),
            Value<bool> esPsicotropico = const Value.absent(),
            Value<bool> esAntibiotico = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ProductosTableCompanion(
            id: id,
            codigoBarras: codigoBarras,
            nombreComercial: nombreComercial,
            principioActivo: principioActivo,
            concentracion: concentracion,
            laboratorioId: laboratorioId,
            categoriaId: categoriaId,
            requiereReceta: requiereReceta,
            esPsicotropico: esPsicotropico,
            esAntibiotico: esAntibiotico,
            estado: estado,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            required String nombreComercial,
            Value<String?> principioActivo = const Value.absent(),
            Value<String?> concentracion = const Value.absent(),
            Value<int?> laboratorioId = const Value.absent(),
            Value<int?> categoriaId = const Value.absent(),
            Value<bool> requiereReceta = const Value.absent(),
            Value<bool> esPsicotropico = const Value.absent(),
            Value<bool> esAntibiotico = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ProductosTableCompanion.insert(
            id: id,
            codigoBarras: codigoBarras,
            nombreComercial: nombreComercial,
            principioActivo: principioActivo,
            concentracion: concentracion,
            laboratorioId: laboratorioId,
            categoriaId: categoriaId,
            requiereReceta: requiereReceta,
            esPsicotropico: esPsicotropico,
            esAntibiotico: esAntibiotico,
            estado: estado,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductosTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductosTableTable,
    ProductosTableData,
    $$ProductosTableTableFilterComposer,
    $$ProductosTableTableOrderingComposer,
    $$ProductosTableTableAnnotationComposer,
    $$ProductosTableTableCreateCompanionBuilder,
    $$ProductosTableTableUpdateCompanionBuilder,
    (
      ProductosTableData,
      BaseReferences<_$AppDatabase, $ProductosTableTable, ProductosTableData>
    ),
    ProductosTableData,
    PrefetchHooks Function()>;
typedef $$PresentacionesTableTableCreateCompanionBuilder
    = PresentacionesTableCompanion Function({
  Value<int> id,
  required int productoId,
  required String nombreDescriptivo,
  Value<int> unidadesPorCaja,
  Value<double> precioCompraCaja,
  Value<double> precioVentaCaja,
  Value<double> precioVentaFraccion,
  Value<int> stockMinimo,
  Value<String?> codigoBarras,
  Value<bool> tieneIva,
});
typedef $$PresentacionesTableTableUpdateCompanionBuilder
    = PresentacionesTableCompanion Function({
  Value<int> id,
  Value<int> productoId,
  Value<String> nombreDescriptivo,
  Value<int> unidadesPorCaja,
  Value<double> precioCompraCaja,
  Value<double> precioVentaCaja,
  Value<double> precioVentaFraccion,
  Value<int> stockMinimo,
  Value<String?> codigoBarras,
  Value<bool> tieneIva,
});

class $$PresentacionesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PresentacionesTableTable> {
  $$PresentacionesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreDescriptivo => $composableBuilder(
      column: $table.nombreDescriptivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unidadesPorCaja => $composableBuilder(
      column: $table.unidadesPorCaja,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioVentaCaja => $composableBuilder(
      column: $table.precioVentaCaja,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioVentaFraccion => $composableBuilder(
      column: $table.precioVentaFraccion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get tieneIva => $composableBuilder(
      column: $table.tieneIva, builder: (column) => ColumnFilters(column));
}

class $$PresentacionesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PresentacionesTableTable> {
  $$PresentacionesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreDescriptivo => $composableBuilder(
      column: $table.nombreDescriptivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unidadesPorCaja => $composableBuilder(
      column: $table.unidadesPorCaja,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioVentaCaja => $composableBuilder(
      column: $table.precioVentaCaja,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioVentaFraccion => $composableBuilder(
      column: $table.precioVentaFraccion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get tieneIva => $composableBuilder(
      column: $table.tieneIva, builder: (column) => ColumnOrderings(column));
}

class $$PresentacionesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresentacionesTableTable> {
  $$PresentacionesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => column);

  GeneratedColumn<String> get nombreDescriptivo => $composableBuilder(
      column: $table.nombreDescriptivo, builder: (column) => column);

  GeneratedColumn<int> get unidadesPorCaja => $composableBuilder(
      column: $table.unidadesPorCaja, builder: (column) => column);

  GeneratedColumn<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja, builder: (column) => column);

  GeneratedColumn<double> get precioVentaCaja => $composableBuilder(
      column: $table.precioVentaCaja, builder: (column) => column);

  GeneratedColumn<double> get precioVentaFraccion => $composableBuilder(
      column: $table.precioVentaFraccion, builder: (column) => column);

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
      column: $table.codigoBarras, builder: (column) => column);

  GeneratedColumn<bool> get tieneIva =>
      $composableBuilder(column: $table.tieneIva, builder: (column) => column);
}

class $$PresentacionesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PresentacionesTableTable,
    PresentacionesTableData,
    $$PresentacionesTableTableFilterComposer,
    $$PresentacionesTableTableOrderingComposer,
    $$PresentacionesTableTableAnnotationComposer,
    $$PresentacionesTableTableCreateCompanionBuilder,
    $$PresentacionesTableTableUpdateCompanionBuilder,
    (
      PresentacionesTableData,
      BaseReferences<_$AppDatabase, $PresentacionesTableTable,
          PresentacionesTableData>
    ),
    PresentacionesTableData,
    PrefetchHooks Function()> {
  $$PresentacionesTableTableTableManager(
      _$AppDatabase db, $PresentacionesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresentacionesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresentacionesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresentacionesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productoId = const Value.absent(),
            Value<String> nombreDescriptivo = const Value.absent(),
            Value<int> unidadesPorCaja = const Value.absent(),
            Value<double> precioCompraCaja = const Value.absent(),
            Value<double> precioVentaCaja = const Value.absent(),
            Value<double> precioVentaFraccion = const Value.absent(),
            Value<int> stockMinimo = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            Value<bool> tieneIva = const Value.absent(),
          }) =>
              PresentacionesTableCompanion(
            id: id,
            productoId: productoId,
            nombreDescriptivo: nombreDescriptivo,
            unidadesPorCaja: unidadesPorCaja,
            precioCompraCaja: precioCompraCaja,
            precioVentaCaja: precioVentaCaja,
            precioVentaFraccion: precioVentaFraccion,
            stockMinimo: stockMinimo,
            codigoBarras: codigoBarras,
            tieneIva: tieneIva,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productoId,
            required String nombreDescriptivo,
            Value<int> unidadesPorCaja = const Value.absent(),
            Value<double> precioCompraCaja = const Value.absent(),
            Value<double> precioVentaCaja = const Value.absent(),
            Value<double> precioVentaFraccion = const Value.absent(),
            Value<int> stockMinimo = const Value.absent(),
            Value<String?> codigoBarras = const Value.absent(),
            Value<bool> tieneIva = const Value.absent(),
          }) =>
              PresentacionesTableCompanion.insert(
            id: id,
            productoId: productoId,
            nombreDescriptivo: nombreDescriptivo,
            unidadesPorCaja: unidadesPorCaja,
            precioCompraCaja: precioCompraCaja,
            precioVentaCaja: precioVentaCaja,
            precioVentaFraccion: precioVentaFraccion,
            stockMinimo: stockMinimo,
            codigoBarras: codigoBarras,
            tieneIva: tieneIva,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PresentacionesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PresentacionesTableTable,
    PresentacionesTableData,
    $$PresentacionesTableTableFilterComposer,
    $$PresentacionesTableTableOrderingComposer,
    $$PresentacionesTableTableAnnotationComposer,
    $$PresentacionesTableTableCreateCompanionBuilder,
    $$PresentacionesTableTableUpdateCompanionBuilder,
    (
      PresentacionesTableData,
      BaseReferences<_$AppDatabase, $PresentacionesTableTable,
          PresentacionesTableData>
    ),
    PresentacionesTableData,
    PrefetchHooks Function()>;
typedef $$LotesTableTableCreateCompanionBuilder = LotesTableCompanion Function({
  Value<int> id,
  required int presentacionId,
  required String lote,
  required DateTime fechaVencimiento,
  Value<DateTime> fechaIngreso,
  Value<double> stockActual,
  Value<double> precioCompraCaja,
  Value<double> precioCompraUnitario,
  Value<String?> ubicacion,
});
typedef $$LotesTableTableUpdateCompanionBuilder = LotesTableCompanion Function({
  Value<int> id,
  Value<int> presentacionId,
  Value<String> lote,
  Value<DateTime> fechaVencimiento,
  Value<DateTime> fechaIngreso,
  Value<double> stockActual,
  Value<double> precioCompraCaja,
  Value<double> precioCompraUnitario,
  Value<String?> ubicacion,
});

class $$LotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaIngreso => $composableBuilder(
      column: $table.fechaIngreso, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioCompraUnitario => $composableBuilder(
      column: $table.precioCompraUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ubicacion => $composableBuilder(
      column: $table.ubicacion, builder: (column) => ColumnFilters(column));
}

class $$LotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaIngreso => $composableBuilder(
      column: $table.fechaIngreso,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioCompraUnitario => $composableBuilder(
      column: $table.precioCompraUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ubicacion => $composableBuilder(
      column: $table.ubicacion, builder: (column) => ColumnOrderings(column));
}

class $$LotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId, builder: (column) => column);

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaIngreso => $composableBuilder(
      column: $table.fechaIngreso, builder: (column) => column);

  GeneratedColumn<double> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => column);

  GeneratedColumn<double> get precioCompraCaja => $composableBuilder(
      column: $table.precioCompraCaja, builder: (column) => column);

  GeneratedColumn<double> get precioCompraUnitario => $composableBuilder(
      column: $table.precioCompraUnitario, builder: (column) => column);

  GeneratedColumn<String> get ubicacion =>
      $composableBuilder(column: $table.ubicacion, builder: (column) => column);
}

class $$LotesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LotesTableTable,
    LotesTableData,
    $$LotesTableTableFilterComposer,
    $$LotesTableTableOrderingComposer,
    $$LotesTableTableAnnotationComposer,
    $$LotesTableTableCreateCompanionBuilder,
    $$LotesTableTableUpdateCompanionBuilder,
    (
      LotesTableData,
      BaseReferences<_$AppDatabase, $LotesTableTable, LotesTableData>
    ),
    LotesTableData,
    PrefetchHooks Function()> {
  $$LotesTableTableTableManager(_$AppDatabase db, $LotesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> presentacionId = const Value.absent(),
            Value<String> lote = const Value.absent(),
            Value<DateTime> fechaVencimiento = const Value.absent(),
            Value<DateTime> fechaIngreso = const Value.absent(),
            Value<double> stockActual = const Value.absent(),
            Value<double> precioCompraCaja = const Value.absent(),
            Value<double> precioCompraUnitario = const Value.absent(),
            Value<String?> ubicacion = const Value.absent(),
          }) =>
              LotesTableCompanion(
            id: id,
            presentacionId: presentacionId,
            lote: lote,
            fechaVencimiento: fechaVencimiento,
            fechaIngreso: fechaIngreso,
            stockActual: stockActual,
            precioCompraCaja: precioCompraCaja,
            precioCompraUnitario: precioCompraUnitario,
            ubicacion: ubicacion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int presentacionId,
            required String lote,
            required DateTime fechaVencimiento,
            Value<DateTime> fechaIngreso = const Value.absent(),
            Value<double> stockActual = const Value.absent(),
            Value<double> precioCompraCaja = const Value.absent(),
            Value<double> precioCompraUnitario = const Value.absent(),
            Value<String?> ubicacion = const Value.absent(),
          }) =>
              LotesTableCompanion.insert(
            id: id,
            presentacionId: presentacionId,
            lote: lote,
            fechaVencimiento: fechaVencimiento,
            fechaIngreso: fechaIngreso,
            stockActual: stockActual,
            precioCompraCaja: precioCompraCaja,
            precioCompraUnitario: precioCompraUnitario,
            ubicacion: ubicacion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LotesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LotesTableTable,
    LotesTableData,
    $$LotesTableTableFilterComposer,
    $$LotesTableTableOrderingComposer,
    $$LotesTableTableAnnotationComposer,
    $$LotesTableTableCreateCompanionBuilder,
    $$LotesTableTableUpdateCompanionBuilder,
    (
      LotesTableData,
      BaseReferences<_$AppDatabase, $LotesTableTable, LotesTableData>
    ),
    LotesTableData,
    PrefetchHooks Function()>;
typedef $$MovimientosStockTableTableCreateCompanionBuilder
    = MovimientosStockTableCompanion Function({
  Value<int> id,
  required String tipo,
  required int loteId,
  required double cantidad,
  Value<String?> documentoReferencia,
  Value<DateTime> fechaMovimiento,
  Value<int?> usuarioId,
  Value<String?> observaciones,
});
typedef $$MovimientosStockTableTableUpdateCompanionBuilder
    = MovimientosStockTableCompanion Function({
  Value<int> id,
  Value<String> tipo,
  Value<int> loteId,
  Value<double> cantidad,
  Value<String?> documentoReferencia,
  Value<DateTime> fechaMovimiento,
  Value<int?> usuarioId,
  Value<String?> observaciones,
});

class $$MovimientosStockTableTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosStockTableTable> {
  $$MovimientosStockTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentoReferencia => $composableBuilder(
      column: $table.documentoReferencia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));
}

class $$MovimientosStockTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosStockTableTable> {
  $$MovimientosStockTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentoReferencia => $composableBuilder(
      column: $table.documentoReferencia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));
}

class $$MovimientosStockTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosStockTableTable> {
  $$MovimientosStockTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get documentoReferencia => $composableBuilder(
      column: $table.documentoReferencia, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaMovimiento => $composableBuilder(
      column: $table.fechaMovimiento, builder: (column) => column);

  GeneratedColumn<int> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);
}

class $$MovimientosStockTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MovimientosStockTableTable,
    MovimientosStockTableData,
    $$MovimientosStockTableTableFilterComposer,
    $$MovimientosStockTableTableOrderingComposer,
    $$MovimientosStockTableTableAnnotationComposer,
    $$MovimientosStockTableTableCreateCompanionBuilder,
    $$MovimientosStockTableTableUpdateCompanionBuilder,
    (
      MovimientosStockTableData,
      BaseReferences<_$AppDatabase, $MovimientosStockTableTable,
          MovimientosStockTableData>
    ),
    MovimientosStockTableData,
    PrefetchHooks Function()> {
  $$MovimientosStockTableTableTableManager(
      _$AppDatabase db, $MovimientosStockTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosStockTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosStockTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosStockTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<int> loteId = const Value.absent(),
            Value<double> cantidad = const Value.absent(),
            Value<String?> documentoReferencia = const Value.absent(),
            Value<DateTime> fechaMovimiento = const Value.absent(),
            Value<int?> usuarioId = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
          }) =>
              MovimientosStockTableCompanion(
            id: id,
            tipo: tipo,
            loteId: loteId,
            cantidad: cantidad,
            documentoReferencia: documentoReferencia,
            fechaMovimiento: fechaMovimiento,
            usuarioId: usuarioId,
            observaciones: observaciones,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String tipo,
            required int loteId,
            required double cantidad,
            Value<String?> documentoReferencia = const Value.absent(),
            Value<DateTime> fechaMovimiento = const Value.absent(),
            Value<int?> usuarioId = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
          }) =>
              MovimientosStockTableCompanion.insert(
            id: id,
            tipo: tipo,
            loteId: loteId,
            cantidad: cantidad,
            documentoReferencia: documentoReferencia,
            fechaMovimiento: fechaMovimiento,
            usuarioId: usuarioId,
            observaciones: observaciones,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MovimientosStockTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MovimientosStockTableTable,
        MovimientosStockTableData,
        $$MovimientosStockTableTableFilterComposer,
        $$MovimientosStockTableTableOrderingComposer,
        $$MovimientosStockTableTableAnnotationComposer,
        $$MovimientosStockTableTableCreateCompanionBuilder,
        $$MovimientosStockTableTableUpdateCompanionBuilder,
        (
          MovimientosStockTableData,
          BaseReferences<_$AppDatabase, $MovimientosStockTableTable,
              MovimientosStockTableData>
        ),
        MovimientosStockTableData,
        PrefetchHooks Function()>;
typedef $$VentasTableTableCreateCompanionBuilder = VentasTableCompanion
    Function({
  Value<int> id,
  Value<int?> clienteId,
  required int usuarioId,
  required int sesionCajaId,
  Value<DateTime> fechaVenta,
  Value<double> subtotal0,
  Value<double> subtotal15,
  Value<double> descuentoTotal,
  Value<double> impuestoTotal,
  required double total,
  Value<String> metodoPago,
  Value<String?> claveAcceso,
  Value<String> estadoSri,
  Value<String?> mensajeSri,
});
typedef $$VentasTableTableUpdateCompanionBuilder = VentasTableCompanion
    Function({
  Value<int> id,
  Value<int?> clienteId,
  Value<int> usuarioId,
  Value<int> sesionCajaId,
  Value<DateTime> fechaVenta,
  Value<double> subtotal0,
  Value<double> subtotal15,
  Value<double> descuentoTotal,
  Value<double> impuestoTotal,
  Value<double> total,
  Value<String> metodoPago,
  Value<String?> claveAcceso,
  Value<String> estadoSri,
  Value<String?> mensajeSri,
});

class $$VentasTableTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTableTable> {
  $$VentasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clienteId => $composableBuilder(
      column: $table.clienteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sesionCajaId => $composableBuilder(
      column: $table.sesionCajaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal0 => $composableBuilder(
      column: $table.subtotal0, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal15 => $composableBuilder(
      column: $table.subtotal15, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get descuentoTotal => $composableBuilder(
      column: $table.descuentoTotal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get impuestoTotal => $composableBuilder(
      column: $table.impuestoTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claveAcceso => $composableBuilder(
      column: $table.claveAcceso, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estadoSri => $composableBuilder(
      column: $table.estadoSri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mensajeSri => $composableBuilder(
      column: $table.mensajeSri, builder: (column) => ColumnFilters(column));
}

class $$VentasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTableTable> {
  $$VentasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clienteId => $composableBuilder(
      column: $table.clienteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sesionCajaId => $composableBuilder(
      column: $table.sesionCajaId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal0 => $composableBuilder(
      column: $table.subtotal0, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal15 => $composableBuilder(
      column: $table.subtotal15, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get descuentoTotal => $composableBuilder(
      column: $table.descuentoTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get impuestoTotal => $composableBuilder(
      column: $table.impuestoTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claveAcceso => $composableBuilder(
      column: $table.claveAcceso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estadoSri => $composableBuilder(
      column: $table.estadoSri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mensajeSri => $composableBuilder(
      column: $table.mensajeSri, builder: (column) => ColumnOrderings(column));
}

class $$VentasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTableTable> {
  $$VentasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<int> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<int> get sesionCajaId => $composableBuilder(
      column: $table.sesionCajaId, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVenta => $composableBuilder(
      column: $table.fechaVenta, builder: (column) => column);

  GeneratedColumn<double> get subtotal0 =>
      $composableBuilder(column: $table.subtotal0, builder: (column) => column);

  GeneratedColumn<double> get subtotal15 => $composableBuilder(
      column: $table.subtotal15, builder: (column) => column);

  GeneratedColumn<double> get descuentoTotal => $composableBuilder(
      column: $table.descuentoTotal, builder: (column) => column);

  GeneratedColumn<double> get impuestoTotal => $composableBuilder(
      column: $table.impuestoTotal, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => column);

  GeneratedColumn<String> get claveAcceso => $composableBuilder(
      column: $table.claveAcceso, builder: (column) => column);

  GeneratedColumn<String> get estadoSri =>
      $composableBuilder(column: $table.estadoSri, builder: (column) => column);

  GeneratedColumn<String> get mensajeSri => $composableBuilder(
      column: $table.mensajeSri, builder: (column) => column);
}

class $$VentasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VentasTableTable,
    VentasTableData,
    $$VentasTableTableFilterComposer,
    $$VentasTableTableOrderingComposer,
    $$VentasTableTableAnnotationComposer,
    $$VentasTableTableCreateCompanionBuilder,
    $$VentasTableTableUpdateCompanionBuilder,
    (
      VentasTableData,
      BaseReferences<_$AppDatabase, $VentasTableTable, VentasTableData>
    ),
    VentasTableData,
    PrefetchHooks Function()> {
  $$VentasTableTableTableManager(_$AppDatabase db, $VentasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> clienteId = const Value.absent(),
            Value<int> usuarioId = const Value.absent(),
            Value<int> sesionCajaId = const Value.absent(),
            Value<DateTime> fechaVenta = const Value.absent(),
            Value<double> subtotal0 = const Value.absent(),
            Value<double> subtotal15 = const Value.absent(),
            Value<double> descuentoTotal = const Value.absent(),
            Value<double> impuestoTotal = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> metodoPago = const Value.absent(),
            Value<String?> claveAcceso = const Value.absent(),
            Value<String> estadoSri = const Value.absent(),
            Value<String?> mensajeSri = const Value.absent(),
          }) =>
              VentasTableCompanion(
            id: id,
            clienteId: clienteId,
            usuarioId: usuarioId,
            sesionCajaId: sesionCajaId,
            fechaVenta: fechaVenta,
            subtotal0: subtotal0,
            subtotal15: subtotal15,
            descuentoTotal: descuentoTotal,
            impuestoTotal: impuestoTotal,
            total: total,
            metodoPago: metodoPago,
            claveAcceso: claveAcceso,
            estadoSri: estadoSri,
            mensajeSri: mensajeSri,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> clienteId = const Value.absent(),
            required int usuarioId,
            required int sesionCajaId,
            Value<DateTime> fechaVenta = const Value.absent(),
            Value<double> subtotal0 = const Value.absent(),
            Value<double> subtotal15 = const Value.absent(),
            Value<double> descuentoTotal = const Value.absent(),
            Value<double> impuestoTotal = const Value.absent(),
            required double total,
            Value<String> metodoPago = const Value.absent(),
            Value<String?> claveAcceso = const Value.absent(),
            Value<String> estadoSri = const Value.absent(),
            Value<String?> mensajeSri = const Value.absent(),
          }) =>
              VentasTableCompanion.insert(
            id: id,
            clienteId: clienteId,
            usuarioId: usuarioId,
            sesionCajaId: sesionCajaId,
            fechaVenta: fechaVenta,
            subtotal0: subtotal0,
            subtotal15: subtotal15,
            descuentoTotal: descuentoTotal,
            impuestoTotal: impuestoTotal,
            total: total,
            metodoPago: metodoPago,
            claveAcceso: claveAcceso,
            estadoSri: estadoSri,
            mensajeSri: mensajeSri,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VentasTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VentasTableTable,
    VentasTableData,
    $$VentasTableTableFilterComposer,
    $$VentasTableTableOrderingComposer,
    $$VentasTableTableAnnotationComposer,
    $$VentasTableTableCreateCompanionBuilder,
    $$VentasTableTableUpdateCompanionBuilder,
    (
      VentasTableData,
      BaseReferences<_$AppDatabase, $VentasTableTable, VentasTableData>
    ),
    VentasTableData,
    PrefetchHooks Function()>;
typedef $$DetallesVentaTableTableCreateCompanionBuilder
    = DetallesVentaTableCompanion Function({
  Value<int> id,
  required int ventaId,
  required int presentacionId,
  required int loteId,
  required double cantidad,
  Value<bool> esFraccion,
  required double precioUnitario,
  Value<double> descuento,
  required double subtotal,
  Value<double> ivaTotal,
});
typedef $$DetallesVentaTableTableUpdateCompanionBuilder
    = DetallesVentaTableCompanion Function({
  Value<int> id,
  Value<int> ventaId,
  Value<int> presentacionId,
  Value<int> loteId,
  Value<double> cantidad,
  Value<bool> esFraccion,
  Value<double> precioUnitario,
  Value<double> descuento,
  Value<double> subtotal,
  Value<double> ivaTotal,
});

class $$DetallesVentaTableTableFilterComposer
    extends Composer<_$AppDatabase, $DetallesVentaTableTable> {
  $$DetallesVentaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esFraccion => $composableBuilder(
      column: $table.esFraccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get descuento => $composableBuilder(
      column: $table.descuento, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ivaTotal => $composableBuilder(
      column: $table.ivaTotal, builder: (column) => ColumnFilters(column));
}

class $$DetallesVentaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DetallesVentaTableTable> {
  $$DetallesVentaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esFraccion => $composableBuilder(
      column: $table.esFraccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get descuento => $composableBuilder(
      column: $table.descuento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ivaTotal => $composableBuilder(
      column: $table.ivaTotal, builder: (column) => ColumnOrderings(column));
}

class $$DetallesVentaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetallesVentaTableTable> {
  $$DetallesVentaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);

  GeneratedColumn<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId, builder: (column) => column);

  GeneratedColumn<int> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<bool> get esFraccion => $composableBuilder(
      column: $table.esFraccion, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario, builder: (column) => column);

  GeneratedColumn<double> get descuento =>
      $composableBuilder(column: $table.descuento, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get ivaTotal =>
      $composableBuilder(column: $table.ivaTotal, builder: (column) => column);
}

class $$DetallesVentaTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetallesVentaTableTable,
    DetallesVentaTableData,
    $$DetallesVentaTableTableFilterComposer,
    $$DetallesVentaTableTableOrderingComposer,
    $$DetallesVentaTableTableAnnotationComposer,
    $$DetallesVentaTableTableCreateCompanionBuilder,
    $$DetallesVentaTableTableUpdateCompanionBuilder,
    (
      DetallesVentaTableData,
      BaseReferences<_$AppDatabase, $DetallesVentaTableTable,
          DetallesVentaTableData>
    ),
    DetallesVentaTableData,
    PrefetchHooks Function()> {
  $$DetallesVentaTableTableTableManager(
      _$AppDatabase db, $DetallesVentaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetallesVentaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetallesVentaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetallesVentaTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ventaId = const Value.absent(),
            Value<int> presentacionId = const Value.absent(),
            Value<int> loteId = const Value.absent(),
            Value<double> cantidad = const Value.absent(),
            Value<bool> esFraccion = const Value.absent(),
            Value<double> precioUnitario = const Value.absent(),
            Value<double> descuento = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> ivaTotal = const Value.absent(),
          }) =>
              DetallesVentaTableCompanion(
            id: id,
            ventaId: ventaId,
            presentacionId: presentacionId,
            loteId: loteId,
            cantidad: cantidad,
            esFraccion: esFraccion,
            precioUnitario: precioUnitario,
            descuento: descuento,
            subtotal: subtotal,
            ivaTotal: ivaTotal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ventaId,
            required int presentacionId,
            required int loteId,
            required double cantidad,
            Value<bool> esFraccion = const Value.absent(),
            required double precioUnitario,
            Value<double> descuento = const Value.absent(),
            required double subtotal,
            Value<double> ivaTotal = const Value.absent(),
          }) =>
              DetallesVentaTableCompanion.insert(
            id: id,
            ventaId: ventaId,
            presentacionId: presentacionId,
            loteId: loteId,
            cantidad: cantidad,
            esFraccion: esFraccion,
            precioUnitario: precioUnitario,
            descuento: descuento,
            subtotal: subtotal,
            ivaTotal: ivaTotal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetallesVentaTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetallesVentaTableTable,
    DetallesVentaTableData,
    $$DetallesVentaTableTableFilterComposer,
    $$DetallesVentaTableTableOrderingComposer,
    $$DetallesVentaTableTableAnnotationComposer,
    $$DetallesVentaTableTableCreateCompanionBuilder,
    $$DetallesVentaTableTableUpdateCompanionBuilder,
    (
      DetallesVentaTableData,
      BaseReferences<_$AppDatabase, $DetallesVentaTableTable,
          DetallesVentaTableData>
    ),
    DetallesVentaTableData,
    PrefetchHooks Function()>;
typedef $$ClientesTableTableCreateCompanionBuilder = ClientesTableCompanion
    Function({
  Value<int> id,
  required String documento,
  Value<String> tipoDocumento,
  required String nombreCompleto,
  Value<String?> telefono,
  Value<String?> email,
  Value<String?> direccion,
  Value<DateTime> createdAt,
});
typedef $$ClientesTableTableUpdateCompanionBuilder = ClientesTableCompanion
    Function({
  Value<int> id,
  Value<String> documento,
  Value<String> tipoDocumento,
  Value<String> nombreCompleto,
  Value<String?> telefono,
  Value<String?> email,
  Value<String?> direccion,
  Value<DateTime> createdAt,
});

class $$ClientesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documento => $composableBuilder(
      column: $table.documento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ClientesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documento => $composableBuilder(
      column: $table.documento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ClientesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documento =>
      $composableBuilder(column: $table.documento, builder: (column) => column);

  GeneratedColumn<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento, builder: (column) => column);

  GeneratedColumn<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ClientesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientesTableTable,
    ClientesTableData,
    $$ClientesTableTableFilterComposer,
    $$ClientesTableTableOrderingComposer,
    $$ClientesTableTableAnnotationComposer,
    $$ClientesTableTableCreateCompanionBuilder,
    $$ClientesTableTableUpdateCompanionBuilder,
    (
      ClientesTableData,
      BaseReferences<_$AppDatabase, $ClientesTableTable, ClientesTableData>
    ),
    ClientesTableData,
    PrefetchHooks Function()> {
  $$ClientesTableTableTableManager(_$AppDatabase db, $ClientesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> documento = const Value.absent(),
            Value<String> tipoDocumento = const Value.absent(),
            Value<String> nombreCompleto = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientesTableCompanion(
            id: id,
            documento: documento,
            tipoDocumento: tipoDocumento,
            nombreCompleto: nombreCompleto,
            telefono: telefono,
            email: email,
            direccion: direccion,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String documento,
            Value<String> tipoDocumento = const Value.absent(),
            required String nombreCompleto,
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientesTableCompanion.insert(
            id: id,
            documento: documento,
            tipoDocumento: tipoDocumento,
            nombreCompleto: nombreCompleto,
            telefono: telefono,
            email: email,
            direccion: direccion,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientesTableTable,
    ClientesTableData,
    $$ClientesTableTableFilterComposer,
    $$ClientesTableTableOrderingComposer,
    $$ClientesTableTableAnnotationComposer,
    $$ClientesTableTableCreateCompanionBuilder,
    $$ClientesTableTableUpdateCompanionBuilder,
    (
      ClientesTableData,
      BaseReferences<_$AppDatabase, $ClientesTableTable, ClientesTableData>
    ),
    ClientesTableData,
    PrefetchHooks Function()>;
typedef $$ProveedoresTableTableCreateCompanionBuilder
    = ProveedoresTableCompanion Function({
  Value<int> id,
  required String ruc,
  required String nombreEmpresa,
  Value<String?> direccion,
  Value<String?> telefonoEmpresa,
  Value<String?> emailEmpresa,
  Value<String?> nombreContacto,
  Value<String?> telefonoContacto,
  Value<String?> emailContacto,
  Value<String> estado,
  Value<DateTime> createdAt,
});
typedef $$ProveedoresTableTableUpdateCompanionBuilder
    = ProveedoresTableCompanion Function({
  Value<int> id,
  Value<String> ruc,
  Value<String> nombreEmpresa,
  Value<String?> direccion,
  Value<String?> telefonoEmpresa,
  Value<String?> emailEmpresa,
  Value<String?> nombreContacto,
  Value<String?> telefonoContacto,
  Value<String?> emailContacto,
  Value<String> estado,
  Value<DateTime> createdAt,
});

class $$ProveedoresTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProveedoresTableTable> {
  $$ProveedoresTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruc => $composableBuilder(
      column: $table.ruc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreEmpresa => $composableBuilder(
      column: $table.nombreEmpresa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefonoEmpresa => $composableBuilder(
      column: $table.telefonoEmpresa,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailEmpresa => $composableBuilder(
      column: $table.emailEmpresa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreContacto => $composableBuilder(
      column: $table.nombreContacto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefonoContacto => $composableBuilder(
      column: $table.telefonoContacto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailContacto => $composableBuilder(
      column: $table.emailContacto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ProveedoresTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProveedoresTableTable> {
  $$ProveedoresTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruc => $composableBuilder(
      column: $table.ruc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreEmpresa => $composableBuilder(
      column: $table.nombreEmpresa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefonoEmpresa => $composableBuilder(
      column: $table.telefonoEmpresa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailEmpresa => $composableBuilder(
      column: $table.emailEmpresa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreContacto => $composableBuilder(
      column: $table.nombreContacto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefonoContacto => $composableBuilder(
      column: $table.telefonoContacto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailContacto => $composableBuilder(
      column: $table.emailContacto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ProveedoresTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProveedoresTableTable> {
  $$ProveedoresTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get nombreEmpresa => $composableBuilder(
      column: $table.nombreEmpresa, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get telefonoEmpresa => $composableBuilder(
      column: $table.telefonoEmpresa, builder: (column) => column);

  GeneratedColumn<String> get emailEmpresa => $composableBuilder(
      column: $table.emailEmpresa, builder: (column) => column);

  GeneratedColumn<String> get nombreContacto => $composableBuilder(
      column: $table.nombreContacto, builder: (column) => column);

  GeneratedColumn<String> get telefonoContacto => $composableBuilder(
      column: $table.telefonoContacto, builder: (column) => column);

  GeneratedColumn<String> get emailContacto => $composableBuilder(
      column: $table.emailContacto, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProveedoresTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProveedoresTableTable,
    ProveedoresTableData,
    $$ProveedoresTableTableFilterComposer,
    $$ProveedoresTableTableOrderingComposer,
    $$ProveedoresTableTableAnnotationComposer,
    $$ProveedoresTableTableCreateCompanionBuilder,
    $$ProveedoresTableTableUpdateCompanionBuilder,
    (
      ProveedoresTableData,
      BaseReferences<_$AppDatabase, $ProveedoresTableTable,
          ProveedoresTableData>
    ),
    ProveedoresTableData,
    PrefetchHooks Function()> {
  $$ProveedoresTableTableTableManager(
      _$AppDatabase db, $ProveedoresTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProveedoresTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProveedoresTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProveedoresTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> ruc = const Value.absent(),
            Value<String> nombreEmpresa = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> telefonoEmpresa = const Value.absent(),
            Value<String?> emailEmpresa = const Value.absent(),
            Value<String?> nombreContacto = const Value.absent(),
            Value<String?> telefonoContacto = const Value.absent(),
            Value<String?> emailContacto = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProveedoresTableCompanion(
            id: id,
            ruc: ruc,
            nombreEmpresa: nombreEmpresa,
            direccion: direccion,
            telefonoEmpresa: telefonoEmpresa,
            emailEmpresa: emailEmpresa,
            nombreContacto: nombreContacto,
            telefonoContacto: telefonoContacto,
            emailContacto: emailContacto,
            estado: estado,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String ruc,
            required String nombreEmpresa,
            Value<String?> direccion = const Value.absent(),
            Value<String?> telefonoEmpresa = const Value.absent(),
            Value<String?> emailEmpresa = const Value.absent(),
            Value<String?> nombreContacto = const Value.absent(),
            Value<String?> telefonoContacto = const Value.absent(),
            Value<String?> emailContacto = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProveedoresTableCompanion.insert(
            id: id,
            ruc: ruc,
            nombreEmpresa: nombreEmpresa,
            direccion: direccion,
            telefonoEmpresa: telefonoEmpresa,
            emailEmpresa: emailEmpresa,
            nombreContacto: nombreContacto,
            telefonoContacto: telefonoContacto,
            emailContacto: emailContacto,
            estado: estado,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProveedoresTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProveedoresTableTable,
    ProveedoresTableData,
    $$ProveedoresTableTableFilterComposer,
    $$ProveedoresTableTableOrderingComposer,
    $$ProveedoresTableTableAnnotationComposer,
    $$ProveedoresTableTableCreateCompanionBuilder,
    $$ProveedoresTableTableUpdateCompanionBuilder,
    (
      ProveedoresTableData,
      BaseReferences<_$AppDatabase, $ProveedoresTableTable,
          ProveedoresTableData>
    ),
    ProveedoresTableData,
    PrefetchHooks Function()>;
typedef $$CajasSesionesTableTableCreateCompanionBuilder
    = CajasSesionesTableCompanion Function({
  Value<int> id,
  required int usuarioId,
  Value<DateTime> fechaApertura,
  Value<DateTime?> fechaCierre,
  Value<double> montoInicial,
  Value<double> montoEsperadoEfectivo,
  Value<double?> montoFinalEfectivo,
  Value<double?> montoFinalTarjeta,
  Value<double?> montoFinalTransferencia,
  Value<String?> observaciones,
  Value<String> estado,
});
typedef $$CajasSesionesTableTableUpdateCompanionBuilder
    = CajasSesionesTableCompanion Function({
  Value<int> id,
  Value<int> usuarioId,
  Value<DateTime> fechaApertura,
  Value<DateTime?> fechaCierre,
  Value<double> montoInicial,
  Value<double> montoEsperadoEfectivo,
  Value<double?> montoFinalEfectivo,
  Value<double?> montoFinalTarjeta,
  Value<double?> montoFinalTransferencia,
  Value<String?> observaciones,
  Value<String> estado,
});

class $$CajasSesionesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CajasSesionesTableTable> {
  $$CajasSesionesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaApertura => $composableBuilder(
      column: $table.fechaApertura, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoInicial => $composableBuilder(
      column: $table.montoInicial, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoEsperadoEfectivo => $composableBuilder(
      column: $table.montoEsperadoEfectivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoFinalEfectivo => $composableBuilder(
      column: $table.montoFinalEfectivo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoFinalTarjeta => $composableBuilder(
      column: $table.montoFinalTarjeta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoFinalTransferencia => $composableBuilder(
      column: $table.montoFinalTransferencia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));
}

class $$CajasSesionesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CajasSesionesTableTable> {
  $$CajasSesionesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaApertura => $composableBuilder(
      column: $table.fechaApertura,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoInicial => $composableBuilder(
      column: $table.montoInicial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoEsperadoEfectivo => $composableBuilder(
      column: $table.montoEsperadoEfectivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoFinalEfectivo => $composableBuilder(
      column: $table.montoFinalEfectivo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoFinalTarjeta => $composableBuilder(
      column: $table.montoFinalTarjeta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoFinalTransferencia => $composableBuilder(
      column: $table.montoFinalTransferencia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));
}

class $$CajasSesionesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajasSesionesTableTable> {
  $$CajasSesionesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaApertura => $composableBuilder(
      column: $table.fechaApertura, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => column);

  GeneratedColumn<double> get montoInicial => $composableBuilder(
      column: $table.montoInicial, builder: (column) => column);

  GeneratedColumn<double> get montoEsperadoEfectivo => $composableBuilder(
      column: $table.montoEsperadoEfectivo, builder: (column) => column);

  GeneratedColumn<double> get montoFinalEfectivo => $composableBuilder(
      column: $table.montoFinalEfectivo, builder: (column) => column);

  GeneratedColumn<double> get montoFinalTarjeta => $composableBuilder(
      column: $table.montoFinalTarjeta, builder: (column) => column);

  GeneratedColumn<double> get montoFinalTransferencia => $composableBuilder(
      column: $table.montoFinalTransferencia, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$CajasSesionesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CajasSesionesTableTable,
    CajasSesionesTableData,
    $$CajasSesionesTableTableFilterComposer,
    $$CajasSesionesTableTableOrderingComposer,
    $$CajasSesionesTableTableAnnotationComposer,
    $$CajasSesionesTableTableCreateCompanionBuilder,
    $$CajasSesionesTableTableUpdateCompanionBuilder,
    (
      CajasSesionesTableData,
      BaseReferences<_$AppDatabase, $CajasSesionesTableTable,
          CajasSesionesTableData>
    ),
    CajasSesionesTableData,
    PrefetchHooks Function()> {
  $$CajasSesionesTableTableTableManager(
      _$AppDatabase db, $CajasSesionesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajasSesionesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajasSesionesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajasSesionesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> usuarioId = const Value.absent(),
            Value<DateTime> fechaApertura = const Value.absent(),
            Value<DateTime?> fechaCierre = const Value.absent(),
            Value<double> montoInicial = const Value.absent(),
            Value<double> montoEsperadoEfectivo = const Value.absent(),
            Value<double?> montoFinalEfectivo = const Value.absent(),
            Value<double?> montoFinalTarjeta = const Value.absent(),
            Value<double?> montoFinalTransferencia = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<String> estado = const Value.absent(),
          }) =>
              CajasSesionesTableCompanion(
            id: id,
            usuarioId: usuarioId,
            fechaApertura: fechaApertura,
            fechaCierre: fechaCierre,
            montoInicial: montoInicial,
            montoEsperadoEfectivo: montoEsperadoEfectivo,
            montoFinalEfectivo: montoFinalEfectivo,
            montoFinalTarjeta: montoFinalTarjeta,
            montoFinalTransferencia: montoFinalTransferencia,
            observaciones: observaciones,
            estado: estado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int usuarioId,
            Value<DateTime> fechaApertura = const Value.absent(),
            Value<DateTime?> fechaCierre = const Value.absent(),
            Value<double> montoInicial = const Value.absent(),
            Value<double> montoEsperadoEfectivo = const Value.absent(),
            Value<double?> montoFinalEfectivo = const Value.absent(),
            Value<double?> montoFinalTarjeta = const Value.absent(),
            Value<double?> montoFinalTransferencia = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<String> estado = const Value.absent(),
          }) =>
              CajasSesionesTableCompanion.insert(
            id: id,
            usuarioId: usuarioId,
            fechaApertura: fechaApertura,
            fechaCierre: fechaCierre,
            montoInicial: montoInicial,
            montoEsperadoEfectivo: montoEsperadoEfectivo,
            montoFinalEfectivo: montoFinalEfectivo,
            montoFinalTarjeta: montoFinalTarjeta,
            montoFinalTransferencia: montoFinalTransferencia,
            observaciones: observaciones,
            estado: estado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CajasSesionesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CajasSesionesTableTable,
    CajasSesionesTableData,
    $$CajasSesionesTableTableFilterComposer,
    $$CajasSesionesTableTableOrderingComposer,
    $$CajasSesionesTableTableAnnotationComposer,
    $$CajasSesionesTableTableCreateCompanionBuilder,
    $$CajasSesionesTableTableUpdateCompanionBuilder,
    (
      CajasSesionesTableData,
      BaseReferences<_$AppDatabase, $CajasSesionesTableTable,
          CajasSesionesTableData>
    ),
    CajasSesionesTableData,
    PrefetchHooks Function()>;
typedef $$ComprasTableTableCreateCompanionBuilder = ComprasTableCompanion
    Function({
  Value<int> id,
  required int proveedorId,
  required String numeroFactura,
  Value<String?> numeroAutorizacionSri,
  required DateTime fechaEmision,
  Value<DateTime> fechaRecepcion,
  Value<double> subtotalDoce,
  Value<double> subtotalCero,
  Value<double> iva,
  Value<double> total,
  Value<String?> observaciones,
  Value<String> estado,
});
typedef $$ComprasTableTableUpdateCompanionBuilder = ComprasTableCompanion
    Function({
  Value<int> id,
  Value<int> proveedorId,
  Value<String> numeroFactura,
  Value<String?> numeroAutorizacionSri,
  Value<DateTime> fechaEmision,
  Value<DateTime> fechaRecepcion,
  Value<double> subtotalDoce,
  Value<double> subtotalCero,
  Value<double> iva,
  Value<double> total,
  Value<String?> observaciones,
  Value<String> estado,
});

class $$ComprasTableTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasTableTable> {
  $$ComprasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroFactura => $composableBuilder(
      column: $table.numeroFactura, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroAutorizacionSri => $composableBuilder(
      column: $table.numeroAutorizacionSri,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaEmision => $composableBuilder(
      column: $table.fechaEmision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRecepcion => $composableBuilder(
      column: $table.fechaRecepcion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotalDoce => $composableBuilder(
      column: $table.subtotalDoce, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotalCero => $composableBuilder(
      column: $table.subtotalCero, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get iva => $composableBuilder(
      column: $table.iva, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));
}

class $$ComprasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasTableTable> {
  $$ComprasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroFactura => $composableBuilder(
      column: $table.numeroFactura,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroAutorizacionSri => $composableBuilder(
      column: $table.numeroAutorizacionSri,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaEmision => $composableBuilder(
      column: $table.fechaEmision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRecepcion => $composableBuilder(
      column: $table.fechaRecepcion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotalDoce => $composableBuilder(
      column: $table.subtotalDoce,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotalCero => $composableBuilder(
      column: $table.subtotalCero,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get iva => $composableBuilder(
      column: $table.iva, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));
}

class $$ComprasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasTableTable> {
  $$ComprasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => column);

  GeneratedColumn<String> get numeroFactura => $composableBuilder(
      column: $table.numeroFactura, builder: (column) => column);

  GeneratedColumn<String> get numeroAutorizacionSri => $composableBuilder(
      column: $table.numeroAutorizacionSri, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaEmision => $composableBuilder(
      column: $table.fechaEmision, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRecepcion => $composableBuilder(
      column: $table.fechaRecepcion, builder: (column) => column);

  GeneratedColumn<double> get subtotalDoce => $composableBuilder(
      column: $table.subtotalDoce, builder: (column) => column);

  GeneratedColumn<double> get subtotalCero => $composableBuilder(
      column: $table.subtotalCero, builder: (column) => column);

  GeneratedColumn<double> get iva =>
      $composableBuilder(column: $table.iva, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$ComprasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ComprasTableTable,
    ComprasTableData,
    $$ComprasTableTableFilterComposer,
    $$ComprasTableTableOrderingComposer,
    $$ComprasTableTableAnnotationComposer,
    $$ComprasTableTableCreateCompanionBuilder,
    $$ComprasTableTableUpdateCompanionBuilder,
    (
      ComprasTableData,
      BaseReferences<_$AppDatabase, $ComprasTableTable, ComprasTableData>
    ),
    ComprasTableData,
    PrefetchHooks Function()> {
  $$ComprasTableTableTableManager(_$AppDatabase db, $ComprasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> proveedorId = const Value.absent(),
            Value<String> numeroFactura = const Value.absent(),
            Value<String?> numeroAutorizacionSri = const Value.absent(),
            Value<DateTime> fechaEmision = const Value.absent(),
            Value<DateTime> fechaRecepcion = const Value.absent(),
            Value<double> subtotalDoce = const Value.absent(),
            Value<double> subtotalCero = const Value.absent(),
            Value<double> iva = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<String> estado = const Value.absent(),
          }) =>
              ComprasTableCompanion(
            id: id,
            proveedorId: proveedorId,
            numeroFactura: numeroFactura,
            numeroAutorizacionSri: numeroAutorizacionSri,
            fechaEmision: fechaEmision,
            fechaRecepcion: fechaRecepcion,
            subtotalDoce: subtotalDoce,
            subtotalCero: subtotalCero,
            iva: iva,
            total: total,
            observaciones: observaciones,
            estado: estado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int proveedorId,
            required String numeroFactura,
            Value<String?> numeroAutorizacionSri = const Value.absent(),
            required DateTime fechaEmision,
            Value<DateTime> fechaRecepcion = const Value.absent(),
            Value<double> subtotalDoce = const Value.absent(),
            Value<double> subtotalCero = const Value.absent(),
            Value<double> iva = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<String> estado = const Value.absent(),
          }) =>
              ComprasTableCompanion.insert(
            id: id,
            proveedorId: proveedorId,
            numeroFactura: numeroFactura,
            numeroAutorizacionSri: numeroAutorizacionSri,
            fechaEmision: fechaEmision,
            fechaRecepcion: fechaRecepcion,
            subtotalDoce: subtotalDoce,
            subtotalCero: subtotalCero,
            iva: iva,
            total: total,
            observaciones: observaciones,
            estado: estado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ComprasTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ComprasTableTable,
    ComprasTableData,
    $$ComprasTableTableFilterComposer,
    $$ComprasTableTableOrderingComposer,
    $$ComprasTableTableAnnotationComposer,
    $$ComprasTableTableCreateCompanionBuilder,
    $$ComprasTableTableUpdateCompanionBuilder,
    (
      ComprasTableData,
      BaseReferences<_$AppDatabase, $ComprasTableTable, ComprasTableData>
    ),
    ComprasTableData,
    PrefetchHooks Function()>;
typedef $$DetallesCompraTableTableCreateCompanionBuilder
    = DetallesCompraTableCompanion Function({
  Value<int> id,
  required int compraId,
  required int presentacionId,
  required String lote,
  required DateTime fechaVencimiento,
  Value<double> cantidadCajas,
  Value<double> cantidadUnidades,
  Value<double> costoCaja,
  Value<double> costoUnitario,
  Value<double> subtotal,
  Value<bool> cumpleRegistroSanitario,
  Value<bool> cumpleEmpaque,
  Value<double?> temperaturaRecepcion,
});
typedef $$DetallesCompraTableTableUpdateCompanionBuilder
    = DetallesCompraTableCompanion Function({
  Value<int> id,
  Value<int> compraId,
  Value<int> presentacionId,
  Value<String> lote,
  Value<DateTime> fechaVencimiento,
  Value<double> cantidadCajas,
  Value<double> cantidadUnidades,
  Value<double> costoCaja,
  Value<double> costoUnitario,
  Value<double> subtotal,
  Value<bool> cumpleRegistroSanitario,
  Value<bool> cumpleEmpaque,
  Value<double?> temperaturaRecepcion,
});

class $$DetallesCompraTableTableFilterComposer
    extends Composer<_$AppDatabase, $DetallesCompraTableTable> {
  $$DetallesCompraTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get compraId => $composableBuilder(
      column: $table.compraId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cantidadCajas => $composableBuilder(
      column: $table.cantidadCajas, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cantidadUnidades => $composableBuilder(
      column: $table.cantidadUnidades,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costoCaja => $composableBuilder(
      column: $table.costoCaja, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cumpleRegistroSanitario => $composableBuilder(
      column: $table.cumpleRegistroSanitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cumpleEmpaque => $composableBuilder(
      column: $table.cumpleEmpaque, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperaturaRecepcion => $composableBuilder(
      column: $table.temperaturaRecepcion,
      builder: (column) => ColumnFilters(column));
}

class $$DetallesCompraTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DetallesCompraTableTable> {
  $$DetallesCompraTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get compraId => $composableBuilder(
      column: $table.compraId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cantidadCajas => $composableBuilder(
      column: $table.cantidadCajas,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cantidadUnidades => $composableBuilder(
      column: $table.cantidadUnidades,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costoCaja => $composableBuilder(
      column: $table.costoCaja, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cumpleRegistroSanitario => $composableBuilder(
      column: $table.cumpleRegistroSanitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cumpleEmpaque => $composableBuilder(
      column: $table.cumpleEmpaque,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperaturaRecepcion => $composableBuilder(
      column: $table.temperaturaRecepcion,
      builder: (column) => ColumnOrderings(column));
}

class $$DetallesCompraTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetallesCompraTableTable> {
  $$DetallesCompraTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get compraId =>
      $composableBuilder(column: $table.compraId, builder: (column) => column);

  GeneratedColumn<int> get presentacionId => $composableBuilder(
      column: $table.presentacionId, builder: (column) => column);

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento, builder: (column) => column);

  GeneratedColumn<double> get cantidadCajas => $composableBuilder(
      column: $table.cantidadCajas, builder: (column) => column);

  GeneratedColumn<double> get cantidadUnidades => $composableBuilder(
      column: $table.cantidadUnidades, builder: (column) => column);

  GeneratedColumn<double> get costoCaja =>
      $composableBuilder(column: $table.costoCaja, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<bool> get cumpleRegistroSanitario => $composableBuilder(
      column: $table.cumpleRegistroSanitario, builder: (column) => column);

  GeneratedColumn<bool> get cumpleEmpaque => $composableBuilder(
      column: $table.cumpleEmpaque, builder: (column) => column);

  GeneratedColumn<double> get temperaturaRecepcion => $composableBuilder(
      column: $table.temperaturaRecepcion, builder: (column) => column);
}

class $$DetallesCompraTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetallesCompraTableTable,
    DetallesCompraTableData,
    $$DetallesCompraTableTableFilterComposer,
    $$DetallesCompraTableTableOrderingComposer,
    $$DetallesCompraTableTableAnnotationComposer,
    $$DetallesCompraTableTableCreateCompanionBuilder,
    $$DetallesCompraTableTableUpdateCompanionBuilder,
    (
      DetallesCompraTableData,
      BaseReferences<_$AppDatabase, $DetallesCompraTableTable,
          DetallesCompraTableData>
    ),
    DetallesCompraTableData,
    PrefetchHooks Function()> {
  $$DetallesCompraTableTableTableManager(
      _$AppDatabase db, $DetallesCompraTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetallesCompraTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetallesCompraTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetallesCompraTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> compraId = const Value.absent(),
            Value<int> presentacionId = const Value.absent(),
            Value<String> lote = const Value.absent(),
            Value<DateTime> fechaVencimiento = const Value.absent(),
            Value<double> cantidadCajas = const Value.absent(),
            Value<double> cantidadUnidades = const Value.absent(),
            Value<double> costoCaja = const Value.absent(),
            Value<double> costoUnitario = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<bool> cumpleRegistroSanitario = const Value.absent(),
            Value<bool> cumpleEmpaque = const Value.absent(),
            Value<double?> temperaturaRecepcion = const Value.absent(),
          }) =>
              DetallesCompraTableCompanion(
            id: id,
            compraId: compraId,
            presentacionId: presentacionId,
            lote: lote,
            fechaVencimiento: fechaVencimiento,
            cantidadCajas: cantidadCajas,
            cantidadUnidades: cantidadUnidades,
            costoCaja: costoCaja,
            costoUnitario: costoUnitario,
            subtotal: subtotal,
            cumpleRegistroSanitario: cumpleRegistroSanitario,
            cumpleEmpaque: cumpleEmpaque,
            temperaturaRecepcion: temperaturaRecepcion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int compraId,
            required int presentacionId,
            required String lote,
            required DateTime fechaVencimiento,
            Value<double> cantidadCajas = const Value.absent(),
            Value<double> cantidadUnidades = const Value.absent(),
            Value<double> costoCaja = const Value.absent(),
            Value<double> costoUnitario = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<bool> cumpleRegistroSanitario = const Value.absent(),
            Value<bool> cumpleEmpaque = const Value.absent(),
            Value<double?> temperaturaRecepcion = const Value.absent(),
          }) =>
              DetallesCompraTableCompanion.insert(
            id: id,
            compraId: compraId,
            presentacionId: presentacionId,
            lote: lote,
            fechaVencimiento: fechaVencimiento,
            cantidadCajas: cantidadCajas,
            cantidadUnidades: cantidadUnidades,
            costoCaja: costoCaja,
            costoUnitario: costoUnitario,
            subtotal: subtotal,
            cumpleRegistroSanitario: cumpleRegistroSanitario,
            cumpleEmpaque: cumpleEmpaque,
            temperaturaRecepcion: temperaturaRecepcion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetallesCompraTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetallesCompraTableTable,
    DetallesCompraTableData,
    $$DetallesCompraTableTableFilterComposer,
    $$DetallesCompraTableTableOrderingComposer,
    $$DetallesCompraTableTableAnnotationComposer,
    $$DetallesCompraTableTableCreateCompanionBuilder,
    $$DetallesCompraTableTableUpdateCompanionBuilder,
    (
      DetallesCompraTableData,
      BaseReferences<_$AppDatabase, $DetallesCompraTableTable,
          DetallesCompraTableData>
    ),
    DetallesCompraTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableTableManager get productosTable =>
      $$ProductosTableTableTableManager(_db, _db.productosTable);
  $$PresentacionesTableTableTableManager get presentacionesTable =>
      $$PresentacionesTableTableTableManager(_db, _db.presentacionesTable);
  $$LotesTableTableTableManager get lotesTable =>
      $$LotesTableTableTableManager(_db, _db.lotesTable);
  $$MovimientosStockTableTableTableManager get movimientosStockTable =>
      $$MovimientosStockTableTableTableManager(_db, _db.movimientosStockTable);
  $$VentasTableTableTableManager get ventasTable =>
      $$VentasTableTableTableManager(_db, _db.ventasTable);
  $$DetallesVentaTableTableTableManager get detallesVentaTable =>
      $$DetallesVentaTableTableTableManager(_db, _db.detallesVentaTable);
  $$ClientesTableTableTableManager get clientesTable =>
      $$ClientesTableTableTableManager(_db, _db.clientesTable);
  $$ProveedoresTableTableTableManager get proveedoresTable =>
      $$ProveedoresTableTableTableManager(_db, _db.proveedoresTable);
  $$CajasSesionesTableTableTableManager get cajasSesionesTable =>
      $$CajasSesionesTableTableTableManager(_db, _db.cajasSesionesTable);
  $$ComprasTableTableTableManager get comprasTable =>
      $$ComprasTableTableTableManager(_db, _db.comprasTable);
  $$DetallesCompraTableTableTableManager get detallesCompraTable =>
      $$DetallesCompraTableTableTableManager(_db, _db.detallesCompraTable);
}
