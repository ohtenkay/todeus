// ignore_for_file: non_constant_identifier_names

import 'package:dartvex/dartvex.dart' as dartvex;

import '../../client.dart';
import '../../schema.dart';

Future<ListResponse> list() async {
  final response = await ConvexClient.instance.query('todos:list');
  return _deserialize(response);
}

Stream<ListResponse> listStream() {
  final subscription = ConvexClient.instance.subscribe('todos:list');
  return subscription.stream.asyncExpand((result) {
    switch (result) {
      case dartvex.QuerySuccess(:final value):
        return Stream.value(_deserialize(value));
      case dartvex.QueryError(:final message):
        return Stream.error(dartvex.ConvexException(message));
      case dartvex.QueryLoading():
        return const Stream.empty();
    }
  });
}

ListResponse _deserialize(dynamic value) {
  final todos = (value as List<dynamic>).map((todo) {
    final map = todo as Map<String, dynamic>;
    return (
      $_creationTime: (map['_creationTime'] as num).toDouble(),
      $_id: TodosId(map['_id'] as String),
      createdAt: (map['createdAt'] as num).toDouble(),
      text: map['text'] as String,
    );
  }).toList(growable: false);

  return (
    body: todos,
  );
}

typedef ListResponse = ({
  List<({double $_creationTime, TodosId $_id, double createdAt, String text})>
  body,
});
