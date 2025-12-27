import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FavouriteMachinesPage extends StatelessWidget {
  const FavouriteMachinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Machines'),
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
            .collection('favourite_machines')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favourites = snapshot.data!.docs;

          if (favourites.isEmpty) {
            return const Center(child: Text('No favourite machines yet'));
          }

          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final fav = favourites[index];
              final machineName = fav['machineName'];
              final laundryName = fav['laundryName'];
              final collection = fav['collection'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(
                    collection == 'washingMachines' 
                      ? Icons.local_laundry_service 
                      : Icons.local_fire_department,
                    size: 40,
                    color: Colors.amber,
                  ),
                  title: Text(machineName),
                  subtitle: Text('Laundry: $laundryName'),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () {
                      // 取消收藏功能
                      favourites[index].reference.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}