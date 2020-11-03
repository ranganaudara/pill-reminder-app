class Reminder {
  int id;
  String drugName;
  String time;
  String days;
  int numberOfPills;

  Reminder({this.id, this.drugName, this.time, this.days, this.numberOfPills});

  factory Reminder.fromMap(Map<String, dynamic> json) => Reminder(
        id: json["id"],
        drugName: json["drugName"],
        time: json["time"],
        days: json["days"],
        numberOfPills: json["numberOfPills"],
      );

  Map<String, dynamic> toMap() => {
        "drugName": drugName,
        "time": time,
        "days": days,
        "numberOfPills": numberOfPills,
      };
}
