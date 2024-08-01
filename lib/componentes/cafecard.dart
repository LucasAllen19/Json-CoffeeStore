import 'package:coffeestore/estado.dart';
import 'package:flutter/material.dart';

class CafeCard extends StatelessWidget {
  final dynamic cafe;

  const CafeCard({super.key, required this.cafe});

  @override
  Widget build(BuildContext context) {

    String imagePath =
        "lib/recursos/imagens/${cafe["coffee"]["blobs"][0]["file"].toString()}";
    String avatarPath =
        "lib/recursos/imagens/${cafe["company"]["avatar"]}";

    return GestureDetector(
      onTap: () {
        // Assumindo que estadoApp.mostrarDetalhes é um método válido
        estadoApp.mostrarDetalhes(cafe["_id"]);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset(avatarPath),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cafe["company"]["name"],
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                cafe["coffee"]["name"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                cafe["coffee"]["description"],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 11
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "R\$ ${cafe['coffee']['price'].toString()}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(cafe["likes"].toString()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
