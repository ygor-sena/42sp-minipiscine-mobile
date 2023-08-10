class TodayTabAPI {
  double? latitude;
  double? longitude;
  HourlyUnits? hourlyUnits;
  Hourly? hourly;

  TodayTabAPI(
      {this.latitude,
      this.longitude,
      this.hourlyUnits,
      this.hourly});

  TodayTabAPI.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    hourlyUnits = json['hourly_units'] != null
        ? new HourlyUnits.fromJson(json['hourly_units'])
        : null;
    hourly =
        json['hourly'] != null ? new Hourly.fromJson(json['hourly']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.hourlyUnits != null) {
      data['hourly_units'] = this.hourlyUnits!.toJson();
    }
    if (this.hourly != null) {
      data['hourly'] = this.hourly!.toJson();
    }
    return data;
  }
}

class HourlyUnits {
  String? time;
  String? temperature2m;
  String? weathercode;
  String? windspeed10m;

  HourlyUnits(
      {this.time, this.temperature2m, this.weathercode, this.windspeed10m});

  HourlyUnits.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    temperature2m = json['temperature_2m'];
    weathercode = json['weathercode'];
    windspeed10m = json['windspeed_10m'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['temperature_2m'] = this.temperature2m;
    data['weathercode'] = this.weathercode;
    data['windspeed_10m'] = this.windspeed10m;
    return data;
  }
}

class Hourly {
  List<String>? time;
  List<double>? temperature2m;
  List<int>? weathercode;
  List<double>? windspeed10m;

  Hourly({this.time, this.temperature2m, this.weathercode, this.windspeed10m});

  Hourly.fromJson(Map<String, dynamic> json) {
    time = json['time'].cast<String>();
    temperature2m = json['temperature_2m'].cast<double>();
    weathercode = json['weathercode'].cast<int>();
    windspeed10m = json['windspeed_10m'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['temperature_2m'] = this.temperature2m;
    data['weathercode'] = this.weathercode;
    data['windspeed_10m'] = this.windspeed10m;
    return data;
  }
}
