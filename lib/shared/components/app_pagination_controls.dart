import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizeOptions;

  const AppPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    final startItem = totalItems == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;
    final endItem = (currentPage * pageSize) > totalItems ? totalItems : (currentPage * pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            'Mostrando $startItem - $endItem de $totalItems registros',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
          const Text(
            'Registros por página:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: pageSizeOptions.contains(pageSize) ? pageSize : pageSizeOptions.first,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                items: pageSizeOptions.map((size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text(size.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) onPageSizeChanged(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? onPreviousPage : null,
            color: AppColors.primary,
            disabledColor: AppColors.textMuted.withValues(alpha: 0.5),
            tooltip: 'Página anterior',
            splashRadius: 20,
          ),
          Text(
            'Página $currentPage de ${totalPages == 0 ? 1 : totalPages}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages ? onNextPage : null,
            color: AppColors.primary,
            disabledColor: AppColors.textMuted.withValues(alpha: 0.5),
            tooltip: 'Siguiente página',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
