import 'package:flutter/material.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/base_widgets/custom_date_picker.dart';
import 'package:talent_link/widgets/sign_up_widgets/signup_page.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userRole;

  const UserDetailsScreen({super.key, required this.userRole});

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedGender = 'Male';
  List<String> genders = ['Male', 'Female'];

  TextEditingController dobController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  late String userdate;
  late String userCity;

  String selectedCountry = 'Palestine';

  List<String> countries = [
    'Palestine',
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Australia',
    'Brazil',
    'China',
    'Japan',
    'India',
    'Mexico',
    'Russia',
    'South Africa',
    'Saudi Arabia',
    'United Arab Emirates',
    'Turkey',
    'Egypt',
    'Argentina',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your personal details.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 20.0),

              // Use CustomDatePicker for DOB
              CustomDatePicker(
                controller: dobController,
                onDateSelected: (selectedDate) {
                  userdate = selectedDate;
                },
              ),
              const SizedBox(height: 10.0),

              // Gender Selection Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField(
                  value: selectedGender,
                  items:
                      genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
              ),
              const SizedBox(height: 10.0),

              // Use LoginSignupTextFieled for Address
              MyTextFieled(
                textHint: "Enter your address",
                textLable: "Address",
                controller: addressController,
                obscureText: false,
              ),
              const SizedBox(height: 10.0),

              // Address 2 (Optional)
              MyTextFieled(
                textHint: "Enter your second address (Optional)",
                textLable: "Address 2 (Optional)",
                controller: address2Controller,
                obscureText: false,
              ),
              const SizedBox(height: 10.0),

              // City Field
              MyTextFieled(
                textHint: "Enter your city",
                textLable: "City",
                controller: cityController,
                obscureText: false,
              ),
              const SizedBox(height: 10.0),

              // Country Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField(
                  value: selectedCountry,
                  items:
                      countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
              ),
              const SizedBox(height: 30.0),

              // Next Button
              BaseButton(
                text: "Next",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SignUpScreen(
                              country: selectedCountry,
                              date: userdate,
                              city: cityController.text,
                              gender: selectedGender,
                              userRole: widget.userRole,
                            ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
