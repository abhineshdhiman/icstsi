import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/access_request.dart';
import '../services/access_request_service.dart';

class RequestAccessScreen extends StatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
  static const _brand = Color(0xFFFF6319);
  final _formKey = GlobalKey<FormState>();
  final _service = AccessRequestService();

  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _repNameCtrl = TextEditingController();
  final _repEmailCtrl = TextEditingController();
  final _repPosCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  String _terminal = 'MICT';
  String _userType = 'Shipping Line Representative / Agent';
  String? _copyFrom;
  final List<PlatformFile> _files = [];
  bool _submitting = false;

  static const _terminals = ['MICT', 'AGCT', 'MICTSI'];
  static const _userTypes = [
    'Shipping Line Representative / Agent',
    'Customs Broker',
    'Freight Forwarder',
    'Importer / Exporter',
    'Trucker',
  ];

  static const _requiredDocs = [
    'BIR forms 2303 and 0605',
    'DTI Certificate (For Individuals)',
    'SEC Certificate (For Corporations)',
    'E-signature of authorised representative',
    'Notarised Secretary\'s Certificate',
    'Scanned copy of Government issued ID (with picture & signature)',
  ];

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _cityCtrl, _stateCtrl, _countryCtrl, _zipCtrl,
      _addressCtrl, _taxCtrl, _emailCtrl,
      _repNameCtrl, _repEmailCtrl, _repPosCtrl, _remarksCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _files.addAll(result.files));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final request = AccessRequest(
        companyName: _nameCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        stateProvince: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
        businessAddress: _addressCtrl.text.trim(),
        taxIdNumber: _taxCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        terminal: _terminal,
        userType: _userType,
        copyFrom: _copyFrom,
        repName: _repNameCtrl.text.trim(),
        repEmail: _repEmailCtrl.text.trim(),
        repPosition: _repPosCtrl.text.trim().isEmpty
            ? null
            : _repPosCtrl.text.trim(),
        remarks: _remarksCtrl.text.trim().isEmpty
            ? null
            : _remarksCtrl.text.trim(),
      );

      final docs = _files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      await _service.submitRequest(request, docs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Access request submitted successfully! You will receive a confirmation email.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text('REQUEST ACCESS',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReminders(),
              const SizedBox(height: 16),
              _buildSection('Company Details', _buildCompanyFields()),
              const SizedBox(height: 12),
              _buildSection('Documents', _buildDocumentSection()),
              const SizedBox(height: 12),
              _buildSection(
                  'Authorised Representative', _buildRepSection()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  Widget _buildReminders() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6319).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reminders:',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B4F00),
                  fontSize: 13)),
          const SizedBox(height: 8),
          ...[
            'Please make sure information typed in the fields are correct and complete.',
            'Documents should be in Microsoft Word, Image, or PDF formats and less than 100MB.',
            'Applications with incomplete requirements will not be processed.',
            'Please ensure you enter the correct email address to receive the confirmation.',
            'Please refer to the sample documents listed below.',
          ].asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${e.key + 1}. ${e.value}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF7B4F00)),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1919))),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildCompanyFields() {
    return Column(
      children: [
        _buildField('Name', _nameCtrl, required: true),
        _buildField('Tax Identification Number', _taxCtrl, required: true),
        _buildField('Email', _emailCtrl,
            required: true,
            type: TextInputType.emailAddress),
        _buildField('Business Address', _addressCtrl, required: true),
        Row(
          children: [
            Expanded(child: _buildField('City', _cityCtrl, required: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildField('State / Province', _stateCtrl)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildField('Country', _countryCtrl, required: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildField('ZIP Code', _zipCtrl,
                    type: TextInputType.number)),
          ],
        ),
        _buildDropdown(
          label: 'Terminal*',
          value: _terminal,
          items: _terminals,
          itemLabel: (t) => '$t - Manila International Container Terminal',
          onChanged: (v) => setState(() => _terminal = v ?? _terminal),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'User Type*',
          value: _userType,
          items: _userTypes,
          itemLabel: (t) => t,
          onChanged: (v) => setState(() => _userType = v ?? _userType),
        ),
      ],
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Required Documents:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
        const SizedBox(height: 8),
        ..._requiredDocs.map(
          (doc) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(doc,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF1A1919))),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_files.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _files.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value.name,
                    style: const TextStyle(fontSize: 11)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    setState(() => _files.removeAt(e.key)),
                backgroundColor: const Color(0xFFF5F5F5),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.upload_outlined, color: _brand),
            label: const Text('Upload Documents',
                style: TextStyle(color: _brand)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: _brand),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepSection() {
    return Column(
      children: [
        _buildField('Name', _repNameCtrl, required: true),
        _buildField('Email Address', _repEmailCtrl,
            required: true, type: TextInputType.emailAddress),
        _buildField('Position', _repPosCtrl),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Remarks',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _remarksCtrl,
              maxLines: 4,
              maxLength: 255,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _brand),
                ),
                hintText: 'Optional remarks…',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(required ? '$label*' : label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: type,
            validator: required
                ? (v) =>
                    v == null || v.trim().isEmpty ? '$label is required' : null
                : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _brand),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _brand),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: items
                .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(itemLabel(e),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('SUBMIT',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}
