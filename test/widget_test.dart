import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/clocks/simple_clock.dart';

void main() {
  testWidgets('Simple Clock test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CountdownProvider(
          // duration: const Duration(seconds: 2),
          child: SimpleClock(),
        ),
      ),
    );

    // That the initial state is waiting
    expect(find.text('Waiting ...'), findsOneWidget);

    // 2 seconds to go
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 1)));
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('00:02'), findsOneWidget);

    // 1 second to go
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 999)));
    await tester.pump(const Duration(milliseconds: 999));
    expect(find.text('00:01'), findsOneWidget);

    // 0 second to go
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 1000)));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('00:00'), findsOneWidget);
    // print(find.byType(Text));

    // Run the countdown timer to completion
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 1000)));
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
