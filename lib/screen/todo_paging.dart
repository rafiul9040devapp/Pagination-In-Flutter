import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../model/todo.dart';

class TodoPaging extends StatefulWidget {
  const TodoPaging({super.key});

  @override
  State<TodoPaging> createState() => _TodoPagingState();
}

class _TodoPagingState extends State<TodoPaging> with TickerProviderStateMixin{
  final ScrollController _scrollController = ScrollController();
  List<Todo> todoList = [];
  late int total;
  int page = 1;
  int limit = 15;
  bool _isLoading = false;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: true);
    fetchTodoFromApi();
    _scrollController.addListener(loadMoreData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO List'),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            final todo = todoList[index];
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Text(todo.id.toString()),
                  ),
                  title: Text(todo.todo ?? ''),
                ),
                if(index == todoList.length-1 && _isLoading)
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(value: controller.value,),),
                  ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.grey,
              indent: 16,
              height: 5,
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchTodoFromApi() async {
    _isLoading = true;
    setState(() {});

    Uri uri = Uri.parse(
        'https://dummyjson.com/todos?limit=$limit&skip=${(page - 1) * limit}');
    Response response = await get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      total = responseData['total'];
      List<Todo> newTodos = (responseData['todos'] as List<dynamic>)
          .map((response) => Todo.fromJson(response))
          .toList();
      todoList.addAll(newTodos);
      page++;
      _isLoading = false;
      setState(() {});
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to load the TODO')));
      }
    }
  }

  void loadMoreData() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        todoList.length < total) {
      fetchTodoFromApi();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
