import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _quotaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  bool _isLoading = false;
  List<dynamic> _categoriesList = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _apiService.fetchCategories();
      if (mounted) {
        setState(() {
          _categoriesList = cats;
          if (cats.isNotEmpty) {
            _selectedCategoryId = cats.first['id'];
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitEvent() async {// Tüm kutuların doğru doldurulduğunu kontrol eder. Boş kalan yer varsa kırmızı hata verir.
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final eventData = {
        'title': _titleController.text,
        'description': _descController.text,
        'category': _selectedCategoryId,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'quota': int.tryParse(_quotaController.text) ?? 10,
        'price': _priceController.text.isEmpty ? "0.00" : _priceController.text,
      };


      final success = await _apiService.createEvent(eventData);
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Event successfully created!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create event. Please verify all input fields.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create New Event', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              // Title Field
              _buildTextField(
                controller: _titleController,
                label: 'Event Title',
                icon: Icons.title_rounded,
                hint: 'e.g. Masterclass: Italian Tiramisu',
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 16),

              // Category Selection Dropdown
              if (_categoriesList.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Event Category',
                      prefixIcon: Icon(Icons.category_rounded, color: Colors.indigo.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: _categoriesList.map<DropdownMenuItem<int>>((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'],
                        child: Text(
                          cat['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],


              // Description Field
              _buildTextField(
                controller: _descController,
                label: 'Description',
                icon: Icons.description_rounded,
                hint: 'Describe what attendees will experience...',
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
              ),

              const SizedBox(height: 24),
              const Text(
                'Date & Venue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      icon: Icons.calendar_today_rounded,
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (val) => val!.isEmpty ? 'Select date' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _timeController,
                      label: 'Time',
                      icon: Icons.access_time_rounded,
                      readOnly: true,
                      onTap: _selectTime,
                      validator: (val) => val!.isEmpty ? 'Select time' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Location / Venue',
                icon: Icons.location_on_rounded,
                hint: 'e.g. Culinary Academy, Istanbul',
                validator: (val) => val!.isEmpty ? 'Please enter a location' : null,
              ),

              const SizedBox(height: 24),
              const Text(
                'Pricing & Quota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              // Quota & Price Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _quotaController,
                      label: 'Seats Quota',
                      icon: Icons.people_alt_rounded,
                      keyboardType: TextInputType.number,
                      hint: '50',
                      validator: (val) => val!.isEmpty ? 'Enter quota' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (\$) (0 for Free)',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      hint: '0.00',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Create Event Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publish Event',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.indigo.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}