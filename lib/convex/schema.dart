class TodosId {
  final String name;
  static const String tableName = "todos";
  const TodosId(this.name);

  @override
  bool operator ==(Object other) {
    if (other is TodosId) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}
