import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart';
import 'add_pet_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String selectedCategory = "All";

  // ── Firestore favorites helpers ──────────────────────────────────────────

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favRef => _uid == null
      ? null
      : FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('favorites');

  Future<void> _toggleFavorite(String petId) async {
    final ref = _favRef;
    if (ref == null) return;
    final doc = await ref.doc(petId).get();
    if (doc.exists) {
      await ref.doc(petId).delete();
    } else {
      await ref.doc(petId).set({
        'petId': petId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex && index == 0) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const SearchScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const AddPetScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const ProfileScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stream the user's favorites set so the heart icons stay in sync
    return StreamBuilder<QuerySnapshot>(
      stream: _favRef?.snapshots(),
      builder: (context, favSnapshot) {
        final favIds =
            favSnapshot.data?.docs.map((d) => d.id).toSet() ?? <String>{};

        return Scaffold(
          backgroundColor: const Color(0xFFFDFDFD),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              "PetConnect",
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const FavoritesScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFE57373),
                        size: 18,
                      ),
                      if (favIds.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${favIds.length}',
                          style: const TextStyle(
                            color: Color(0xFFE57373),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildCategoryFilter(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: selectedCategory == "All"
                      ? FirebaseFirestore.instance
                            .collection('pets')
                            .snapshots()
                      : FirebaseFirestore.instance
                            .collection('pets')
                            .where('type', isEqualTo: selectedCategory)
                            .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7CB6A5),
                        ),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No pets found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, i) {
                        final doc = snapshot.data!.docs[i];
                        final pet = doc.data() as Map<String, dynamic>;
                        final isFav = favIds.contains(doc.id);
                        return _buildPetCard(pet, doc.id, isFav);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF7CB6A5),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_rounded),
                label: "Add",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    const categories = ["All", "Dogs", "Cats", "Birds"];
    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isSelected = selectedCategory == categories[i];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7CB6A5)
                    : const Color(0xFFD7EBE5),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF7CB6A5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet, String id, bool isFav) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            pet: pet,
            petId: id,
            isFavorited: isFav,
            onFavoriteToggle: () => _toggleFavorite(id),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: Image.network(
                pet['image'] ?? "",
                width: 115,
                height: 115,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 115,
                  height: 115,
                  color: const Color(0xFFD7EBE5),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF7CB6A5),
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'] ?? "Pet",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet['breed'] ?? "Mixed Breed",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7EBE5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pet['type'] ?? "",
                      style: const TextStyle(
                        color: Color(0xFF7CB6A5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFFE57373),
                size: 26,
              ),
              onPressed: () => _toggleFavorite(id),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
