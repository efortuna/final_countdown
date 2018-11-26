import 'package:flutter/widgets.dart';

import 'package:final_countdown/data/file_stream.dart';

/// Use to maintain state between hot restarts
/// Make sure you wrap this above the MaterialApp widget
/// or hot reload will affect it
class FileStreamProvider extends InheritedWidget {
  FileStreamProvider({
    Key key,
    @required Widget child,
  })  : assert(child != null),
        stream = FileStream(),
        super(key: key, child: child);

  final FileStream stream;

  static FileStreamProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(FileStreamProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}
