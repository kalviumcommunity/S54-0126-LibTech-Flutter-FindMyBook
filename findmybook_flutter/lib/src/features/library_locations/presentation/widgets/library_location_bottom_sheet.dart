import 'package:flutter/material.dart';
import '../../domain/entities/library_location_entity.dart';

/// Bottom Sheet Widget displaying Library Location Details
/// 
/// MERN Comparison:
/// - React modal/drawer component for display location details
/// - Similar to: <Modal open={selected} onClose={setSelected(null)}><LibraryDetails {...}</Modal>
class LibraryLocationBottomSheet extends StatelessWidget {
  final LibraryLocationEntity? location;
  final VoidCallback onClose;
  final Function(LibraryLocationEntity) onNavigate;

  const LibraryLocationBottomSheet({
    Key? key,
    required this.location,
    required this.onClose,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header with drag indicator
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    location!.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    color: Colors.blue.shade50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Drag indicator
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating and Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Chip
                          Chip(
                            label: Text(
                              location!.isOpen ? 'Open now' : 'Closed',
                              style: TextStyle(
                                color: location!.isOpen
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            backgroundColor: location!.isOpen
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                          ),
                          // Rating
                          if (location!.rating != null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${location!.rating!.toStringAsFixed(1)} / 5.0',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Book Availability
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${location!.availableBooks}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Column(
                              children: [
                                Text(
                                  '${location!.totalBooks}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact Information
                      _buildSection(
                        title: 'Location',
                        icon: Icons.location_on,
                        content: location!.address,
                      ),
                      const SizedBox(height: 12),

                      _buildSection(
                        title: 'Phone',
                        icon: Icons.phone,
                        content: location!.phone,
                        onTap: () => _launchPhone(location!.phone),
                      ),
                      const SizedBox(height: 12),

                      _buildSection(
                        title: 'Email',
                        icon: Icons.email,
                        content: location!.email,
                        onTap: () => _launchEmail(location!.email),
                      ),

                      if (location!.website != null) ...[
                        const SizedBox(height: 12),
                        _buildSection(
                          title: 'Website',
                          icon: Icons.language,
                          content: location!.website!,
                          onTap: () =>
                              _launchWebsite(location!.website!),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Opening Hours
                      if (location!.openingHours.isNotEmpty) ...[
                        const Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...location!.openingHours
                            .map((hours) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            hours,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ))
                            .toList(),
                        const SizedBox(height: 20),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onClose,
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => onNavigate(location!),
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a section with icon and content
  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String phone) {
    // TODO: Implement phone launch using url_launcher
    // urllauncher.launch('tel:$phone');
    debugPrint('Phone: $phone');
  }

  void _launchEmail(String email) {
    // TODO: Implement email launch using url_launcher
    // urllauncher.launch('mailto:$email');
    debugPrint('Email: $email');
  }

  void _launchWebsite(String website) {
    // TODO: Implement website launch using url_launcher
    // urllauncher.launch(website);
    debugPrint('Website: $website');
  }
}
