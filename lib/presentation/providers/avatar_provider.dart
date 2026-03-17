import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';

class AvatarProvider extends ChangeNotifier {
  String? _avatarUrl;
  String? _previousAvatarUrl;
  StreamSubscription<void>? _profileSubscription;
  int _updateCount = 0;
  int get updateCount => _updateCount;

  String? get avatarUrl => _avatarUrl;

  AvatarProvider() {
    _loadInitialAvatar();
    _listenToProfileChanges();
  }

  void _loadInitialAvatar() {
    try {
      final authService = getIt<FirebaseAuthService>();
      _avatarUrl = authService.currentUserImageUrl;
      _previousAvatarUrl = _avatarUrl;
      notifyListeners();
    } catch (e) {
      // Service not ready yet
    }
  }

  void _listenToProfileChanges() {
    try {
      final authService = getIt<FirebaseAuthService>();
      _profileSubscription = authService.onProfileChanged.listen((_) {
        refreshAvatar();
      });
    } catch (e) {
      // Service not ready yet
    }
  }

  Future<void> refreshAvatar() async {
    try {
      final authService = getIt<FirebaseAuthService>();
      final newUrl = authService.currentUserImageUrl;

      if (newUrl != _previousAvatarUrl) {
        _avatarUrl = newUrl;
        _previousAvatarUrl = newUrl;
        _invalidateCache();
        notifyListeners();
      }
    } catch (e) {
      // Service not ready
    }
  }

  void onAvatarUpdated(String newUrl) {
    _avatarUrl = newUrl;
    _updateCount++;
    _invalidateCache();
    notifyListeners();
  }

  void _invalidateCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
