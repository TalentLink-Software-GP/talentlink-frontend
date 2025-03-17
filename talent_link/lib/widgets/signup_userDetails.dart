import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/signup_page.dart';

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

              TextFormField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                readOnly: true,
                validator:
                    (value) =>
                        value!.isEmpty ? "Date of Birth is required" : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dobController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                      userdate = dobController.text;
                      print(userdate);
                    });
                  }
                },
              ),
              const SizedBox(height: 10.0),

              DropdownButtonFormField(
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
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator:
                    (value) => value!.isEmpty ? "Address is required" : null,
              ),
              const SizedBox(height: 10.0),

              TextFormField(
                controller: address2Controller,
                decoration: InputDecoration(
                  labelText: 'Address 2 (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator:
                    (value) => value!.isEmpty ? "City is required" : null,
                onChanged: (value) {
                  userCity = cityController.text;
                },
              ),

              const SizedBox(height: 10.0),

              DropdownButtonFormField(
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
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),

              BaseButton(
                text: "Next",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SignUpScreen(
                              country: "$selectedCountry",
                              date: "$userdate",
                              city: "$userCity",
                              gender: "$selectedGender",
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
