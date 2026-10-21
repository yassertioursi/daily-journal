import 'package:flutter_test/flutter_test.dart';

import 'package:daily_journal/main.dart';

void main() {
  testWidgets('shows the journal home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyJournalApp());

    expect(find.text('Daily Journal'), findsOneWidget);
    expect(find.text('No entries yet'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
  });
}
