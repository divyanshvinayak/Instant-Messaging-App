import 'package:flutter/material.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';

class CountryListItem extends StatelessWidget {
  final Country country;

  const CountryListItem({required this.country});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: CountryPickerUtils.getDefaultFlagImage(country),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 8,
            child: Text(country.name),
          ),
          const Expanded(
            flex: 1,
            child: const Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey, width: 0.5)),
    );
  }
}
