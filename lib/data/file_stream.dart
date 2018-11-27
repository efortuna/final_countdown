import 'dart:async';
import 'dart:io';

import 'package:watcher/watcher.dart';
import 'package:path_provider/path_provider.dart';

// Forwards on all File events, and helps us avoid using a FutureBuilder.
class FileStream extends Stream<List<String>> {
  StreamController<List<String>> _controller = new StreamController.broadcast();
  @override
  StreamSubscription<List<String>> listen(void Function(List<String> event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    _setUpFileWatching();
    return _controller.stream.listen(onData);
  }

  _setUpFileWatching() async {
    Directory dir = await getApplicationDocumentsDirectory();
    DirectoryWatcher(dir.path).events.listen((WatchEvent event) {
      if (event.type == ChangeType.ADD) {
        // A file has been added. Trigger a new event with the updated list of files.
        var photos = dir
            .listSync()
            .where((FileSystemEntity e) => e is File && e.path.endsWith('jpg'))
            .map<String>((FileSystemEntity file) => file.path)
            .toList()
              ..sort((a, b) => -a.compareTo(b));
        _controller.add(photos);
      }
    });
  }
}
