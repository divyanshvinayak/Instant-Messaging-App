import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:express/widgets/country_list_item.dart';
import 'package:express/screens/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = true;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('US');
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lookupUserCountry();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _loading
            ? Container()
            : SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 30, bottom: 20, left: 30, right: 30),
                          child: const Text(
                            'Enter your phone number to get started',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                height: 1.25),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: const Text(
                            'Please confirm your country code and enter your phone number.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, height: 1.25),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _openCountryPickerDialog();
                          },
                          title:
                              CountryListItem(country: _selectedDialogCountry),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 30, bottom: 40),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 17, horizontal: 10),
                                child: Text(
                                  '+${_selectedDialogCountry.phoneCode}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 30, bottom: 40),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 20),
                                child: TextField(
                                    controller: _controller,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Phone number',
                                      hintStyle: const TextStyle(
                                          color: Colors.black38),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (String phone) {
                                      _showSubmitDialog(phone);
                                    }),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 60,
                          margin: MediaQuery.of(context).viewInsets.bottom == 0
                              ? const EdgeInsets.only(bottom: 60)
                              : const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _showSubmitDialog(_controller.text);
                              },
                              child: const Text('NEXT')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _lookupUserCountry() async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/?fields=countryCode'));
      setState(() {
        _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode(
            json.decode(response.body)['countryCode']);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSubmitDialog(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    const SnackBar snackBar =
        SnackBar(content: Text('You must specify your phone number'));
    phone.isEmpty
        ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
        : showDialog(
            context: context,
            builder: (context) {
              return phone.length >= 6 && phone.length <= 12
                  ? AlertDialog(
                      title: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.grey, size: 36),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('Confirm'),
                        ],
                      ),
                      content: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Is your phone number below correct?\n'),
                            TextSpan(
                                text:
                                    '+${_selectedDialogCountry.phoneCode} $phone',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16, height: 1.5),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('NO'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('YES'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => ProfileSetupScreen(
                                  phone:
                                      '+${_selectedDialogCountry.phoneCode}$phone',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : AlertDialog(
                      title: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.grey, size: 36),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('Invalid number'),
                        ],
                      ),
                      content: Text(
                          'The number you specified (+${_selectedDialogCountry.phoneCode}$phone) is invalid.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
            },
          );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          isSearchable: false,
          onValuePicked: (Country country) =>
              setState(() => _selectedDialogCountry = country),
          itemBuilder: _buildDialogItem,
        ),
      );

  Widget _buildDialogItem(Country country) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CountryPickerUtils.getDefaultFlagImage(country),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 13,
          child: Text(country.name),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 5,
          child: Text('+${country.phoneCode}'),
        ),
      ],
    );
  }
}
