import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupsManagementScreen extends StatefulWidget {
  @override
  _GroupsManagementScreenState createState() => _GroupsManagementScreenState();
}

class _GroupsManagementScreenState extends State<GroupsManagementScreen> {
  List<Map<String, dynamic>> classes = [];

  @override
  void initState() {
    super.initState();
    fetchClassesFromBackend();
  }

  Future<void> fetchClassesFromBackend() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8082/classes'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('_embedded') && data['_embedded'] != null) {
          List<dynamic> classesData = data['_embedded']['classes'];
          setState(() {
            classes = List<Map<String, dynamic>>.from(classesData);
          });
        } else {
          throw Exception('No classes found');
        }
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (error) {
      print('Error fetching classes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(classes[index]['nomClass'] ?? 'N/A'),
              subtitle: Text('ID: ${classes[index]['codClass'] ?? 'N/A'}'),
            );
          },
        ),
      ),
    );
  }
}