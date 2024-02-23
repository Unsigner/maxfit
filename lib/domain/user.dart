import 'package:firebase_auth/firebase_auth.dart';
import 'package:maxfit/domain/workout.dart';

class User{
  String id;
  UserData userData;

  User.fromFirebase(FirebaseUser fUser){
    id = fUser.uid;
  }

  void setUserData(UserData userData){
    this.userData = userData;
  }

  bool hasActiveWorkout(String uid)=> userData != null && userData.workouts != null
    && userData.workouts.any((w) => w.workoutId == uid && w.completedOnMs == null);

  List<String> get workoutIds => userData != null && userData.workouts != null
    ? userData.workouts.map((e) => e.workoutId).toList()
    : List<String>();

  Map getWorkoutInfo(Workout workout){
    var userWorkout = userData.workouts.firstWhere((w) => w.workoutId == workout.id);
    if(userWorkout == null) return null;

    var nextWorkoutInfo = userWorkout.getNextWorkoutInfo;

    return {
      "loadedOn": DateTime.fromMillisecondsSinceEpoch(userWorkout.loadedOnMs),
      "completedOn": userWorkout.completedOnMs != null ? DateTime.fromMillisecondsSinceEpoch(userWorkout.completedOnMs) : null,
      "lastCompletedWeek": userWorkout.lastWeek,
      "lastCompletedDay": userWorkout.lastDay,
      "nextWeek": nextWorkoutInfo['nextWeek'],
      "nextDay": nextWorkoutInfo['nextDay'],
    };
  }
}

class UserData {
  String uid;
  List<UserWorkout> workouts;

  Map<String, dynamic> toMap(){
    return {
      "workouts": workouts == null ? [] : workouts.map((w) => w.toMap()).toList()
    };
  }

  UserData();

  UserData.fromJson(String uid, Map<String, dynamic> data){
    this.uid = uid;
    if(data['workouts'] == null)
      workouts = List<UserWorkout>();
    else
      workouts = (data['workouts'] as List).map((w) => UserWorkout.fromJson(w)).toList();
  }

    bool hasActiveWorkout(String uid)=> workouts != null
          && workouts.any((w) => w.workoutId == uid && w.completedOnMs == null);


  void addUserWorkout(UserWorkout userWorkout) {
    if(workouts == null)
      workouts = List<UserWorkout>();

    workouts.add(userWorkout);
  }
}

class UserWorkout{
  String workoutId;
  List<UserWorkoutWeek> weeks;
  int lastWeek;
  int lastDay;
  int loadedOnMs;
  int completedOnMs;

  Map<String, dynamic> toMap() {
      return {
        "workoutId": workoutId,
        "lastWeek": lastWeek,
        "lastDay": lastDay,
        "loadedOnMs": loadedOnMs,
        "completedOnMs": completedOnMs,
        "weeks": weeks.map((w) => w.toMap()).toList(),
      };
    }

  UserWorkout.fromJson(Map<String, dynamic> value){
    workoutId = value['workoutId'];
    lastWeek = value['lastWeek'];
    lastDay = value['lastDay'];
    loadedOnMs = value['loadedOnMs'];
    completedOnMs = value['completedOnMs'];
    weeks = (value['weeks'] as List).map((w) => UserWorkoutWeek.fromJson(w)).toList();
  }

  UserWorkout.fromWorkout(WorkoutSchedule workout){
    workoutId = workout.uid;
    weeks = workout.weeks.map((e){
      final days = [for(var i=0; i < e.days.length; i+=1) 
                      UserWorkoutDay.empty(isProductive: e.days[i].notRestDrillBlocksCount > 0)].toList();
      final week = UserWorkoutWeek(days);
      return week;
    }).toList();

    loadedOnMs = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String,Object> get getNextWorkoutInfo {
    var week = (lastWeek != null && lastWeek > 0) ? lastWeek : 0;
    var day = (lastDay != null && lastDay > 0) ? lastDay : 0;

    var weeksCount = weeks.length;
    var nextDay = day;
    var nextWeek = week;

    var isFound = false;
    do{
      if(nextDay > 7){
        nextDay = 1;
        nextWeek++;
      }
      if(nextWeek > weeksCount)
        break;

      if(weeks[nextWeek].days[nextDay].isProductive){
        isFound = true;
        break;
      }
      nextDay++;
    }while(true);

    if(isFound){
      return {
        "isCompleted": false,
        "nextWeek": nextWeek + 1,
        "nextDay": nextDay + 1
      };
    }else{
      return {
        "isCompleted": true,
      };
    }
  }
}

class UserWorkoutWeek{
  List<UserWorkoutDay> days;

  UserWorkoutWeek(this.days);

  Map<String, dynamic> toMap() {
    return {
      "days": days.map((w) => w.toMap()).toList(),
    };
  }

  UserWorkoutWeek.fromJson(Map<String, dynamic> value){
    days = (value['days'] as List).map((w) => UserWorkoutDay.fromJson(w)).toList();
  }
}

class UserWorkoutDay{
  int completedOnMs;
  bool isProductive;

  UserWorkoutDay.empty({this.isProductive});

  UserWorkoutDay.fromJson(Map<String, dynamic> value){
    completedOnMs = value['completedOnMs'];
    isProductive = value['isProductive'];
  }

  Map<String, dynamic> toMap() {
    return {
      "completedOnMs": completedOnMs,
      "isProductive": isProductive
    };
  }
}