import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Columna tipada para la tabla de escritorio
class AppTableColumn<T> {
  final String label;
  final Widget Function(T item) builder;
  final double? width;
  final bool numeric;

  const AppTableColumn({
    required this.label,
    required this.builder,
    this.width,
    this.numeric = false,
  });
}

/// Tabla de datos de alta densidad diseñada para pantallas de escritorio (SOLID: DRY)
class AppDataTable<T> extends StatelessWidget {
  final List<AppTableColumn<T>> columns;
  final List<T> data;
  final bool isLoading;
  final String emptyMessage;
  final void Function(T item)? onRowTap;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.isLoading = false,
    this.emptyMessage = 'No se encontraron registros.',
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate total required width to support horizontal scrolling safely (including 32px for horizontal padding)
          final totalWidth = columns.fold<double>(0, (sum, col) => sum + (col.width ?? 150.0)) + 32.0;
          final tableWidth = totalWidth > constraints.maxWidth ? totalWidth : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado de Columnas
                  Container(
                    color: AppColors.divider,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: columns.map((col) {
                        final text = Text(
                          col.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        );
                        if (col.width != null) {
                          return SizedBox(width: col.width, child: text);
                        }
                        return Expanded(child: text);
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  // Filas de Datos
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return InkWell(
                          onTap: onRowTap != null ? () => onRowTap!(item) : null,
                          hoverColor: AppColors.primarySurface.withValues(alpha: 0.5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: columns.map((col) {
                                final widget = col.builder(item);
                                if (col.width != null) {
                                  return SizedBox(width: col.width, child: widget);
                                }
                                return Expanded(child: widget);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
