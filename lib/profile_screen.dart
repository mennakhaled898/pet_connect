import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          "My Profile",
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7CB6A5),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFFD7EBE5),
                      child: Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? "P",
                        style: const TextStyle(
                          fontSize: 42,
                          color: Color(0xFF7CB6A5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "Pet Lover",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── My Collection ───────────────────────────────────────────
            _sectionLabel("My Collection"),
            const SizedBox(height: 14),

            // Favorites — count streamed from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                return _menuCard(
                  context: context,
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFE57373),
                  iconBg: const Color(0xFFFDE8EA),
                  title: "Favorites",
                  subtitle: "$count saved",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // My Listings — count streamed from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pets')
                  .where('ownerId', isEqualTo: _uid)
                  .snapshots(),
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                return _menuCard(
                  context: context,
                  icon: Icons.pets_rounded,
                  iconColor: const Color(0xFF7CB6A5),
                  iconBg: const Color(0xFFD7EBE5),
                  title: "My Listings",
                  subtitle: "$count pets posted",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyListingsScreen()),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Adoption ────────────────────────────────────────────────
            _sectionLabel("Adoption"),
            const SizedBox(height: 14),

            _menuCard(
              context: context,
              icon: Icons.outbox_rounded,
              iconColor: const Color(0xFFE57373),
              iconBg: const Color(0xFFFDE8EA),
              title: "Requests Sent",
              subtitle: "Applications you submitted",
              onTap: () => _showRequestsSheet(
                context,
                filterField: 'applicantId',
                title: 'Requests Sent',
                isSent: true,
              ),
            ),

            const SizedBox(height: 14),

            _menuCard(
              context: context,
              icon: Icons.inbox_rounded,
              iconColor: const Color(0xFF7CB6A5),
              iconBg: const Color(0xFFD7EBE5),
              title: "Requests Received",
              subtitle: "Applications for your pets",
              onTap: () => _showRequestsSheet(
                context,
                filterField: 'ownerId',
                title: 'Requests Received',
                isSent: false,
              ),
            ),

            const SizedBox(height: 44),

            // ── Logout ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE57373),
                  size: 20,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFFE57373),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDE8EA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
    ),
  );

  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );

  // ── Requests bottom sheet (kept inline as before) ────────────────────────
  void _showRequestsSheet(
    BuildContext context, {
    required String filterField,
    required String title,
    required bool isSent,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _BottomSheetWrapper(
        title: title,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('applications')
              .where(filterField, isEqualTo: uid)
              .snapshots(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot> snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE57373)),
              );
            }
            if (snap.data!.docs.isEmpty) {
              return _emptyState(
                isSent ? "No requests sent yet" : "No requests received yet",
                isSent ? Icons.outbox_rounded : Icons.inbox_rounded,
                const Color(0xFFFDE8EA),
                const Color(0xFFE57373),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 4),
              itemCount: snap.data!.docs.length,
              itemBuilder: (_, i) {
                final data = snap.data!.docs[i].data() as Map<String, dynamic>;
                return _requestCard(data, isSent);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> data, bool isSent) {
    final petName = data['petName'] ?? "Unknown Pet";
    final applicantName = data['applicantName'] ?? "Unknown";
    final phone = data['phone'] ?? "—";
    final reason = data['reason'] ?? "—";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isSent
                      ? const Color(0xFFFDE8EA)
                      : const Color(0xFFD7EBE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSent ? Icons.outbox_rounded : Icons.inbox_rounded,
                  color: isSent
                      ? const Color(0xFFE57373)
                      : const Color(0xFF7CB6A5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSent
                      ? "Application for $petName"
                      : "$applicantName → $petName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          if (!isSent) ...[
            _detailRow(
              icon: Icons.person_rounded,
              label: "Name",
              value: applicantName,
              iconColor: const Color(0xFF7CB6A5),
              iconBg: const Color(0xFFD7EBE5),
            ),
            const SizedBox(height: 12),
          ],
          _detailRow(
            icon: Icons.phone_rounded,
            label: "Phone",
            value: phone,
            iconColor: const Color(0xFF7CB6A5),
            iconBg: const Color(0xFFD7EBE5),
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: isSent ? "Your message" : "Their message",
            value: reason,
            iconColor: const Color(0xFFE57373),
            iconBg: const Color(0xFFFDE8EA),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color iconBg,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D2D2D),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  static Widget _emptyState(String msg, IconData icon, Color bg, Color color) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              msg,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ── Reusable bottom sheet frame ──────────────────────────────────────────────
class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
