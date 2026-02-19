import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../domain/library_location.dart";

class LibrariesService {
  final FirebaseFirestore _firestore;
  LibrariesService(this._firestore);

  Stream<List<LibraryLocation>> watchLibraries() {
    return _firestore.collection(FirestorePaths.libraries).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final map = doc.data();
          return LibraryLocation(
            id: doc.id,
            name: map["name"] as String? ?? "Library",
            address: map["address"] as String? ?? "No address available",
            latitude: (map["lat"] as num?)?.toDouble() ?? 0,
            longitude: (map["lng"] as num?)?.toDouble() ?? 0,
          );
        }).toList(growable: false);
      },
    );
  }
}
