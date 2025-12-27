import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class VoucherPage extends StatelessWidget {
  final String userUid;

  const VoucherPage({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    if (userUid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Voucher"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Error: userUid not provided")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voucher"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .collection("vouchers")
            // 你 database 只有 expireAt，因此改成 orderBy expireAt
            .orderBy("expireAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            print(userUid);

            return const Center(child: Text("No vouchers yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final amount = data["amount"]?.toString() ?? "0";
              final type = data["type"]?.toString() ?? "";
              final fromOwner = data["fromOwner"]?.toString() ?? "";
              final expireAt = (data["expireAt"] as Timestamp).toDate();

              return _voucherCard(amount, type, fromOwner, expireAt);
            },
          );
        },
      ),
    );
  }

  Widget _voucherCard(
    String amount,
    String type,
    String fromOwner,
    DateTime expireAt,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.card_giftcard,
          size: 40,
          color: Colors.deepPurple,
        ),
        title: Text(
          "RM $amount OFF",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: $type"),
            Text("From Owner: $fromOwner"),
            Text("Expire At: ${expireAt.toString().substring(0, 16)}"),
          ],
        ),
      ),
    );
  }
}
