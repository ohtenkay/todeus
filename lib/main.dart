import 'package:flutter/material.dart';
import 'package:todeus/convex/client.dart';
import 'package:todeus/convex/functions/todos/create.dart' as todos_create;
import 'package:todeus/convex/functions/todos/list.dart' as todos_list;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConvexClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.todosStream, this.createTodo});

  final Stream<todos_list.ListResponse>? todosStream;
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
  final Stream<todos_list.ListResponse>? todosStream;
  final Future<void> Function()? createTodo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Stream<todos_list.ListResponse> _todosStream;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _todosStream = widget.todosStream ?? todos_list.listStream();
  }

  Future<void> _createTodo() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final createTodo = widget.createTodo;
      if (createTodo == null) {
        await todos_create.create();
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
      body: StreamBuilder<todos_list.ListResponse>(
        stream: _todosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Convex error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!.body;
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
                subtitle: Text(todo.$_id.toString()),
              );
            },
          );
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
