/// Library Locations Feature - Barrel file
/// 
/// Exports all public APIs of the library_locations feature
/// Enables clean imports: import 'library_locations.dart';

// Models
export 'models/library_location.dart';

// Domain Layer
export 'domain/entities/library_location_entity.dart';
export 'domain/repositories/library_location_repository.dart';
export 'domain/usecases/library_location_usecases.dart';

// Data Layer (usually kept internal, but exposing for flexibility)
export 'data/datasources/firestore_library_location_datasource.dart';
export 'data/repositories/library_location_repository_impl.dart';
export 'data/sample_library_data.dart';

// Presentation Layer
export 'presentation/controllers/library_locations_providers.dart';
export 'presentation/pages/library_locations_map_page.dart';
export 'presentation/widgets/library_locations_map.dart';
export 'presentation/widgets/library_location_bottom_sheet.dart';
export 'presentation/widgets/library_locations_search_bar.dart';
