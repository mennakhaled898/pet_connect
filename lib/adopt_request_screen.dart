import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class AdoptRequestScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final String ownerId;

  const AdoptRequestScreen({
    super.key,
    required this.petId,
    required this.petName,
    required this.ownerId,
  });

  @override
  State<AdoptRequestScreen> createState() => _AdoptRequestScreenState();
}

class _AdoptRequestScreenState extends State<AdoptRequestScreen> {
  final _reasonController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _submitRequest() async {
    if (_reasonController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      PetNotification.show(context, "Please fill in all fields", true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('applications').add({
        'petId': widget.petId,
        'petName': widget.petName,
        'ownerId': widget.ownerId,
        'applicantId': user.uid,
        'applicantName': user.displayName ?? "Interested Adopter",
        'reason': _reasonController.text.trim(),
        'phone': _phoneController.text.trim(),
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        PetNotification.show(
          context,
          "Application submitted successfully!",
          false,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        PetNotification.show(context, "Error: ${e.toString()}", true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          "Adopt ${widget.petName}",
          style: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE57373),
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Applying for ${widget.petName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Tell the owner a bit about yourself",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Contact Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _phoneController,
              hint: "Phone Number",
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            const Text(
              "Why do you want to adopt?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _reasonController,
              hint: "Tell the owner about yourself and your home...",
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 5,
            ),

            const SizedBox(height: 40),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7CB6A5)),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB6A5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Submit Application",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
    );
  }
}
