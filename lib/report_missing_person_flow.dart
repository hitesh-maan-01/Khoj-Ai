// report_missing_person_flow.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'case_details_page.dart'; // keep/update path if located elsewhere

class ReportMissingPersonFlow extends StatefulWidget {
  const ReportMissingPersonFlow({super.key});

  @override
  State<ReportMissingPersonFlow> createState() =>
      _ReportMissingPersonFlowState();
}

class _ReportMissingPersonFlowState extends State<ReportMissingPersonFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Image
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  // Step 1 controllers
  final _formKeyStep1 = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  final TextEditingController _lastSeenLocationController =
      TextEditingController();
  DateTime? _dateLastSeen;

  // Step 2 controllers
  final _formKeyStep2 = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _clothingController = TextEditingController();
  final TextEditingController _distinguishingMarksController =
      TextEditingController();
  String? _lastSeenTime; // e.g., "2:30 PM"

  // Guardian / contact (Step 1 cont.)
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  String? _relationship;

  // Additional notes
  final TextEditingController _additionalNotesController =
      TextEditingController();

  // Saving state
  bool _isSaving = false;

  // Helpers
  Future<void> _pickFromCamera() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) setState(() => _photo = File(img.path));
  }

  Future<void> _pickFromGallery() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _photo = File(img.path));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: _dateLastSeen ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateLastSeen = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      setState(() => _lastSeenTime = DateFormat.jm().format(dt));
    }
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  // validate step, then move forward
  bool _validateAndNext() {
    if (_currentPage == 0) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        _goToPage(1);
        return true;
      }
      return false;
    } else if (_currentPage == 1) {
      if (_formKeyStep2.currentState?.validate() ?? false) {
        _goToPage(2);
        return true;
      }
      return false;
    }
    return true;
  }

  // FINAL submit: save to SharedPreferences, generate case ID, return the saved report
  Future<void> _onSubmit() async {
    // Ensure forms valid
    final valid1 = _formKeyStep1.currentState?.validate() ?? true;
    final valid2 = _formKeyStep2.currentState?.validate() ?? true;
    if (!valid1 || !valid2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      if (!valid1)
        _goToPage(0);
      else if (!valid2) _goToPage(1);
      return;
    }

    setState(() => _isSaving = true);

    final String caseId = 'CASE-${DateTime.now().millisecondsSinceEpoch}';

    final Map<String, dynamic> reportData = {
      "caseId": caseId,
      "fullName": _fullNameController.text,
      "age": _ageController.text,
      "gender": _gender ?? "",
      "lastSeenLocation": _lastSeenLocationController.text,
      "dateLastSeen": _dateLastSeen == null
          ? ""
          : DateFormat('dd-MM-yyyy').format(_dateLastSeen!),
      "height": _heightController.text,
      "weight": _weightController.text,
      "clothing": _clothingController.text,
      "distinguishingMarks": _distinguishingMarksController.text,
      "lastSeenTime": _lastSeenTime ?? "",
      "guardian": _guardianNameController.text,
      "contact": _contactNumberController.text,
      "relationship": _relationship ?? "",
      "notes": _additionalNotesController.text,
      "photoPath": _photo?.path ?? "",
      "createdAt": DateTime.now().toIso8601String(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existingJson = prefs.getString('reports');
      final List<dynamic> existing =
          existingJson != null ? jsonDecode(existingJson) as List<dynamic> : [];
      // add the new report (insert at start so newest appears first)
      existing.insert(0, reportData);
      await prefs.setString('reports', jsonEncode(existing));

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report saved — $caseId')),
      );

      // Return the saved report to caller (ReportsPage will receive it)
      Navigator.pop(context, reportData);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save report: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _lastSeenLocationController.dispose();
    _guardianNameController.dispose();
    _contactNumberController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _clothingController.dispose();
    _distinguishingMarksController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color.fromARGB(255, 42, 77, 255)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }),
    );
  }

  Widget _photoWidget() {
    return GestureDetector(
      onTap: () => _showImageOptions(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _photo == null
            ? DottedPlaceholder(key: const ValueKey('empty'))
            : ClipRRect(
                key: const ValueKey('photo'),
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_photo!,
                    fit: BoxFit.cover, width: 150, height: 150),
              ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              }),
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              }),
          if (_photo != null)
            ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photo = null);
                }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Missing Person'),
        centerTitle: false,
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 42, 77, 255),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: _buildStepIndicator()),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // ---------------- STEP 1 ----------------
                  SingleChildScrollView(
                    padding: pagePadding,
                    child: Form(
                      key: _formKeyStep1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Details',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Center(child: _photoWidget()),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                prefixIcon: Icon(Icons.person)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter full name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Age *',
                                      prefixIcon: Icon(Icons.cake)),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter age'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                      labelText: 'Gender *',
                                      prefixIcon: Icon(Icons.wc)),
                                  value: _gender,
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(
                                          value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _gender = v),
                                  validator: (v) =>
                                      (v == null) ? 'Select gender' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastSeenLocationController,
                            decoration: const InputDecoration(
                                labelText: 'Last Seen Location *',
                                prefixIcon: Icon(Icons.location_on)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter location'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Date Last Seen',
                                    prefixIcon: Icon(Icons.calendar_today)),
                                controller: TextEditingController(
                                    text: _dateLastSeen == null
                                        ? ''
                                        : DateFormat('dd-MM-yyyy')
                                            .format(_dateLastSeen!)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text('Guardian Contact Information',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _guardianNameController,
                            decoration: const InputDecoration(
                                labelText: 'Guardian Name *',
                                prefixIcon: Icon(Icons.person_outline)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter guardian name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                labelText: 'Contact Number *',
                                prefixIcon: Icon(Icons.phone)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter contact number'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Relationship *',
                                prefixIcon: Icon(Icons.family_restroom)),
                            value: _relationship,
                            items: [
                              'Parent',
                              'Sibling',
                              'Relative',
                              'Friend',
                              'Other'
                            ]
                                .map((r) =>
                                    DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) => setState(() => _relationship = v),
                            validator: (v) =>
                                (v == null) ? 'Select relationship' : null,
                          ),
                          const SizedBox(height: 20),
                          // Navigation
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Save draft placeholder
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Draft saved locally')));
                                  },
                                  child: const Text('Save Draft'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _validateAndNext(),
                                  child: const Text('Continue'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 42, 77, 255),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ---------------- STEP 2 ----------------
                  SingleChildScrollView(
                    padding: pagePadding,
                    child: Form(
                      key: _formKeyStep2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Physical & Incident Details',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Height (cm) *',
                                      prefixIcon: Icon(Icons.height)),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter height'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Weight (kg)',
                                      prefixIcon: Icon(Icons.monitor_weight)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _clothingController,
                            decoration: const InputDecoration(
                                labelText: 'Clothing / Last seen wearing',
                                prefixIcon: Icon(Icons.checkroom)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter clothing details'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _distinguishingMarksController,
                            decoration: const InputDecoration(
                                labelText:
                                    'Distinguishing marks (tattoos, scars...)',
                                prefixIcon: Icon(Icons.star)),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectTime,
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          labelText: 'Last seen time',
                                          prefixIcon: Icon(Icons.access_time)),
                                      controller: TextEditingController(
                                          text: _lastSeenTime ?? ''),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Container()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _additionalNotesController,
                            decoration: const InputDecoration(
                                labelText: 'Additional Notes',
                                prefixIcon: Icon(Icons.note),
                                alignLabelWithHint: true),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => _goToPage(0),
                                child: const Text('Back'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _validateAndNext(),
                                  child: const Text('Continue'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 42, 77, 255),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ---------------- STEP 3 (Review) ----------------
                  SingleChildScrollView(
                    padding: pagePadding,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Review & Confirm',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 6)
                                  ]),
                              child: _photo == null
                                  ? const DottedPlaceholder()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_photo!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _reviewRow('Full Name', _fullNameController.text),
                          _reviewRow('Age', _ageController.text),
                          _reviewRow('Gender', _gender ?? '-'),
                          _reviewRow('Last Seen Location',
                              _lastSeenLocationController.text),
                          _reviewRow(
                              'Date Last Seen',
                              _dateLastSeen == null
                                  ? '-'
                                  : DateFormat('dd-MM-yyyy')
                                      .format(_dateLastSeen!)),
                          _reviewRow('Height (cm)', _heightController.text),
                          _reviewRow('Weight (kg)', _weightController.text),
                          _reviewRow('Clothing', _clothingController.text),
                          _reviewRow('Distinguishing Marks',
                              _distinguishingMarksController.text),
                          _reviewRow('Last Seen Time', _lastSeenTime ?? '-'),
                          _reviewRow('Guardian', _guardianNameController.text),
                          _reviewRow('Contact', _contactNumberController.text),
                          _reviewRow('Relationship', _relationship ?? '-'),
                          _reviewRow(
                              'Additional Notes',
                              _additionalNotesController.text.isEmpty
                                  ? '-'
                                  : _additionalNotesController.text),
                          const SizedBox(height: 20),
                          if (_isSaving)
                            const Center(child: CircularProgressIndicator()),
                          if (!_isSaving)
                            Row(
                              children: [
                                OutlinedButton(
                                    onPressed: () => _goToPage(1),
                                    child: const Text('Back')),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _onSubmit,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text('Submit Report'),
                                        SizedBox(width: 8),
                                        Icon(Icons.send),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 42, 77, 255),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child:
                  Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class DottedPlaceholder extends StatelessWidget {
  const DottedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.camera_alt_outlined, size: 36, color: Colors.grey),
        SizedBox(height: 8),
        Text('Upload Photo', style: TextStyle(color: Colors.grey)),
      ])),
    );
  }
}
