// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: type=lint, unused_element, unused_import, unused_local_variable

import '../runtime.dart';
import '../schema.dart';
import 'package:dartvex/dartvex.dart';

class TodosApi {
  const TodosApi(this._client);

  final ConvexFunctionCaller _client;

  Future<Null> create() async {
    await _client.mutate('todos:create', const <String, dynamic>{});
    return null;
  }

  Future<List<ListResultItem>> list() async {
    final raw$ = await _client.query('todos:list', const <String, dynamic>{});
    return expectList(
      raw$,
      label: 'ListResult',
    ).map((item) => _decodeListResultItem(item)).toList();
  }

  TypedConvexSubscription<List<ListResultItem>> listSubscribe() {
    final subscription$ = _client.subscribe(
      'todos:list',
      const <String, dynamic>{},
    );
    final typedStream$ = subscription$.stream.map((event) {
      switch (event) {
        case QuerySuccess(:final value):
          return TypedQuerySuccess<List<ListResultItem>>(
            expectList(
              value,
              label: 'ListResult',
            ).map((item) => _decodeListResultItem(item)).toList(),
          );
        case QueryLoading(:final hasPendingWrites):
          return TypedQueryLoading<List<ListResultItem>>(
            hasPendingWrites: hasPendingWrites,
          );
        case QueryError(:final message, :final data, :final logLines):
          return TypedQueryError<List<ListResultItem>>(
            message,
            data: data,
            logLines: logLines,
          );
      }
    });
    return TypedConvexSubscription<List<ListResultItem>>(
      subscription$,
      typedStream$,
    );
  }
}

typedef ListResultItem = ({
  double creationTime,
  TodosId id,
  double createdAt,
  String text,
});

Map<String, dynamic> _encodeListResultItem(ListResultItem value$) {
  final (creationTime: creationTime, id: id, createdAt: createdAt, text: text) =
      value$;
  return <String, dynamic>{
    '_creationTime': creationTime,
    '_id': id.value,
    'createdAt': createdAt,
    'text': text,
  };
}

ListResultItem _decodeListResultItem(dynamic raw) {
  final map = expectMap(raw, label: 'ListResultItem');
  if (!map.containsKey('_creationTime')) {
    throw FormatException(
      'Missing required field "_creationTime" for ListResultItem',
    );
  }
  if (!map.containsKey('_id')) {
    throw FormatException('Missing required field "_id" for ListResultItem');
  }
  if (!map.containsKey('createdAt')) {
    throw FormatException(
      'Missing required field "createdAt" for ListResultItem',
    );
  }
  if (!map.containsKey('text')) {
    throw FormatException('Missing required field "text" for ListResultItem');
  }
  return (
    creationTime: expectDouble(
      map['_creationTime'],
      label: 'ListResultItemCreationTime',
    ),
    id: TodosId(expectString(map['_id'], label: 'ListResultItemId')),
    createdAt: expectDouble(map['createdAt'], label: 'ListResultItemCreatedAt'),
    text: expectString(map['text'], label: 'ListResultItemText'),
  );
}
