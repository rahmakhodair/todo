import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/model/my_user.dart';
import 'package:todo/model/task.dart';

class FirebaseUtils {
  static CollectionReference<Task> getTasksCollection(String uId) {
    return getUsersCollection()
        .doc(uId)
        .collection('tasks')
        .withConverter<Task>(
            fromFirestore: (snapshot, options) =>
                Task.formFireStore(snapshot.data()!),
            toFirestore: (task, options) => task.toFireStore());
  }

  static Future<void> addTaskToFireStore(Task task, String uId) {
    var taskCollection = getTasksCollection(uId);
    DocumentReference<Task> docRef = taskCollection.doc();
    task.id = docRef.id;
    return docRef.set(task);
  }

  static Future<void> deleteTaskFromFireStore(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).delete();
  }

  static CollectionReference<MyUser> getUsersCollection() {
    return FirebaseFirestore.instance
        .collection(MyUser.collectionName)
        .withConverter<MyUser>(
            fromFirestore: (snapshot, options) =>
                MyUser.fromFireStore(snapshot.data()),
            toFirestore: (user, options) => user.toFireStore());
  }

  static Future<void> addUserToFireStore(MyUser myUser) {
    return getUsersCollection().doc(myUser.id).set(myUser);
  }

  static Future<MyUser?> readUserFromFireStore(String uId) async {
    var querySnapShot = await getUsersCollection().doc(uId).get();
    return querySnapShot.data();
  }

  static Future<void> editTask(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).update(task.toFireStore());
  }

  static Future<void> editIsDone(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).update({'isDone': task.isDone});
  }
}
