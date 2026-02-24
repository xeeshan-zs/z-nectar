import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/widgets/green_button.dart';

class ManualAddressScreen extends StatefulWidget {
  const ManualAddressScreen({super.key});

  @override
  State<ManualAddressScreen> createState() => _ManualAddressScreenState();
}

class _ManualAddressScreenState extends State<ManualAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProvince;
  String? _selectedCity;
  final TextEditingController _streetCtrl = TextEditingController();

  final Map<String, List<String>> _provinceCityMap = {
    'Sindh': ['Karachi', 'Hyderabad', 'Sukkur', 'Larkana', 'Nawabshah', 'Mirpur Khas'],
    'Punjab': ['Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala', 'Sialkot', 'Bahawalpur', 'Sargodha'],
    'Khyber Pakhtunkhwa': ['Peshawar', 'Mardan', 'Swat', 'Abbottabad', 'Mansehra', 'Kohat'],
    'Balochistan': ['Quetta', 'Gwadar', 'Khuzdar', 'Chaman', 'Turbat'],
    'Islamabad Capital Territory': ['Islamabad'],
    'Gilgit-Baltistan': ['Gilgit', 'Skardu', 'Hunza'],
    'Azad Kashmir': ['Muzaffarabad', 'Mirpur', 'Rawalakot'],
  };

  void _save() {
    if (_formKey.currentState!.validate()) {
      final address = '${_streetCtrl.text.trim()}, $_selectedCity, $_selectedProvince';
      Navigator.of(context).pop(address);
    }
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Add Address', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Address Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Province Dropdown
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: InputDecoration(
                  labelText: 'Province / Territory',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                items: _provinceCityMap.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedProvince = val;
                    // Reset city selection when province changes
                    _selectedCity = null; 
                  });
                },
                validator: (val) => val == null ? 'Please select a province' : null,
              ),
              const SizedBox(height: 20),
              
              // City Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                items: _selectedProvince == null 
                    ? [] 
                    : _provinceCityMap[_selectedProvince]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCity = val;
                  });
                },
                validator: (val) => val == null ? 'Please select a city' : null,
              ),
              const SizedBox(height: 20),
              
              // Street Address
              TextFormField(
                controller: _streetCtrl,
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'e.g. House 14, Street 5, Phase 2...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                maxLines: 2,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a street address' : null,
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: GreenButton(
                  text: 'Save Address',
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
