import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _bio = TextEditingController();
  final _imageUrl = TextEditingController();

  String _selectedType = "Dogs";
  String _selectedSex = "Male";

  void _savePet() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_name.text.isEmpty || _breed.text.isEmpty) {
      PetNotification.show(context, "Please fill in name and breed", true);
      return;
    }

    await FirebaseFirestore.instance.collection('pets').add({
      'ownerId': user.uid,
      'ownerEmail': user.email,
      'name': _name.text.trim(),
      'breed': _breed.text.trim(),
      'age': _age.text.trim(),
      'weight': _weight.text.trim(),
      'sex': _selectedSex,
      'type': _selectedType,
      'bio': _bio.text.trim(),
      'image': _imageUrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          "List a Pet",
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Basic Info"),
            _buildField(_name, "Pet Name *", Icons.pets_rounded),
            _buildField(_breed, "Breed *", Icons.category_rounded),

            Row(
              children: [
                Expanded(child: _buildField(_age, "Age", Icons.cake_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    _weight,
                    "Weight (kg)",
                    Icons.monitor_weight_rounded,
                  ),
                ),
              ],
            ),

            _sectionLabel("Category & Sex"),
            _buildDropdown(
              "Category",
              ["Dogs", "Cats", "Birds"],
              _selectedType,
              (v) => setState(() => _selectedType = v!),
            ),
            _buildDropdown(
              "Sex",
              ["Male", "Female"],
              _selectedSex,
              (v) => setState(() => _selectedSex = v!),
            ),

            _sectionLabel("Photo & Description"),
            _buildField(_imageUrl, "Image URL", Icons.image_rounded),
            _buildField(
              _bio,
              "Bio / Description",
              Icons.description_rounded,
              lines: 4,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB6A5),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: _savePet,
              child: const Text(
                "Post Listing",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFE57373)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String current,
    Function(String?) onChg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFE57373),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChg,
        ),
      ),
    );
  }
}
