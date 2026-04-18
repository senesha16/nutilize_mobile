import 'package:flutter/material.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
    this.type = TextInputType.text,
    this.inputFormatters,
    this.autofocus = false,
    this.enabled = true,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onChanged,
    this.onTap,
    this.onSaved,
    this.validator,
    this.autocompleteOptions,
    super.key,
  });

  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType type;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<AutocompleteOption>? autocompleteOptions;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  String? selectedAffiliation;
  bool showDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showDropdown = !showDropdown;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Text(
                  selectedAffiliation ?? widget.hint,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
        if (showDropdown)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.autocompleteOptions?.length ?? 0,
              itemBuilder: (context, index) {
                final option = widget.autocompleteOptions![index];
                return ListTile(
                  title: Text(option.label),
                  onTap: () {
                    setState(() {
                      selectedAffiliation = option.value;
                      showDropdown = false;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(option.value!);
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class AutocompleteOption {
  const AutocompleteOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

List<AutocompleteOption> options = [
  AutocompleteOption(label: 'BS Accountancy', value: 'bs_accountancy'),
  AutocompleteOption(label: 'BS Management Accounting', value: 'bs_management_accounting'),
  // Add more options as needed
];

AppInput(
  label: 'Affiliation',
  hint: 'Select your affiliation',
  autocompleteOptions: options,
  onSaved: (value) {
    // Save the selected value to the database
  },
  validator: (value) {
    if (value == null) {
      return 'Please select your affiliation';
    }
    return null;
  },
),