import 'package:flutter/material.dart';
import 'package:maxfit/components/common/workout-level.dart';
import 'package:maxfit/domain/user.dart';
import 'package:maxfit/domain/workout.dart';
import 'package:maxfit/screens/workout-details.dart';
import 'package:maxfit/services/database.dart';
import 'package:provider/provider.dart';

class ActiveWorkouts extends StatelessWidget {
  const ActiveWorkouts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return Container(
      alignment: FractionalOffset.center,
      child: StreamBuilder<List<Workout>>(
        stream: DatabaseService().getUserWorkouts(user),
        builder: (BuildContext context, AsyncSnapshot<List<Workout>> snapshot) {
          List<Widget> children;
            if (snapshot.hasError) {
              children = <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text("Can't load data", style: TextStyle(color: Colors.white)),
                )
              ];
            } else {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.done:
                  children = <Widget>[
                    SizedBox(
                      child: const CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting data...', style: TextStyle(color: Colors.white)),
                    )
                  ];
                  break;
                case ConnectionState.active:
                  var workouts = snapshot.data;
                  children = <Widget>[
                    Expanded(
      child: ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => WorkoutDetails(id:workouts[i].id)));
              },
              child: Card(
                key: Key(workouts[i].id),
                elevation: 2.0,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(50, 65, 85, 0.9)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    title: Text(workouts[i].title,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline6.color,
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      children: [
                        WorkoutLevel(level: workouts[i].level),
                        Container(
                          decoration: BoxDecoration(color: Color.fromRGBO(200, 205, 205, 0.9)),
                          child: _buildWorkoutInfo(user, workouts[i]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    )
                  ];
                  break;
              }
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            );
          },
      )
    );
  }
}

Widget _buildWorkoutInfo(User user, Workout workout) {
  var data = user.getWorkoutInfo(workout);

  return Column(
    children: [
      Text('Loaded: '+ data['loadedOn'].toString()),
      Text('Completed: '+ data['completedOn'].toString()),
      Text('Last Completed: '+ data['lastCompletedWeek'].toString()+ data['lastCompletedDay'].toString()),
      Text('Next: '+ data['nextWeek'].toString()+ data['nextDay'].toString()),
    ],
  );
}