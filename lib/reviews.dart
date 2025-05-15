import 'package:flutter/material.dart';

class Reviews extends StatelessWidget {
  const Reviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('UPARK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20)),
              Text('Reviews', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildParkingHeader(),
            _buildReviewsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.edit),
        label: Text('Escribir Reseña'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildParkingHeader() {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/estacionamiento.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: Colors.red),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Nombre - Calle 123',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: [
        _buildReviewCard(),
        _buildReviewCard(),
      ],
    );
  }

  Widget _buildReviewCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Review body',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/17.jpg'),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviewer name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 