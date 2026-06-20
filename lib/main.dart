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

class MyHomePage extends StatelessWidget {
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

  Future<void> _createTodo() async {
    final createTodo = this.createTodo;
    if (createTodo == null) {
      await ConvexClient.api.todos.create();
    } else {
      await createTodo();
    }
  }

  Future<void> _removeTodo(TodosId id) async {
    final removeTodo = this.removeTodo;
    if (removeTodo == null) {
      await ConvexClient.api.todos.remove(id: id);
    } else {
      await removeTodo(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: StreamBuilder<TypedQueryResult<List<ListResultItem>>>(
        stream: todosStream ?? ConvexClient.api.todos.listSubscribe().stream,
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
              return _TodosList(todos: value, onRemove: _removeTodo);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTodo,
        tooltip: 'Create todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TodosList extends StatelessWidget {
  const _TodosList({required this.todos, required this.onRemove});

  final List<ListResultItem> todos;
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
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank),
          title: Text(todo.text),
          subtitle: Text(todo.id.toString()),
          trailing: IconButton(
            tooltip: 'Delete todo',
            onPressed: () => onRemove(todo.id),
            icon: const Icon(Icons.delete_outline),
          ),
        );
      },
    );
  }
}
