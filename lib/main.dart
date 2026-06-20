import 'package:flutter/material.dart';
import 'package:todeus/convex/client.dart';
import 'package:todeus/convex_api/api.dart';
import 'package:todeus/convex_api/modules/todos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConvexClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.todosStream, this.createTodo});

  final Stream<TypedQueryResult<List<ListResultItem>>>? todosStream;
  final Future<void> Function()? createTodo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todeus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(
        title: 'Todeus johnsons',
        todosStream: todosStream,
        createTodo: createTodo,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.todosStream,
    this.createTodo,
  });

  final String title;
  final Stream<TypedQueryResult<List<ListResultItem>>>? todosStream;
  final Future<void> Function()? createTodo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Stream<TypedQueryResult<List<ListResultItem>>> _todosStream;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _todosStream =
        widget.todosStream ?? ConvexClient.api.todos.listSubscribe().stream;
  }

  Future<void> _createTodo() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final createTodo = widget.createTodo;
      if (createTodo == null) {
        await ConvexClient.api.todos.create();
      } else {
        await createTodo();
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<TypedQueryResult<List<ListResultItem>>>(
        stream: _todosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          switch (result) {
            case TypedQueryLoading<List<ListResultItem>>():
              return const Center(child: CircularProgressIndicator());
            case TypedQueryError<List<ListResultItem>>(:final message):
              return Center(child: Text('Convex error: $message'));
            case TypedQuerySuccess<List<ListResultItem>>(:final value):
              return _TodosList(todos: value);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _creating ? null : _createTodo,
        tooltip: 'Create todo',
        child: _creating
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}

class _TodosList extends StatelessWidget {
  const _TodosList({required this.todos});

  final List<ListResultItem> todos;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(child: Text('No todos yet. Tap + to add one.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank),
          title: Text(todo.text),
          subtitle: Text(todo.id.toString()),
        );
      },
    );
  }
}
