import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentManagementScreen extends StatefulWidget {
  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<Map<String, dynamic>> classes = [];
  Map<String, dynamic>? selectedClass;
  List<Map<String, dynamic>> students = []; // State variable to store fetched students

  @override
  void initState() {
    super.initState();
    // Fetch classes from the backend API and update the 'classes' list
    fetchClassesFromBackend();
  }

  // Method to fetch classes from the backend
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

  // Function to fetch students based on the selected class
  Future<void> fetchStudentsByClass(int classCode) async {
    final String apiUrl = 'http://10.0.2.2:8082/classes/$classCode/etudiants';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('_embedded') &&
            responseData['_embedded'] != null &&
            responseData['_embedded'].containsKey('etudiants')) {
          List<dynamic> studentsData = responseData['_embedded']['etudiants'];
          List<Map<String, dynamic>> fetchedStudents =
          List<Map<String, dynamic>>.from(studentsData);
          setState(() {
            students = fetchedStudents; // Update the state with fetched students
          });
        } else {
          throw Exception('No students found for class with ID: $classCode');
        }
      } else {
        throw Exception('Failed to load students for class with ID: $classCode');
      }
    } catch (error) {
      throw Exception('Error fetching students: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<Map<String, dynamic>>(
              value: selectedClass,
              hint: Text('Select a class'),
              items: classes.map<DropdownMenuItem<Map<String, dynamic>>>((
                  classData,
                  ) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: classData,
                  child: Text(classData['nomClass'].toString()),
                );
              }).toList(),
              onChanged: (Map<String, dynamic>? classData) {
                setState(() {
                  selectedClass = classData;
                });
                if (classData != null) {
                  fetchStudentsByClass(classData['codClass']);
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    subtitle: Text('ID: ${students[index]['id']}'),
                    title: Text(students[index]['nom']), // Modify key to match the student's name
                    // Modify key for student ID
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}