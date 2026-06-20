// ignore_for_file: non_constant_identifier_names

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todeus/convex/functions/todos/list.dart' as todos_list;
import 'package:todeus/convex/schema.dart';
import 'package:todeus/main.dart';

void main() {
  testWidgets('shows todos from the injected stream', (tester) async {
    final todos = Stream<todos_list.ListResponse>.value((
      body: [
        (
          $_creationTime: 1.0,
          $_id: const TodosId('todo-id'),
          createdAt: 1.0,
          text: 'Injected todo',
        ),
      ].toIList(),
    ));

    await tester.pumpWidget(MyApp(todosStream: todos));
    await tester.pump();

    expect(find.text('Injected todo'), findsOneWidget);
    expect(find.text('todo-id'), findsOneWidget);
  });
}
