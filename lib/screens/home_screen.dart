import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/screens/add_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List items = [];
  void showErrorMessage(String message) {
      final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  Future<void> fetchToDo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> navigateToAddPage() async {
      final route = MaterialPageRoute(
        builder: (context) => AddToDoPage(),
      );
      await Navigator.push(context, route);
      setState(() {
        isLoading = true;
      });
      fetchToDo();
    }
     Future<void> deleteById(String id) async {
      final url = 'https://api.nstack.in/v1/todos/$id';
      final uri = Uri.parse(url);
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        final filtered =
            items.where((element) => element['_id'] != id).toList();
      } else {
        showErrorMessage('Can not Delete');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: RefreshIndicator(
          onRefresh: fetchToDo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      navigateToEditPage(item);
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('Add ToDo'),
      ),
    );
  }

Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(ToDo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });   
    fetchToDo();
  }
}
