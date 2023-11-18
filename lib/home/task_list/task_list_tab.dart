import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/home/task_list/task_widget.dart';
import 'package:todo/my_theme.dart';
import 'package:todo/providers/list_provider.dart';

import '../../providers/auth_provider.dart';

class TaskListTab extends StatefulWidget {
  @override
  State<TaskListTab> createState() => _TaskListTabState();
}

class _TaskListTabState extends State<TaskListTab> {
  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var listProvider = Provider.of<ListProvider>(context);
    if (listProvider.tasksList.isEmpty) {
      listProvider.getAllTasksFromFireStore(authProvider.currentUser!.id!);
    }
    return Column(
      children: [
        CalendarTimeline(
          initialDate: listProvider.selectDate,
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now().add(Duration(days: 365)),
          onDateSelected: (date) {
            listProvider.changeSelectDate(date, authProvider.currentUser!.id!);
          },
          leftMargin: 20,
          monthColor: MyTheme.blackColor,
          dayColor: MyTheme.blackColor,
          activeDayColor: MyTheme.whiteColor,
          activeBackgroundDayColor: Theme.of(context).primaryColor,
          dotsColor: MyTheme.whiteColor,
          selectableDayPredicate: (date) => true,
          locale: 'en_ISO',
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return TaskWidget(task: listProvider.tasksList[index]);
            },
            itemCount: listProvider.tasksList.length,
          ),
        )
      ],
    );
  }
}
