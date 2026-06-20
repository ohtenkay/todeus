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
  const MyApp({super.key, this.todosStream, this.createTodo, this.removeTodo});

  final Stream<TypedQueryResult<List<ListResultItem>>>? todosStream;
  final Future<void> Function()? createTodo;
  final Future<void> Function(TodosId id)? removeTodo;

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
        removeTodo: removeTodo,
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
    this.removeTodo,
  });

  final String title;
  final Stream<TypedQueryResult<List<ListResultItem>>>? todosStream;
  final Future<void> Function()? createTodo;
  final Future<void> Function(TodosId id)? removeTodo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Stream<TypedQueryResult<List<ListResultItem>>> _todosStream;
  bool _creating = false;
  final Set<TodosId> _removing = <TodosId>{};

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

  Future<void> _removeTodo(TodosId id) async {
    if (_removing.contains(id)) return;
    setState(() => _removing.add(id));
    try {
      final removeTodo = widget.removeTodo;
      if (removeTodo == null) {
        await ConvexClient.api.todos.remove(id: id);
      } else {
        await removeTodo(id);
      }
    } finally {
      if (mounted) {
        setState(() => _removing.remove(id));
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
              return _TodosList(
                todos: value,
                removing: _removing,
                onRemove: _removeTodo,
              );
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
  const _TodosList({
    required this.todos,
    required this.removing,
    required this.onRemove,
  });

  final List<ListResultItem> todos;
  final Set<TodosId> removing;
  final Future<void> Function(TodosId id) onRemove;

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
        final isRemoving = removing.contains(todo.id);
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank),
          title: Text(todo.text),
          subtitle: Text(todo.id.toString()),
          trailing: IconButton(
            tooltip: 'Delete todo',
            onPressed: isRemoving ? null : () => onRemove(todo.id),
            icon: isRemoving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        );
      },
    );
  }
}
