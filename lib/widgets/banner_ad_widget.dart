import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _isAdLoaded = false;
  bool _loading = false;

  void _disposeBanner() {
    _banner?.dispose();
    _banner = null;
    _isAdLoaded = false;
  }

  void _loadBanner() {
    if (_loading || _banner != null) return;
    _loading = true;
    final banner = AdService.instance.createBanner(
      onLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
            _loading = false;
          });
        }
      },
      onFailed: () {
        if (mounted) {
          setState(() {
            _banner = null;
            _isAdLoaded = false;
            _loading = false;
          });
        }
      },
    );
    if (banner == null) {
      _loading = false;
      return;
    }
    _banner = banner;
    banner.load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBanner();
      }
    });
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show when the ad has actually loaded content.
    if (_banner == null || !_isAdLoaded) return const SizedBox.shrink();
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
