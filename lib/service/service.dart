import 'package:add_fav/model/weather_model.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/api.dart';
import 'exception.dart';

class WeatherService {
  Future<WeatherModel> getWeather() async {
    try {
      final response = await http
          .get(Uri.parse(ApiKey.apiKey))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        log(response.body);
        final jsonDecodeDta = await jsonDecode(response.body);
        final data = WeatherModel.fromJson(jsonDecodeDta);
        return data;
      } else {
        throw Exception(
          'Error Occured while connecting to server With StatusCode :${response.statusCode}',
        );
      }
    } on SocketException {
      throw NetWorkException(massage: 'Connection Faild');
    } on HttpException {
      throw NoserviceException(massage: 'No Service Found');
    } on TimeoutException {
      throw ConnectionTimeOutException(massage: 'Connection Timeout');
    } catch (e) {
      final response = await http.get(Uri.parse(ApiKey.apiKey)).timeout(
            const Duration(seconds: 5),
          );

      log('$response');
      throw processResponse(response);
    }
  }

  dynamic processResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(massage: 'Server Bad Request');
      case 401:
      case 403:
        throw UnAuthirizedException(massage: 'Address Not Found');
      case 404:
        throw NoteFound(massage: 'Url Not Found ');
      default:
        throw FetchDataException(
            massage:
                'Error Occured while connecting to server With StatusCode :${response.statusCode}');
    }
  }
}
