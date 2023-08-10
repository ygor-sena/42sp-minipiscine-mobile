class CityToCoordinatesConverter extends StatefulWidget {
  @override
  _CityToCoordinatesConverterState createState() =>
      _CityToCoordinatesConverterState();
}

class _CityToCoordinatesConverterState
    extends State<CityToCoordinatesConverter> {
  final TextEditingController _cityController = TextEditingController();
  List<Location>? _coordinates;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _convertCityToCoordinates() async {
    final cityName = _cityController.text;
    if (cityName.isNotEmpty) {
      List<Location> coordinates = await getCoordinatesFromCity(cityName);
      setState(() {
        _coordinates = coordinates;
      });
    }
  }