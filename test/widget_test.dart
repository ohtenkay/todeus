// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:todeus/convex_api/api.dart';
import 'package:todeus/convex_api/modules/todos.dart';
import 'package:todeus/main.dart';

void main() {
  testWidgets('shows todos from the injected stream', (tester) async {
    final todos = Stream<TypedQueryResult<List<ListResultItem>>>.value(
      const TypedQuerySuccess([
        (
          creationTime: 1.0,
          id: TodosId('todo-id'),
          createdAt: 1.0,
          text: 'Injected todo',
        ),
      ]),
    );

    await tester.pumpWidget(MyApp(todosStream: todos));
    await tester.pump();

    expect(find.text('Injected todo'), findsOneWidget);
    expect(find.text('todo-id'), findsOneWidget);
  });
}
