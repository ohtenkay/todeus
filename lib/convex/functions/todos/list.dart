// ignore_for_file: type=lint, unused_import, unnecessary_question_mark, dead_code, dead_null_aware_expression
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter, invalid_use_of_internal_member
import "package:convex_dart/src/convex_dart_for_generated_code.dart";
import "dart:typed_data";
import "../../schema.dart";
import "../../literals.dart";

Future<ListResponse> list() async {
  final serializedArgs = _serialize(null);
  final response = await InternalConvexClient.instance.query(
    name: 'todos:list',
    args: serializedArgs,
  );
  final deserializedResponse = _deserialize(response);
  return deserializedResponse;
}

Stream<ListResponse> listStream() {
  final serializedArgs = _serialize(null);
  return InternalConvexClient.instance.stream(
    name: 'todos:list',
    args: serializedArgs,
    decodeResult: _deserialize,
  );
}

@pragma("vm:prefer-inline")
BTreeMapStringValue _serialize(void args) {
  return hashmapToBtreemap(hashmap: {});
}

@pragma("vm:prefer-inline")
ListResponse _deserialize(Value map) {
  return (
    body: (decodeValue(map) as IList<dynamic>)
        .map(
          (on963601) => (on963601 as IMap<String, dynamic>).then(
            (on896509) => (
              $_creationTime: (on896509['_creationTime'] as double),
              $_id: TodosId(on896509['_id'] as String),
              createdAt: (on896509['createdAt'] as double),
              text: (on896509['text'] as String),
            ),
          ),
        )
        .toIList(),
  );
}

typedef ListResponse = ({
  IList<({double $_creationTime, TodosId $_id, double createdAt, String text})>
  body,
});
