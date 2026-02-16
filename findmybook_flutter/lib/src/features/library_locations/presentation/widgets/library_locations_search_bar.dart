import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/library_location_entity.dart';
import '../controllers/library_locations_providers.dart';

/// Search Bar and Filters Widget
/// 
/// MERN Comparison:
/// - React component with controlled input and filter dropdowns
/// - Similar to: <SearchBar query={query} onChange={setQuery} /> + <Filters />
class LibraryLocationsSearchBar extends ConsumerWidget {
  final Function(String) onSearchChanged;

  const LibraryLocationsSearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final radius = ref.watch(searchRadiusProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search TextField
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Search libraries...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                    onSearchChanged('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Radius: ${radius.toInt()} km',
                  onTap: () => _showRadiusBottomSheet(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                label: 'More Filters',
                icon: Icons.tune,
                onTap: () => _showAdvancedFilters(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter chip button
  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusBottomSheet(BuildContext context, WidgetRef ref) {
    final currentRadius = ref.read(searchRadiusProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: currentRadius,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${currentRadius.toInt()} km',
              onChanged: (value) {
                ref.read(searchRadiusProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Open Now'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Has Available Books'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('4+ Rating'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
