import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/base_widgets/text_field.dart';

class AddNewJobScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? jobToEdit;

  const AddNewJobScreen({super.key, required this.token, this.jobToEdit});

  @override
  State<AddNewJobScreen> createState() => _AddNewJobScreenState();
}

class _AddNewJobScreenState extends State<AddNewJobScreen>
    with TickerProviderStateMixin {
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();
  final TextEditingController responsibilityController =
      TextEditingController();

  List<String> requirementsList = [];
  List<String> responsibilitiesList = [];
  String? selectedFilePath;
  String? aiTextInput;
  bool isLoading = false;

  DateTime selectedDeadline = DateTime.now().add(Duration(days: 30));
  final List<String> jobTypes = [
    'Full-Time',
    'Part-Time',
    'Remote',
    'Internship',
    'Contract',
  ];

  bool get isUpdate => widget.jobToEdit != null;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: isUpdate ? 1 : 3, vsync: this);

    if (isUpdate) {
      final job = widget.jobToEdit!;
      jobTitleController.text = job['title'] ?? '';
      jobDescriptionController.text = job['description'] ?? '';
      locationController.text = job['location'] ?? '';
      salaryController.text = job['salary'] ?? '';
      jobTypeController.text = job['jobType'] ?? '';
      categoryController.text = job['category'] ?? '';
      selectedDeadline =
          DateTime.tryParse(job['deadline'] ?? '') ?? selectedDeadline;
      requirementsList = List<String>.from(job['requirements'] ?? []);
      responsibilitiesList = List<String>.from(job['responsibilities'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? "Update Job" : "Add New Job"),
        centerTitle: true,
        bottom:
            isUpdate
                ? null
                : TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Manual Form'),
                    Tab(text: 'Upload File'),
                    Tab(text: 'Write to AI'),
                  ],
                ),
      ),
      body:
          isUpdate
              ? _buildManualForm()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildManualForm(),
                  _buildFileUploadTab(),
                  _buildWriteToAITab(),
                ],
              ),
    );
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyTextFieled(
            controller: jobTitleController,
            textHint: 'Job Title',
            textLable: 'Job Title',
            obscureText: false,
          ),
          MyTextFieled(
            controller: jobDescriptionController,
            textHint: 'Description',
            textLable: 'Description',
            obscureText: false,
          ),
          MyTextFieled(
            controller: locationController,
            textHint: 'Location',
            textLable: 'Location',
            obscureText: false,
          ),
          MyTextFieled(
            controller: salaryController,
            textHint: 'Salary',
            textLable: 'Salary',
            obscureText: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value:
                  jobTypeController.text.isNotEmpty
                      ? jobTypeController.text
                      : null,
              decoration: const InputDecoration(labelText: 'Job Type'),
              items:
                  jobTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(() => jobTypeController.text = value!),
            ),
          ),
          MyTextFieled(
            controller: categoryController,
            textHint: 'Category',
            textLable: 'Category',
            obscureText: false,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildChipsSection(
              'Requirement',
              requirementController,
              requirementsList,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildChipsSection(
              'Responsibility',
              responsibilityController,
              responsibilitiesList,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDeadline,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selectedDeadline = picked);
              }
            },
            child: Text(
              "Pick Deadline: ${selectedDeadline.toLocal().toString().split(' ')[0]}",
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: submitJob,
                child: Text(isUpdate ? "Update" : "Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipsSection(
    String label,
    TextEditingController controller,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    items.add(controller.text.trim());
                    controller.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 6.0,
          children:
              items
                  .asMap()
                  .entries
                  .map(
                    (entry) => InputChip(
                      label: Text(entry.value),
                      onDeleted:
                          () => setState(() => items.removeAt(entry.key)),
                      onPressed: () {
                        final editController = TextEditingController(
                          text: entry.value,
                        );
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("Edit $label"),
                                content: TextField(controller: editController),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(
                                        () =>
                                            items[entry.key] =
                                                editController.text.trim(),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  void submitJob() async {
    final url =
        isUpdate
            ? 'http://10.0.2.2:5000/api/job/updatejob?jobId=${widget.jobToEdit!['_id']}'
            : 'http://10.0.2.2:5000/api/job/addjob';

    final method = isUpdate ? http.patch : http.post;

    try {
      final response = await method(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': jobTitleController.text,
          'description': jobDescriptionController.text,
          'location': locationController.text,
          'salary': salaryController.text,
          'jobType': jobTypeController.text,
          'category': categoryController.text,
          'requirements': requirementsList,
          'responsibilities': responsibilitiesList,
          'deadline':
              DateTime(
                selectedDeadline.year,
                selectedDeadline.month,
                selectedDeadline.day,
              ).toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isUpdate ? "Job updated!" : "Job posted!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to ${isUpdate ? 'update' : 'add'} job"),
          ),
        );
      }
    } catch (e) {
      print("Submit error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  Future<void> uploadFileAndSubmit() async {
    setState(() => isLoading = true);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:5000/api/job/smart-add-job'),
      );
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.files.add(
        await http.MultipartFile.fromPath('jobFile', selectedFilePath!),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job posted from file!")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create job from file.")),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error uploading file.")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendTextToAIAndSubmit() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/job/smart-add-job'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': aiTextInput}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job posted from AI!")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("AI submission failed.")));
      }
    } catch (e) {
      print("AI error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting text to AI.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildFileUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text("Choose File"),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'docx', 'txt'],
              );
              if (result != null && result.files.single.path != null) {
                setState(() {
                  selectedFilePath = result.files.single.path!;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          if (selectedFilePath != null)
            Text("Selected: ${selectedFilePath!.split('/').last}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedFilePath != null ? uploadFileAndSubmit : null,
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Upload and Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteToAITab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste or write your job description here...',
            ),
            onChanged: (value) => aiTextInput = value,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                (aiTextInput != null && aiTextInput!.trim().isNotEmpty)
                    ? sendTextToAIAndSubmit
                    : null,
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Send to AI and Submit"),
          ),
        ],
      ),
    );
  }
}
