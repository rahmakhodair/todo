import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo/firebase_utils.dart';
import 'package:todo/my_theme.dart';

import '../../model/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/list_provider.dart';
import 'edit_task.dart';

class TaskWidget extends StatefulWidget {
  Task task;

  TaskWidget({required this.task});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    var listProvider = Provider.of<ListProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);
    var uId = authProvider.currentUser!.id!;
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, EditTask.routeName,
              arguments: widget.task);
        },
        child: Container(
          margin: EdgeInsets.all(12),
          child: Slidable(
            startActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    FirebaseUtils.deleteTaskFromFireStore(
                            widget.task, authProvider.currentUser!.id!)
                        .timeout(Duration(milliseconds: 500), onTimeout: () {
                      print('Task deleted successfully');
                      listProvider.getAllTasksFromFireStore(
                          authProvider.currentUser!.id!);
                    });
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  backgroundColor: MyTheme.redColor,
                  foregroundColor: MyTheme.whiteColor,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: MyTheme.whiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Theme.of(context).primaryColor,
                    height: 80,
                    width: 4,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          widget.task.title ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: MyTheme.primaryLight),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget.task.description ?? '',
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ],
                  )),
                  InkWell(
                    onTap: () {
                      widget.task.isDone = !widget.task.isDone!;
                      FirebaseUtils.editIsDone(widget.task, uId);
                      setState(() {});
                    },
                    child: widget.task.isDone!
                        ? Text(
                            'Done!',
                            style: TextStyle(
                              color: MyTheme.greenColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 30,
                              color: MyTheme.whiteColor,
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
