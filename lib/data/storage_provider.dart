import 'package:flutter/widgets.dart';

import 'package:final_countdown/data/persistence.dart';

/// Provides the storage directory for photos
class PhotoStorageProvider extends InheritedWidget {
  PhotoStorageProvider({
    Key key,
    @required Widget child,
  })  : storage = PhotoDirectory(),
        super(key: key, child: child);
  final PhotoDirectory storage;

  static PhotoDirectory of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(PhotoStorageProvider)
              as PhotoStorageProvider)
          ?.storage;

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}

// Accessor to a temporary directory where photos are stored, so that the photos are
// persistent across hot restarts, from countdown to countdown.
class PhotoDirectory {
  PhotoDirectory() {
    initializeDirectory();
  }

  initializeDirectory() async {
    path = (await loadStorage()).path;
  }

  String path;
}
