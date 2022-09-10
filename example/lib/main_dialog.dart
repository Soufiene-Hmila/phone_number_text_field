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
      home: Scaffold(appBar: AppBar(
          title: const Text('Demo')),
          body: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'NG';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              print(number.phoneNumber);
            },
            onInputValidated: (bool value) {
              print(value);
            },
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.disabled,
            initialValue: PhoneNumber(isoCode: 'NG'),
            textFieldController: controller,
            inputBorder: const OutlineInputBorder(),
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.DIALOG,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.validate();
            },
            child: const Text('Validate'),
          ),
          ElevatedButton(
            onPressed: () {
              getPhoneNumber('+15417543010');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

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
