class CurrentlyTabAPI {
  CurrentWeather? currentWeather;

  CurrentlyTabAPI(
      {this.currentWeather});

  CurrentlyTabAPI.fromJson(Map<String, dynamic> json) {
    currentWeather = json['current_weather'] != null
        ? CurrentWeather.fromJson(json['current_weather'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentWeather != null) {
      data['current_weather'] = currentWeather!.toJson();
    }
    return data;
  }
}

class CurrentWeather {
  double? temperature;
  double? windspeed;
  int? weathercode;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temperature'] = temperature;
    data['windspeed'] = windspeed;
    data['weathercode'] = weathercode;
    return data;
  }
}