import '../../client.dart';

Future<CreateResponse> create() async {
  await ConvexClient.instance.mutate('todos:create');
  return (body: null);
}

typedef CreateResponse = ({void body});
