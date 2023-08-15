import 'package:flutter/material.dart';
import 'package:task_manager_project/ui/screen/show_delete_task.dart';
import 'package:task_manager_project/ui/screen/update_profile_screen.dart';
import 'package:task_manager_project/ui/screen/update_task_status_sheet.dart';

import '../../data/Utils/urls.dart';
import '../../data/model/summery_count_model.dart';
import '../../data/model/task_list_model.dart';
import '../../data/service/network_coller.dart';
import '../../data/service/network_response.dart';
import '../../widgets/list_tile_task.dart';
import '../../widgets/summery_card.dart';
import '../../widgets/user_profile_banar.dart';
import 'create_task_Screen.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({Key? key}) : super(key: key);

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  SummeryCountModel _summeryCountModel = SummeryCountModel();
  TaskListModel _taskListModel = TaskListModel();

  bool _summeryCountInProgress = false, _addNewTaskInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSummeryCount();
      getNewTaskList();
    });
  }

  // Future<void> deleteTask(taskId) async {
  //   final NetworkResponse response =
  //       await NetWorkCaller().getRequest(Urls.deleteTask(taskId));
  //   if (response.isSuccess) {
  //
  //      _taskListModel.data?.removeWhere((element) => element.sId == taskId);
  //     // getNewTaskList();
  //     // getSummeryCount();
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           backgroundColor: Colors.red, content: Text("Task delete failed!")));
  //     }
  //   }
  // }



  Future<void> getSummeryCount() async {
    _summeryCountInProgress = true;
    if (mounted) {
      setState(() {});
    }

    final NetworkResponse response = await NetWorkCaller().getRequest(Urls.taskStatusCount);
    _summeryCountInProgress = false;
    if (mounted) {
      setState(() {});
    }

    if (response.isSuccess) {
      _summeryCountModel = SummeryCountModel.fromJson(response.body!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text("summery data get failed!")));
      }
    }
  }

    Future<void> getNewTaskList() async {
    _addNewTaskInProgress = true;
    if (mounted) {
      setState(() {});

      final NetworkResponse response =
          await NetWorkCaller().getRequest(Urls.newTaskList);

      _addNewTaskInProgress = false;
      if (mounted) {
        setState(() {});
      }
      if (response.isSuccess) {
        _taskListModel = TaskListModel.fromJson(response.body!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text("New Task data failed!")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UpdateProfileScreen()));
              },
              child: const UserProfileBanner(),
            ),

            //  Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: _summeryCountInProgress ? const LinearProgressIndicator() :
            //   const Row(
            //     children: [
            //       SummeryCard(
            //         count: '5',
            //         title: "New Task",
            //       ),
            //       SummeryCard(
            //         count: '4',
            //         title: "In Progress",
            //       ),
            //       SummeryCard(
            //         count: '4',
            //         title: "Completed",
            //       ),
            //       SummeryCard(
            //         count: '3',
            //         title: "Cancel",
            //       ),
            //     ],
            //   ),
            // ),

            Visibility(
              visible: !_summeryCountInProgress,
              replacement: const LinearProgressIndicator(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _summeryCountModel.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return SummeryCard(
                        count: _summeryCountModel.data![index].sum.toString(),
                        title: _summeryCountModel.data![index].sId ?? "New",
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 4,
                        thickness: 1,
                      );
                    },
                  ),
                ),
              ),
            ),

            Expanded(
                child: RefreshIndicator(
              color: Colors.red,
              backgroundColor: Colors.white70,
              onRefresh: () async {
                getNewTaskList();
                getSummeryCount();
              },
              child: Visibility(
                visible: _addNewTaskInProgress == false,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: ListView.separated(
                  itemCount: _taskListModel.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTileTask(
                      data: _taskListModel.data![index],
                      onDeleteTap: () {
                       _deleteTask(_taskListModel.data![index]);
                        // deleteTask(_newTaskListModel.data![index].sId);
                      },
                      onEditTap: () {
                        showStatusUpdateBottomSheet(_taskListModel.data![index]);
                      },
                      color: Colors.lightBlue,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 4,
                      thickness: 1,
                    );
                  },
                ),
              ),
            ))

            // const ListTileTask(text:"New",color: Colors.blue,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateNewTaskScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteTask(TaskData task){
    showDialog(context: context, builder: (context){
      return ShowDeleteTask(
       task: task,
        onDeleteTab: (){
         getNewTaskList();
        },
      );
    });
  }

  void showStatusUpdateBottomSheet(TaskData task) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return UpdateTaskStatusSheet(task: task, onUpdate: () {
          getNewTaskList();
        });
      },
    );
  }

}


