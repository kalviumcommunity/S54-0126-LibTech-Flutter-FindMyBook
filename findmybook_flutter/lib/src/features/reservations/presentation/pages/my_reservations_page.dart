import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../reservations/data/datasources/reservations_remote_data_source.dart';
import '../../../reservations/data/repositories/reservation_repository_impl.dart';
import '../../../reservations/domain/repositories/reservation_repository.dart';
import '../../../reservations/domain/usecases/reservation_usecases.dart';
import '../../../reservations/domain/entities/reservation.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  late final ReservationRepository _reservationRepository;
  late final GetUserReservationsUsecase _getUserReservationsUsecase;
  late final CancelReservationUsecase _cancelUsecase;

  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _loadReservations();
  }

  void _initDependencies() {
    final remoteDataSource = ReservationsRemoteDataSource();
    _reservationRepository = ReservationRepositoryImpl(remoteDataSource);
    _getUserReservationsUsecase = GetUserReservationsUsecase(_reservationRepository);
    _cancelUsecase = CancelReservationUsecase(_reservationRepository);
  }

  Future<void> _loadReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _error = 'You must be logged in';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final reservations = await _getUserReservationsUsecase(user.uid);
      if (mounted) {
        setState(() {
          _reservations = reservations;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load reservations: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text('Are you sure you want to cancel your reservation for "${reservation.bookTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Reservation'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _cancelUsecase(reservation.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservation for "${reservation.bookTitle}" cancelled'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReservations(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading reservations...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadReservations();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmarks_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No reservations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Books you reserve will appear here',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Separate active and inactive reservations
    final activeReservations = _reservations
      .where((r) => r.status == ReservationStatus.active && !r.isExpired)
      .toList();
    final otherReservations = _reservations
      .where((r) => !(r.status == ReservationStatus.active && !r.isExpired))
      .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Active reservations
        if (activeReservations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              'Active Reservations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...activeReservations.map((r) => _buildReservationCard(r, true)),
        ],

        // Other reservations
        if (otherReservations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              'Past Reservations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...otherReservations.map((r) => _buildReservationCard(r, false)),
        ],
      ],
    );
  }

  Widget _buildReservationCard(Reservation reservation, bool isActive) {
    final daysLeft = reservation.daysRemaining;
    final isExpired = reservation.isExpired;

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.check_circle;

    if (reservation.status == ReservationStatus.active && !isExpired) {
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
    } else if (reservation.status == ReservationStatus.cancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (isExpired) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.book, color: Colors.blue.shade600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.bookTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${reservation.bookAuthor}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  reservation.statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isActive && !isExpired && daysLeft != null)
              Text(
                'Expires in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}',
                style: TextStyle(
                  color: (daysLeft != null && daysLeft <= 2) ? Colors.red : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            if (isExpired)
              Text(
                'Expired on ${reservation.expiresAt.toString().split(' ')[0]}',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
              ),
            const SizedBox(height: 12),
            if (isActive && !isExpired)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _cancelReservation(reservation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: const Text('Cancel Reservation'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
