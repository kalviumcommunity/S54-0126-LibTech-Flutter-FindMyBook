/// Example Page - Shows how to use all core components
/// 
/// This demonstrates:
/// - Theme system (colors, spacing, typography)
/// - All component types
/// - Clean code organization
/// - State management patterns
///
/// MERN Comparison: Like a React component that demonstrates best practices

import 'package:flutter/material.dart';
import '../core/widgets/index.dart';
import '../core/theme/index.dart';

class ExampleComponentPage extends StatefulWidget {
  const ExampleComponentPage({Key? key}) : super(key: key);

  @override
  State<ExampleComponentPage> createState() => _ExampleComponentPageState();
}

class _ExampleComponentPageState extends State<ExampleComponentPage> {
  // Controllers for inputs
  late TextEditingController searchCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;

  // State variables
  bool isLoading = false;
  String? selectedGenre;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // ============= Event Handlers =============

  void _handleSearch(String query) {
    debugPrint('Search: $query');
    // Trigger search logic here
  }

  void _handleSubmit() async {
    setState(() => isLoading = true);
    
    // Simulate async operation
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => isLoading = false);
      AppSnackbars.success(context, 'Successfully submitted!');
    }
  }

  void _handleDelete() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Delete Item?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      AppSnackbars.success(context, 'Item deleted');
    }
  }

  void _handleShowInfo() {
    AppSnackbars.info(
      context,
      'This is an info message!',
    );
  }

  // ============= Build Methods =============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: AppPadding(
          all: AppSpacing.lg,
          child: AppGap(
            gap: AppSpacing.xxl,
            children: [
              // ============= Buttons Section =============
              _buildButtonsSection(),

              // ============= Input Fields Section =============
              _buildInputsSection(),

              // ============= Cards Section =============
              _buildCardsSection(),

              // ============= Loaders Section =============
              _buildLoadersSection(),

              // ============= Spacing Section =============
              _buildSpacingSection(),

              // ============= Colors Section =============
              _buildColorsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ============= Button Examples =============

  Widget _buildButtonsSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Buttons',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppGap(
          gap: AppSpacing.md,
          children: [
            // Filled Button
            AppButton(
              onPressed: _handleSubmit,
              label: 'Save Changes',
              isLoading: isLoading,
              fullWidth: true,
              icon: Icons.save,
            ),

            // Outlined Button
            AppOutlinedButton(
              onPressed: _handleDelete,
              label: 'Delete Item',
              fullWidth: true,
              borderColor: AppColors.error,
              textColor: AppColors.error,
            ),

            // Text Button
            AppTextButton(
              onPressed: _handleShowInfo,
              label: 'Show Info',
              icon: Icons.info,
            ),

            // Icon Button
            AppIconButton(
              icon: Icons.star,
              onPressed: () => AppSnackbars.success(context, 'Favorited!'),
              tooltip: 'Add to favorites',
              backgroundColor: AppColors.primary.withOpacity(0.1),
              iconColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  // ============= Input Examples =============

  Widget _buildInputsSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Input Fields',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppGap(
          gap: AppSpacing.lg,
          children: [
            // Search Field
            AppSearchField(
              controller: searchCtrl,
              hint: 'Search for books...',
              onChanged: _handleSearch,
            ),

            // Email Field
            AppTextField(
              controller: emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),

            // Password Field
            AppPasswordField(
              controller: passwordCtrl,
              label: 'Password',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password required';
                if (value!.length < 8) return 'Min 8 characters';
                return null;
              },
            ),

            // Dropdown
            AppDropdownField<String>(
              label: 'Select Genre',
              items: ['Fiction', 'Science', 'History', 'Biography'],
              value: selectedGenre,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() => selectedGenre = value);
                AppSnackbars.info(context, 'Genre: $value');
              },
            ),
          ],
        ),
      ],
    );
  }

  // ============= Card Examples =============

  Widget _buildCardsSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Cards',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppGap(
          gap: AppSpacing.lg,
          children: [
            // Book Card
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AppHorizontalGap(
                gap: AppSpacing.lg,
                children: [
                  BookCard(
                    title: 'The Great Gatsby',
                    author: 'F. Scott Fitzgerald',
                    rating: 4.5,
                    isAvailable: true,
                    categoryColor: AppColors.bookBluish,
                    onTap: () => AppSnackbars.info(context, 'Book tapped!'),
                  ),
                  BookCard(
                    title: '1984',
                    author: 'George Orwell',
                    rating: 4.8,
                    isAvailable: false,
                    categoryColor: AppColors.bookPurplish,
                  ),
                ],
              ),
            ),

            // User Card
            UserCard(
              name: 'John Doe',
              role: 'Student',
              onTap: () => AppSnackbars.info(context, 'Profile tapped!'),
            ),

            // Stat Cards in Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              children: [
                StatCard(
                  label: 'Books',
                  value: '24',
                  icon: Icons.library_books,
                  iconColor: AppColors.primary,
                ),
                StatCard(
                  label: 'Authors',
                  value: '18',
                  icon: Icons.person,
                  iconColor: AppColors.secondary,
                ),
                StatCard(
                  label: 'Genres',
                  value: '12',
                  icon: Icons.category,
                  iconColor: AppColors.success,
                ),
              ],
            ),

            // Action Card
            ActionCard(
              title: 'New Feature!',
              description: 'Discover personalized book recommendations',
              buttonLabel: 'Explore',
              icon: Icons.lightbulb,
              onButtonTap: () => AppSnackbars.success(
                context,
                'Opening recommendations...',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============= Loader Examples =============

  Widget _buildLoadersSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Loaders & Skeletons',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppGap(
          gap: AppSpacing.lg,
          children: [
            // Circular Loader
            const Center(child: AppLoader()),

            // Progress Indicator
            const AppProgressIndicator(
              progress: 0.65,
              label: 'Loading books...',
            ),

            // Skeleton Lines
            AppGap(
              gap: AppSpacing.sm,
              children: const [
                AppShimmer(width: double.infinity, height: 20),
                AppShimmer(width: double.infinity, height: 16),
                AppShimmer(width: 150, height: 16),
              ],
            ),

            // Skeleton Card
            const AppShimmerCard(height: 150),
          ],
        ),
      ],
    );
  }

  // ============= Spacing Examples =============

  Widget _buildSpacingSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Spacing & Layout',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppGap(
          gap: AppSpacing.lg,
          children: [
            // AppGap Example
            AppCard(
              child: AppGap(
                gap: AppSpacing.md,
                children: [
                  Text(
                    'Using AppGap',
                    style: AppTypography.titleMedium,
                  ),
                  Text(
                    'Notice consistent spacing between items',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // AppPadding Example
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Extra padding applied here',
                style: AppTypography.bodyMedium,
              ),
            ),

            // AppBox Example
            AppBox(
              padding: AppSpacing.lg,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.cardBorderRadius,
              child: Text(
                'AppBox with custom styling',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============= Color Palette Example =============

  Widget _buildColorsSection() {
    return AppGap(
      gap: AppSpacing.md,
      children: [
        Text(
          'Color Palette',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _buildColorSwatch('Primary', AppColors.primary),
            _buildColorSwatch('Secondary', AppColors.secondary),
            _buildColorSwatch('Success', AppColors.success),
            _buildColorSwatch('Error', AppColors.error),
            _buildColorSwatch('Warning', AppColors.warning),
            _buildColorSwatch('Info', AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
