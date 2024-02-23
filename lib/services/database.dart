import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maxfit/domain/user.dart';
import 'package:maxfit/domain/workout.dart';

class DatabaseService{
  final CollectionReference _workoutCollection = Firestore.instance.collection('workouts');
  final CollectionReference _workoutScheduleCollection = Firestore.instance.collection('workoutSchedules');
  final CollectionReference _userDataCollection = Firestore.instance.collection("userData");

  Future addOrUpdateWorkout(WorkoutSchedule schedule) async {
    DocumentReference workoutRef = _workoutCollection.document(schedule.uid);

    return workoutRef.setData(schedule.toWorkoutMap()).then((_) async{
      var docId = workoutRef.documentID;
      await _workoutScheduleCollection.document(docId).setData(schedule.toMap());
    });
  }

  Stream<List<Workout>> getWorkouts({String level, String author})
  {
    Query query;
    if(author != null)
      query = _workoutCollection.where('author', isEqualTo: author);
    else
      query = _workoutCollection.where('isOnline', isEqualTo: true);

    if(level != null)
      query = query.where('level', isEqualTo: level);

      //query = query.orderBy('createdOn', descending: true);
      //query = query.where(FieldPath.documentId, whereIn: ["KO7D0oSrOfM1Y5A0RpHG","o6Nz4MS9b39mR8RYxEmp"]);

    return query.snapshots().map((QuerySnapshot data) =>
        data.documents.map((DocumentSnapshot doc) => Workout.fromJson(doc.data, id: doc.documentID)).toList());
  }

  Future<WorkoutSchedule> getWorkout(String id) async{
    var doc = await _workoutScheduleCollection.document(id).get();
    return WorkoutSchedule.fromJson(doc.documentID, doc.data);
  }

  // User Data
  Future<UserData> getUserData(String uid) async {
      var userDataDoc = await _userDataCollection.document(uid).get();
      var userData = UserData.fromJson(uid, userDataDoc.data);
      return userData;
  }

  Future addUserWorkout(User user, WorkoutSchedule workout) async {
    var userWorkout = UserWorkout.fromWorkout(workout);
    user.userData.addUserWorkout(userWorkout);
    final data = user.userData.toMap();
    await _userDataCollection.document(user.id).setData(data);
  }

  Stream<List<Workout>> getUserWorkouts(User user)
  {
    var query = _workoutCollection.where(FieldPath.documentId, whereIn: user.workoutIds);

    return query.snapshots().map((QuerySnapshot data) =>
        data.documents.map((DocumentSnapshot doc) => Workout.fromJson(doc.data, id: doc.documentID)).toList());
  }
}