import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../shared/widgets/empty_state.dart";
import "../../../shared/widgets/error_state.dart";
import "../../../shared/widgets/loading_skeleton.dart";
import "../domain/reservation.dart";
import "reservations_providers.dart";

class MyReservationsPage extends ConsumerWidget {
  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(userReservationsProvider);
    final actionState = ref.watch(reservationControllerProvider);

    ref.listen<AsyncValue<void>>(reservationControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("My Reservations")),
      body: reservationsAsync.when(
        loading: () => const LoadingSkeleton(itemCount: 4),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(userReservationsProvider),
        ),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: "No reservations yet",
              subtitle: "Reserved books appear here in real time.",
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                child: ListTile(
                  title: Text(reservation.bookTitle),
                  subtitle: Text(
                    "${reservation.bookAuthor}\n"
                    "Expires: ${reservation.expiresAt.toLocal().toString().split(" ").first}",
                  ),
                  isThreeLine: true,
                  trailing: _statusChip(reservation),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: actionState.isLoading
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }

  Widget _statusChip(Reservation reservation) {
    if (reservation.status == ReservationStatus.cancelled) {
      return const Chip(label: Text("Cancelled"));
    }
    if (reservation.isExpired) {
      return const Chip(label: Text("Expired"));
    }
    return const Chip(label: Text("Active"));
  }
}
