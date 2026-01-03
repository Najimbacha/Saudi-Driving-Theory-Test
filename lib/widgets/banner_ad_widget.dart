import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../state/app_state.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _banner;
  bool _loading = false;
  bool? _previousAdsEnabled;

  void _disposeBanner() {
    _banner?.dispose();
    _banner = null;
  }

  void _loadBanner() {
    if (_loading || _banner != null) return;
    _loading = true;
    final banner = AdService.instance.createBanner();
    if (banner == null) {
      _loading = false;
      return;
    }
    banner.load();
    if (mounted) {
      setState(() {
        _banner = banner;
        _loading = false;
      });
    } else {
      _loading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _previousAdsEnabled = ref.read(appSettingsProvider).adsEnabled;
    if (_previousAdsEnabled == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadBanner();
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsEnabled = ref.watch(appSettingsProvider.select((state) => state.adsEnabled));
    
    // Handle changes to adsEnabled
    if (_previousAdsEnabled != adsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (adsEnabled) {
          _loadBanner();
        } else {
          setState(() {
            _disposeBanner();
          });
        }
      });
      _previousAdsEnabled = adsEnabled;
    }
    
    if (!adsEnabled) return const SizedBox.shrink();
    if (_banner == null) return const SizedBox.shrink();
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
