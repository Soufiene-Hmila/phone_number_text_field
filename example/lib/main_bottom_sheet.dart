import 'package:flutter/material.dart';
import 'package:phone_number_text_field/phone_number_text_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(appBar: AppBar(title: const Text('Demo')), body: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'TN';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              debugPrint("${number.dialCode} // ${number.phoneNumber} // ${number.isoCode}");
            },
            onInputValidated: (bool value) {
              debugPrint("$value");
            },
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            searchBoxDecoration: const InputDecoration(label: Text('Search by country/region name or dial code')),
            initialValue: PhoneNumber(isoCode: 'TN'),
            textFieldController: controller,
            inputBorder: const OutlineInputBorder(),
            selectorConfig: const SelectorConfig(
              setSelectorButtonAsPrefixIcon: true, leadingPadding: 15,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,),
          ),
          ElevatedButton(
            onPressed: () => formKey.currentState?.validate(),
            child: const Text('Validate'),
          ),
          ElevatedButton(
            onPressed: () => getPhoneNumber('+21651674704'),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'TN');
    String parsableNumber = await PhoneNumber.getParsableNumber(number);
    controller.text = parsableNumber;
    setState(() => initialCountry = number.isoCode!);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
