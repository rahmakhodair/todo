import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/firebase_utils.dart';
import 'package:todo/model/task.dart';

import '../../dialog_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/list_provider.dart';

class AddTaskBottomSheet extends StatefulWidget {
  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  DateTime selectedDate = DateTime.now();
  var formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";
  late ListProvider listProvider;

  @override
  Widget build(BuildContext context) {
    listProvider = Provider.of<ListProvider>(context);

    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'Add New Task',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (text) {
                        title = text;
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Please enter task title';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "Enter Task title"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (text) {
                        description = text;
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Please enter task description';
                        }
                        return null;
                      },
                      decoration:
                          InputDecoration(hintText: "Enter Task Description"),
                      maxLines: 4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Date',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        showCalendar();
                      },
                      child: Text(
                        '${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        addTask();
                      },
                      child: Text(
                        'Add',
                        style: Theme.of(context).textTheme.titleLarge,
                      ))
                ],
              ))
        ],
      ),
    );
  }

  void showCalendar() async {
    var chosenDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (chosenDate != null) {
      selectedDate = chosenDate;
      setState(() {});
    }
  }

  void addTask() {
    if (formKey.currentState?.validate() == true) {
      Task task =
          Task(title: title, description: description, dateTime: selectedDate);
      DialogUtils.showLoading(context, 'Loading...');
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      FirebaseUtils.addTaskToFireStore(task, authProvider.currentUser!.id!)
          .then((value) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(context, 'Task added successfully',
            posActionName: 'ok', posAction: () {
          Navigator.pop(context);
          // Navigator.pop(context);
        });
      }).timeout(Duration(milliseconds: 500), onTimeout: () {
        print('todo is added');
        listProvider.getAllTasksFromFireStore(authProvider.currentUser!.id!);
        Navigator.pop(context);
      });
    }
  }
}
