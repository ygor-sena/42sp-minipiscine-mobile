class CurrentlyTabAPI {
  CurrentWeather? currentWeather;

  CurrentlyTabAPI(
      {this.currentWeather});

  CurrentlyTabAPI.fromJson(Map<String, dynamic> json) {
    currentWeather = json['current_weather'] != null
        ? new CurrentWeather.fromJson(json['current_weather'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.currentWeather != null) {
      data['current_weather'] = this.currentWeather!.toJson();
    }
    return data;
  }
}

class CurrentWeather {
  double? temperature;
  double? windspeed;
  int? weathercode;
  int? isDay;
  String? time;

  CurrentWeather(
      {this.temperature,
      this.windspeed,
      this.weathercode,});

  CurrentWeather.fromJson(Map<String, dynamic> json) {
    temperature = json['temperature'];
    windspeed = json['windspeed'];
    weathercode = json['weathercode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temperature'] = this.temperature;
    data['windspeed'] = this.windspeed;
    data['weathercode'] = this.weathercode;
    return data;
  }
}