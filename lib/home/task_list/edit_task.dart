import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialog_utils.dart';
import '../../firebase_utils.dart';
import '../../model/task.dart';
import '../../my_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/list_provider.dart';

class EditTask extends StatefulWidget {
  static const String routeName = 'edit';

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  DateTime selectedDate = DateTime.now();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  late ListProvider listProvider;
  late Task task;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      task = ModalRoute.of(context)!.settings.arguments as Task;
      titleController.text = task.title!;
      descriptionController.text = task.description!;
      selectedDate = task.dateTime!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var ScreenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: ScreenSize.height * 0.1,
            color: MyTheme.primaryLight,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenSize.width * 0.1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Edit Task',
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
                              controller: titleController,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'please enter task title';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter Task Title',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: descriptionController,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'please enter task description';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter Task Description',
                              ),
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Select Date',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          InkWell(
                            onTap: () {
                              showCalender();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              editTask();
                            },
                            child: Text(
                              'Save Changes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCalender() async {
    var chosenDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosenDate != null) {
      selectedDate = chosenDate;
      setState(() {});
    }
  }

  void editTask() {
    if (formKey.currentState?.validate() == true) {
      /// add task to firebase
      task.title = titleController.text;
      task.description = descriptionController.text;
      task.dateTime = selectedDate;

      DialogUtils.showLoading(context, 'Loading...');
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      FirebaseUtils.editTask(task, authProvider.currentUser!.id!).then((value) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(context, 'Task edited successfully',
            posActionName: 'ok', posAction: () {
          Navigator.pop(context);
          // Navigator.pop(context);
        });
      }).timeout(const Duration(milliseconds: 500), onTimeout: () {
        print('ToDo edited successfully');
        listProvider.getAllTasksFromFireStore(authProvider.currentUser!.id!);
        Navigator.pop(context);
      });
    }
  }
}
