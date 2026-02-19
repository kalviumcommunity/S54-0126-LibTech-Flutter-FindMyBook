import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase/firebase_providers.dart";
import "../data/libraries_service.dart";
import "../domain/library_location.dart";

final librariesServiceProvider = Provider<LibrariesService>((ref) {
  return LibrariesService(ref.watch(firestoreProvider));
});

final librariesStreamProvider = StreamProvider<List<LibraryLocation>>((ref) {
  return ref.watch(librariesServiceProvider).watchLibraries();
});
