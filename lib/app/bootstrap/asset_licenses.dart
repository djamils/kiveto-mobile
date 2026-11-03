import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the licences of the bundled assets (shown by the licence
/// page): DM Sans (SIL OFL 1.1) and the Lucide icons drawn by the UI kit
/// (ISC, with the Feather MIT notice).
void registerAssetLicenses({AssetBundle? bundle}) {
  final assets = bundle ?? rootBundle;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'DM Sans',
    ], await assets.loadString('assets/fonts/OFL.txt'));
    yield LicenseEntryWithLineBreaks(const [
      'Lucide',
    ], await assets.loadString('assets/licenses/lucide.txt'));
  });
}
