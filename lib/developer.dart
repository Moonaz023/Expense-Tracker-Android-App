import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developer Info'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.deepPurple],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildDeveloperInfo(
              'Md. Moonaz Rahman',
              'moonaz.png',
              'moonaz.cse6.bu@gmail.com',
              '01521229838',
              true,
            ),
            SizedBox(height: 20),
            _buildDeveloperInfo(
              'Afrin Hayat',
              'afrin.png',
              'afrin.cse6.bu@gmail.com',
              '987-654-3210',
              false,
            ),
            SizedBox(height: 20),
            _buildDeveloperInfo(
              'Sumaiya Habib Meem',
              'meem.png',
              'meem.cse6.bu@gmail.com',
              '555-555-5555',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(
      String name, String image, String email, String phone, bool imageAtRight) {
    return Container(
      width: double.infinity,
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: imageAtRight ? Axis.horizontal : Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!imageAtRight) _buildImage(image),
              _buildDetails(name, email, phone),
              if (imageAtRight) _buildImage(image),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String image) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
      child: SizedBox(
        width: 100,
        height: 100,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Image.asset(
            'assets/$image',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(String name, String email, String phone) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text('Email: $email'),
            Text('Phone: $phone'),
          ],
        ),
      ),
    );
  }
}
