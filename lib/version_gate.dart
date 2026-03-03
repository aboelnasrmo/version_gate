/// A lightweight Flutter package that checks for app updates on the
/// App Store and Google Play Store with zero configuration.
///
/// ## Quick Start
/// ```dart
/// import 'package:version_gate/version_gate.dart';
///
/// final result = await VersionGate().check();
/// if (result != null && result.hasUpdate) {
///   result.showBuiltInDialog(context);
/// }
/// ```
library version_gate;

export 'src/core/version_gate.dart';
export 'src/core/version_comparator.dart';
export 'src/core/frequency_guard.dart';
export 'src/checkers/ios_store_checker.dart';
export 'src/checkers/android_store_checker.dart';
export 'src/models/version_check_result.dart';
export 'src/models/check_frequency.dart';
export 'src/models/update_mode.dart';
export 'src/widgets/update_dialog.dart';
export 'src/widgets/update_banner.dart';
export 'src/widgets/update_block_screen.dart';
