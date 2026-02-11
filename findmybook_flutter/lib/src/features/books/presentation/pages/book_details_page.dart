import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/book_model.dart';
import '../../../reservations/data/datasources/reservations_remote_data_source.dart';
import '../../../reservations/data/repositories/reservation_repository_impl.dart';
import '../../../reservations/domain/repositories/reservation_repository.dart';
import '../../../reservations/domain/usecases/reservation_usecases.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;

  const BookDetailsPage({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final ReservationRepository _reservationRepository;
  late final ReserveBookUsecase _reserveBookUsecase;
  late final GetReservationCountUsecase _getCountUsecase;

  bool _isReserved = false;
  bool _isReserving = false;
  int _reservationCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _checkReservationStatus();
  }

  void _initDependencies() {
    final remoteDataSource = ReservationsRemoteDataSource();
    _reservationRepository = ReservationRepositoryImpl(remoteDataSource);
    _reserveBookUsecase = ReserveBookUsecase(_reservationRepository);
    _getCountUsecase = GetReservationCountUsecase(_reservationRepository);
  }

  Future<void> _checkReservationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final isReserved = await _reservationRepository.isBookReservedByUser(
        user.uid,
        widget.book.id,
      );
      final count = await _getCountUsecase(widget.book.id);

      if (mounted) {
        setState(() {
          _isReserved = isReserved;
          _reservationCount = count;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to check reservation status: $e';
        });
      }
    }
  }

  Future<void> _showReservationConfirmDialog() async {
    final expiresAt = DateTime.now().add(const Duration(days: 7));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reserve Book?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'by ${widget.book.author}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'This book will be reserved for 7 days. Your reservation expires on ${expiresAt.toString().split(' ')[0]}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reserve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reserveBook();
    }
  }

  Future<void> _reserveBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackbar('You must be logged in to reserve books');
      return;
    }

    setState(() {
      _isReserving = true;
      _error = null;
    });

    try {
      await _reserveBookUsecase(
        user.uid,
        widget.book.id,
        widget.book.title,
        widget.book.author,
      );

      if (mounted) {
        setState(() {
          _isReserved = true;
          _isReserving = false;
        });
        _showSuccessSnackbar('Book reserved successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReserving = false;
          _error = e.toString();
        });
        _showErrorSnackbar('Failed to reserve book: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.book,
                  size: 100,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Author
            Text(
              'by ${widget.book.author}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Reservation count
            if (_reservationCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  '$_reservationCount ${_reservationCount == 1 ? 'person has' : 'people have'} reserved this book',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade900,
                      ),
                ),
              ),
            const SizedBox(height: 24),

            // Description placeholder
            Text(
              'About this book',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No description available for this book.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),

            // Error message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Reserve button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReserved || _isReserving
                    ? null
                    : _showReservationConfirmDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isReserved ? Colors.grey : Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isReserving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isReserved ? 'Already Reserved' : 'Reserve Book',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
