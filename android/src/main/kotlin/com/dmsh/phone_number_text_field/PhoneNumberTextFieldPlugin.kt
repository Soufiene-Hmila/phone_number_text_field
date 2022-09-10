package com.dmsh.phone_number_text_field

import com.google.i18n.phonenumbers.NumberParseException
import com.google.i18n.phonenumbers.PhoneNumberToCarrierMapper
import com.google.i18n.phonenumbers.PhoneNumberUtil
import com.google.i18n.phonenumbers.PhoneNumberUtil.PhoneNumberFormat
import com.google.i18n.phonenumbers.PhoneNumberUtil.PhoneNumberType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/** PhoneNumberTextFieldPlugin */
class PhoneNumberTextFieldPlugin : MethodCallHandler, FlutterPlugin {
  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    val channel = MethodChannel(binding.binaryMessenger, "phone_number_text_field")
    channel.setMethodCallHandler(PhoneNumberTextFieldPlugin())
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isValidPhoneNumber" -> handleIsValidPhoneNumber(call, result)
      "normalizePhoneNumber" -> handleNormalizePhoneNumber(call, result)
      "getRegionInfo" -> handleGetRegionInfo(call, result)
      "getNumberType" -> handleGetNumberType(call, result)
      "getExampleNumber" -> handleGetExampleNumber(call, result)
      "formatAsYouType" -> formatAsYouType(call, result)
      "getNameForNumber" -> handleGetNameForNumber(call, result)
      "format" -> handleFormat(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleGetNameForNumber(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      result.success(phoneNumberToCarrierMapper.getNameForNumber(p, Locale.getDefault()))
    } catch (e: NumberParseException) {
      result.error("NumberParseException", e.message, null)
    }
  }

  private fun handleFormat(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    val format = call.argument<String>("format")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      val phoneNumberFormat = format?.let { PhoneNumberFormat.valueOf(it) }
      result.success(phoneUtil.format(p, phoneNumberFormat))
    } catch (e: Exception) {
      result.error("Exception", e.message, null)
    }
  }

  private fun handleIsValidPhoneNumber(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      result.success(phoneUtil.isValidNumber(p))
    } catch (e: NumberParseException) {
      result.error("NumberParseException", e.message, null)
    }
  }

  private fun handleNormalizePhoneNumber(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      val normalized = phoneUtil.format(p, PhoneNumberFormat.E164)
      result.success(normalized)
    } catch (e: NumberParseException) {
      result.error("NumberParseException", e.message, null)
    }
  }

  private fun handleGetRegionInfo(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      val regionCode = phoneUtil.getRegionCodeForNumber(p)
      val countryCode = p.countryCode.toString()
      val formattedNumber = phoneUtil.format(p, PhoneNumberFormat.NATIONAL)
      val resultMap: MutableMap<String, String> = HashMap()
      resultMap["isoCode"] = regionCode
      resultMap["regionCode"] = countryCode
      resultMap["formattedPhoneNumber"] = formattedNumber
      result.success(resultMap)
    } catch (e: NumberParseException) {
      result.error("NumberParseException", e.message, null)
    }
  }

  private fun handleGetExampleNumber(call: MethodCall, result: Result) {
    val isoCode = call.argument<String>("iso_code")
    val p = phoneUtil.getExampleNumber(isoCode)
    val regionCode = phoneUtil.getRegionCodeForNumber(p)
    val formattedNumber = phoneUtil.format(p, PhoneNumberFormat.NATIONAL)
    val resultMap: MutableMap<String, String> = HashMap()
    resultMap["isoCode"] = regionCode
    resultMap["formattedPhoneNumber"] = formattedNumber
    result.success(resultMap)
  }

  private fun handleGetNumberType(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    try {
      val p = phoneUtil.parse(phoneNumber, isoCode?.uppercase(Locale.getDefault()))
      when (phoneUtil.getNumberType(p)) {
        PhoneNumberType.FIXED_LINE -> result.success(0)
        PhoneNumberType.MOBILE -> result.success(1)
        PhoneNumberType.FIXED_LINE_OR_MOBILE -> result.success(2)
        PhoneNumberType.TOLL_FREE -> result.success(3)
        PhoneNumberType.PREMIUM_RATE -> result.success(4)
        PhoneNumberType.SHARED_COST -> result.success(5)
        PhoneNumberType.VOIP -> result.success(6)
        PhoneNumberType.PERSONAL_NUMBER -> result.success(7)
        PhoneNumberType.PAGER -> result.success(8)
        PhoneNumberType.UAN -> result.success(9)
        PhoneNumberType.VOICEMAIL -> result.success(10)
        PhoneNumberType.UNKNOWN -> result.success(-1)
      }
    } catch (e: NumberParseException) {
      result.error("NumberParseException", e.message, null)
    }
  }

  private fun formatAsYouType(call: MethodCall, result: Result) {
    val phoneNumber = call.argument<String>("phone_number")
    val isoCode = call.argument<String>("iso_code")
    val asYouTypeFormatter = phoneUtil.getAsYouTypeFormatter(isoCode?.uppercase(Locale.getDefault()))
    var res: String? = null
    for (i in 0 until phoneNumber!!.length) {
      res = asYouTypeFormatter.inputDigit(phoneNumber[i])
    }
    result.success(res)
  }

  companion object {
    private val phoneUtil = PhoneNumberUtil.getInstance()
    private val phoneNumberToCarrierMapper = PhoneNumberToCarrierMapper.getInstance()

    /** Keeping around to support older apps that aren't using v2 Android embedding  */
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "phone_number_text_field")
      channel.setMethodCallHandler(PhoneNumberTextFieldPlugin())
    }
  }
}

