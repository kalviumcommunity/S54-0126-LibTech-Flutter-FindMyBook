# findmybook_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Case Study: From Figma to Functional Flutter UI

### Scenario: "The App That Looked Perfect, But Only on One Phone"
We addressed the issue where a static design fails on diverse screen dimensions by implementing a responsive architecture that adapts to the available space rather than enforcing rigid pixel constraints.

### Translating Figma to Flutter
To ensure the "FindMyBook" app works across devices, we moved away from hardcoded sizes and embraced Flutter's responsive primitives:

1.  **LayoutBuilder for Macro Layouts**:
    We used `LayoutBuilder` in `ResponsiveHomePage` to make high-level decisions. If the width exceeds 600px (tablet/desktop), we switch to a `GridView`. For mobile (< 600px), we stay with a `ListView`.
    ```dart
    body: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const BookGrid();
        } else {
          return const BookList();
        }
      },
    ),
    ```

2.  **Expanded & Flexible for Micro Layouts**:
    Inside the `BookCard`, we used `Expanded` and `Flexible` to ensure content behaves well regardless of the container size.
    - **Expanded**: In `_buildHorizontalLayout`, `Expanded` forces the text column to fill the remaining width after the image, ensuring it uses all available space without overflowing.
    - **Flexible**: Used for the description text. It allows the text to wrap and take up space but shrinks if necessary, preventing "yellow and black" overflow errors.
    ```dart
    Expanded(
      child: Column(
        children: [
          // ...
          Flexible(
            child: Text(book.description, ...),
          ),
        ],
      ),
    )
    ```

3.  **MediaQuery for Context**:
    We used `MediaQuery` to display the current screen width in the AppBar. This helps developers visualize breakpoints in real-time.
    ```dart
    final screenSize = MediaQuery.of(context).size;
    Text('FindMyBook (${screenSize.width.toInt()}px)')
    ```

### Achieving the "Triangle of Good Design"
- **Consistency**: We created a single `BookCard` widget that adapts its internal layout (horizontal vs. vertical) based on the parent's context (`isCompact` flag). This ensures the visual language (typography, colors, shadows) remains identical across mobile and tablet layouts.
- **Responsiveness**: The app feels native on both form factors. Tablet users get a dense grid that utilizes their extra screen real estate, while phone users get a comfortable scrolling list.
- **Usability**: By creating adaptive layouts, touch targets remain accessible, and text remains readable without requiring horizontal scrolling or zooming.
