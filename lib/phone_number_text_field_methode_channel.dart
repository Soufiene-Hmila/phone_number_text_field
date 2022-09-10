import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RegionInfo {

  String? regionPrefix;
  String? isoCode;
  String? formattedPhoneNumber;

  RegionInfo({this.regionPrefix, this.isoCode, this.formattedPhoneNumber});

  @override
  String toString() {
    return '[RegionInfo prefix=$regionPrefix, iso=$isoCode, formatted=$formattedPhoneNumber]';
  }
}

enum PhoneNumberFormat {
    E164,
    INTERNATIONAL,
    NATIONAL,
    RFC3966
}

enum PhoneNumberType {
  fixedLine,
  mobile,
  fixedLineOrMobile,
  tollFree,
  premiumRate,
  sharedCost,
  voip,
  personalNumber,
  pager,
  uan,
  voicemail,
  unknown
}

class MethodChannelPhoneNumberTextField {

  @visibleForTesting
  static const methodChannel = MethodChannel('phone_number_text_field');

  static Future<bool?> isValidPhoneNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    try {
      return await methodChannel.invokeMethod('isValidPhoneNumber', {
        'phone_number': phoneNumber,
        'iso_code': isoCode,
      });
    } catch (e) {
      // Sometimes invalid phone numbers can cause exceptions, e.g. "+1"
      return false;
    }
  }

  static Future<String?> getNameForNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    return await methodChannel.invokeMethod('getNameForNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
  }

  static Future<String?> normalizePhoneNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    return await methodChannel.invokeMethod('normalizePhoneNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
  }

  static Future<RegionInfo> getRegionInfo({
    required String phoneNumber,
    required String isoCode,
  }) async {
    Map<dynamic, dynamic> result =
        await (methodChannel.invokeMethod('getRegionInfo', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    }));

    return RegionInfo(
      regionPrefix: result['regionCode'],
      isoCode: result['isoCode'],
      formattedPhoneNumber: result['formattedPhoneNumber'],
    );
  }

  static Future<PhoneNumberType> getNumberType({
    required String phoneNumber,
    required String isoCode,
  }) async {
    int? result = await methodChannel.invokeMethod('getNumberType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result == -1) {
      return PhoneNumberType.unknown;
    }
    return PhoneNumberType.values[result!];
  }

  static Future<String> getExampleNumber(String isoCode) async {
    Map<dynamic, dynamic> result = await methodChannel.invokeMethod('getExampleNumber', {
      'iso_code': isoCode,
    });
    return result['formattedPhoneNumber'].toString();
  }
  
  static Future<String?> formatAsYouType({
    required String phoneNumber,
    required String isoCode,
  }) async {
    return await methodChannel.invokeMethod('formatAsYouType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
  }

  static Future<String> format({
    required String phoneNumber,
    required String isoCode,
    required PhoneNumberFormat format,
    // If true, this removes the spaces between the digits in the number formats
    // that add them.
    bool removeSpacesBetweenDigits = true,
  }) async {
    final String formatString = format.toString();
    if(formatString.isEmpty) {
      return phoneNumber;
    }

    final String formattedPhoneNumber = await methodChannel.invokeMethod('format', {
          'phone_number': phoneNumber,
          'iso_code': isoCode,
          'format': formatString.substring(formatString.indexOf('.') + 1)
    });
    
    if(removeSpacesBetweenDigits) {
      return formattedPhoneNumber.replaceAll(' ', '');
    } else {
      return formattedPhoneNumber;
    }
  }
}
