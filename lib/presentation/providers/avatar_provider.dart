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
      if (kDebugMode) {
        print('AvatarProvider loaded initial avatar: $_avatarUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AvatarProvider _loadInitialAvatar error: $e');
      }
    }
  }

  void _listenToProfileChanges() {
    try {
      final authService = getIt<FirebaseAuthService>();
      _profileSubscription = authService.onProfileChanged.listen((_) {
        refreshAvatar();
      });
    } catch (e) {
      if (kDebugMode) {
        print('AvatarProvider _listenToProfileChanges error: $e');
      }
    }
  }

  Future<void> refreshAvatar() async {
    try {
      final authService = getIt<FirebaseAuthService>();
      final newUrl = authService.currentUserImageUrl;

      // Check if URL changed from previous
      if (newUrl != _previousAvatarUrl) {
        if (kDebugMode) {
          print(
            'AvatarProvider refreshAvatar: URL changed from $_previousAvatarUrl to $newUrl',
          );
        }
        _avatarUrl = newUrl;
        _previousAvatarUrl = newUrl;
        _invalidateCache();
        notifyListeners();
      } else if (kDebugMode) {
        print('AvatarProvider refreshAvatar: URL unchanged ($newUrl)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AvatarProvider refreshAvatar error: $e');
      }
    }
  }

  void onAvatarUpdated(String newUrl) {
    if (kDebugMode) {
      print(
        'AvatarProvider.onAvatarReceived: newUrl=$newUrl, current=$_avatarUrl',
      );
    }
    // Always notify because the image content changed even if URL is the same
    // This handles the case where Cloudflare R2 serves a new image at the same URL
    _avatarUrl = newUrl;
    _updateCount++;
    _invalidateCache();
    notifyListeners();
    if (kDebugMode) {
      print(
        'AvatarProvider: Notified listeners (URL may be same but content changed), updateCount=$_updateCount',
      );
    }
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
