import "package:flutter/material.dart";

class LoadingSkeleton extends StatelessWidget {
  final int itemCount;

  const LoadingSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 180, color: Colors.grey.shade100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
