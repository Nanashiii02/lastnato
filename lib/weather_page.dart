import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherDataCache {
  static final WeatherDataCache _instance = WeatherDataCache._internal();
  factory WeatherDataCache() => _instance;
  WeatherDataCache._internal();

  Map<String, dynamic>? _weatherData;
  List<dynamic>? _hourlyForecastData;
  List<dynamic>? _dailyForecastData;
  String? _city;

  void setData({
    required String city,
    required Map<String, dynamic> weatherData,
    required List<dynamic> hourlyForecastData,
    required List<dynamic> dailyForecastData,
  }) {
    _city = city;
    _weatherData = weatherData;
    _hourlyForecastData = hourlyForecastData;
    _dailyForecastData = dailyForecastData;
  }

  Map<String, dynamic>? get weatherData => _weatherData;
  List<dynamic>? get hourlyForecastData => _hourlyForecastData;
  List<dynamic>? get dailyForecastData => _dailyForecastData;
  String? get city => _city;

  bool hasDataFor(String city) {
    return _city == city &&
        _weatherData != null &&
        _hourlyForecastData != null &&
        _dailyForecastData != null;
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final String _apiKey = '5eba9fc6cb3ae1bf5c1f56e26abe9735';
  String _city = 'Tarlac';
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final WeatherDataCache _cache = WeatherDataCache();

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather({String? city}) {
    final targetCity = city ?? _city;
    if (_cache.hasDataFor(targetCity)) {
      _loadDataFromCache(targetCity);
    } else {
      _fetchWeatherData(city: targetCity);
    }
  }

  void _loadDataFromCache(String city) {
    setState(() {
      _city = _cache.city!;
      // Data is already in the build method, just need to stop loading
      _isLoading = false;
    });
  }

  Future<void> _fetchWeatherData({String? city}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cityName = city ?? _city;
    Map<String, dynamic>? weatherData;
    List<dynamic>? hourlyForecast;
    List<dynamic>? dailyForecast;

    try {
      final weatherResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric',
        ),
      );

      if (weatherResponse.statusCode == 200) {
        weatherData = json.decode(weatherResponse.body);
      } else {
        setState(() {
          _errorMessage = 'City not found';
          _isLoading = false;
        });
        return;
      }

      final forecastResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$_apiKey&units=metric',
        ),
      );

      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body)['list'];
        hourlyForecast = _processHourlyForecast(forecastData);
        dailyForecast = _processDailyForecast(forecastData);
      } else {
        setState(() {
          _errorMessage = 'Could not fetch forecast';
          _isLoading = false;
        });
        return;
      }

      _cache.setData(
        city: weatherData!['name'],
        weatherData: weatherData,
        hourlyForecastData: hourlyForecast,
        dailyForecastData: dailyForecast,
      );

      setState(() {
        _city = weatherData!['name'];
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      developer.log('Error fetching weather data: $e');
      setState(() {
        _errorMessage = 'Failed to load weather data';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _processHourlyForecast(List<dynamic> forecastList) {
    final now = DateTime.now();
    return forecastList.where((forecast) {
      final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      return date.isAfter(now) &&
          date.isBefore(now.add(const Duration(hours: 24)));
    }).toList();
  }

  List<dynamic> _processDailyForecast(List<dynamic> forecastList) {
    final dailyForecasts = <String, Map<String, dynamic>>{};

    for (var forecast in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      final day = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyForecasts.containsKey(day)) {
        dailyForecasts[day] = {
          'temp_min': forecast['main']['temp_min'],
          'temp_max': forecast['main']['temp_max'],
          'weather': forecast['weather'][0],
          'dt': forecast['dt'],
        };
      } else {
        if (forecast['main']['temp_min'] < dailyForecasts[day]!['temp_min']) {
          dailyForecasts[day]!['temp_min'] = forecast['main']['temp_min'];
        }
        if (forecast['main']['temp_max'] > dailyForecasts[day]!['temp_max']) {
          dailyForecasts[day]!['temp_max'] = forecast['main']['temp_max'];
        }
      }
    }
    return dailyForecasts.values.toList();
  }

  void _searchCity(String city) {
    if (city.isNotEmpty) {
      _loadWeather(city: city);
      _searchController.clear();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use cached data if available
    final weatherData = _cache.weatherData;
    final hourlyForecastData = _cache.hourlyForecastData;
    final dailyForecastData = _cache.dailyForecastData;

    return Scaffold(
      backgroundColor: const Color(0xFF343A40),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _errorMessage != null && weatherData == null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : _buildWeatherUI(
                weatherData,
                hourlyForecastData,
                dailyForecastData,
              ),
      ),
    );
  }

  Widget _buildWeatherUI(
    Map<String, dynamic>? weatherData,
    List<dynamic>? hourlyForecastData,
    List<dynamic>? dailyForecastData,
  ) {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (weatherData != null) _buildMainWeatherCard(weatherData),
                  const SizedBox(height: 20),
                  if (hourlyForecastData != null && dailyForecastData != null)
                    _buildForecastCard(hourlyForecastData, dailyForecastData),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => GoRouter.of(context).go('/home'),
          ),
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    onSubmitted: _searchCity,
                  )
                : Container(),
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(Map<String, dynamic> weatherData) {
    final weather = weatherData['weather'][0];
    final temp = weatherData['main']['temp'].round();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF495057),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Text(
            _city,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Image.network(
            'https://openweathermap.org/img/wn/${weather['icon']}@4x.png',
            width: 150,
            height: 150,
          ),
          Text(
            '$temp°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            weather['description'].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(
    List<dynamic> hourlyForecastData,
    List<dynamic> dailyForecastData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF495057),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOURLY FORECAST',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecastData.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecastData[index];
                return _buildHourlyForecastItem(
                  time: DateFormat.j().format(
                    DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000),
                  ),
                  icon: forecast['weather'][0]['icon'],
                  temp: forecast['main']['temp'].round(),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 40),
          const Text(
            '5-DAY FORECAST',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyForecastData.length,
              itemBuilder: (context, index) {
                final forecast = dailyForecastData[index];
                final isToday =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                    DateFormat('yyyy-MM-dd').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        forecast['dt'] * 1000,
                      ),
                    );

                return _buildDailyForecastItem(
                  day: DateFormat('E').format(
                    DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000),
                  ),
                  icon: forecast['weather']['icon'],
                  tempMax: forecast['temp_max'].round(),
                  tempMin: forecast['temp_min'].round(),
                  isSelected: isToday,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastItem({
    required String time,
    required String icon,
    required int temp,
  }) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Image.network(
            'https://openweathermap.org/img/wn/$icon@2x.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 8),
          Text(
            '$temp°',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem({
    required String day,
    required String icon,
    required int tempMax,
    required int tempMin,
    bool isSelected = false,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withAlpha(38) : Colors.transparent,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(
            'https://openweathermap.org/img/wn/$icon@2x.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 8),
          Text(
            '$tempMax° $tempMin°',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
