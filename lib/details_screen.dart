import 'package:flutter/material.dart';
import 'adopt_request_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  final String petId;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const DetailsScreen({
    super.key,
    required this.pet,
    required this.petId,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool localFav;

  @override
  void initState() {
    super.initState();
    localFav = widget.isFavorited;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Hero image
          Image.network(
            widget.pet['image'] ?? "",
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              height: 400,
              color: const Color(0xFFFDE8EA),
              child: const Center(
                child: Icon(Icons.pets, size: 80, color: Color(0xFFE57373)),
              ),
            ),
          ),

          // Top buttons
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(
                  Icons.arrow_back_rounded,
                  () => Navigator.pop(context),
                ),
                _circleBtn(
                  localFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  () {
                    setState(() => localFav = !localFav);
                    widget.onFavoriteToggle();
                  },
                  color: const Color(0xFFE57373),
                ),
              ],
            ),
          ),

          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.pet['name'] ?? "Pet",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.pet['breed'] ?? "",
                          style: const TextStyle(
                            color: Color(0xFFE57373),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _infoBox("Age", widget.pet['age'] ?? "N/A"),
                      const SizedBox(width: 12),
                      _infoBox("Sex", widget.pet['sex'] ?? "N/A"),
                      const SizedBox(width: 12),
                      _infoBox("Weight", widget.pet['weight'] ?? "N/A"),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.pet['bio'] ?? "No description.",
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.6,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CB6A5),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => AdoptRequestScreen(
                          petName: widget.pet['name'],
                          petId: widget.petId,
                          ownerId: widget.pet['ownerId'],
                        ),
                      ),
                    ),
                    child: const Text(
                      "Adopt Me",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8EA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFFE57373),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    VoidCallback tap, {
    Color color = Colors.black,
  }) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 22,
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: tap,
      ),
    );
  }
}
