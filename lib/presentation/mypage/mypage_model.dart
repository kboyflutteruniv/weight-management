import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weight_management/domain/ideal_muscle_data.dart';

class MyPageModel extends ChangeNotifier {
  double idealWeight;
  double idealFat;
  File idealImageFile;
  String idealImagePath;
  List<IdealMuscleData> idealMuscleList = [];
  IdealMuscleData idealMuscle;
  TextEditingController idealWeightTextController, idealFatTextController;
  bool hasIdealMuscle = false;

  Future fetchData() async {
    final docs =
        await FirebaseFirestore.instance.collection('idealMuscleData').get();
    final muscleData = docs.docs.map((doc) => IdealMuscleData(doc)).toList();
    this.idealMuscleList = muscleData;
    idealMuscle = idealMuscleList[0];
    if (idealMuscle != null) hasIdealMuscle = true;
    if (hasIdealMuscle) {
      idealWeight = idealMuscle.weight;
      idealWeightTextController =
          TextEditingController(text: idealWeight.toString());
      if (idealMuscle.bodyFatPercentage != null) {
        idealFat = idealMuscle.bodyFatPercentage;
        idealFatTextController =
            TextEditingController(text: idealFat.toString());
      }
      if (idealMuscle.imagePath != null)
        idealImageFile = File(idealMuscle.imagePath);
    }

    notifyListeners();
  }

  Future showImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    idealImagePath = pickedFile.path;
    idealImageFile = File(idealImagePath);
    notifyListeners();
  }

  Future addDataToFirebase() async {
    //firebaseに値を追加
    if (idealWeight == null) {
      throw ('体重を入力してください');
    }
    if (idealImageFile != null && idealFat != null) {
      //写真と体脂肪率があるとき
      final imageURL = await _uploadImage();
      await FirebaseFirestore.instance.collection('idealMuscleData').add(
        {
          'weight': idealWeight,
          'bodyFatPercentage': idealFat,
          'imageURL': imageURL,
          'imagePath': idealImagePath,
        },
      );
    } else if (idealImageFile == null && idealFat != null) {
      //写真なし＆体脂肪率あり
      await FirebaseFirestore.instance.collection('idealMuscleData').add(
        {
          'weight': idealWeight,
          'bodyFatPercentage': idealFat,
        },
      );
    } else if (idealImageFile != null && idealFat == null) {
      //写真アリ＆体脂肪率なし
      final imageURL = await _uploadImage();
      await FirebaseFirestore.instance.collection('idealMuscleData').add(
        {
          'weight': idealWeight,
          'imageURL': imageURL,
          'imagePath': idealImagePath,
        },
      );
    } else if (idealImageFile == null && idealFat == null) {
      //写真なし＆体脂肪率なし
      await FirebaseFirestore.instance.collection('idealMuscleData').add(
        {
          'weight': idealWeight,
        },
      );
    }
  }

  Future updateData(IdealMuscleData muscleData) async {
    if (idealWeight == null) {
      throw ('体重を入力してください');
    }
    if (idealImageFile != null && idealFat != null) {
      //写真と体脂肪率があるとき
      final imageURL = await _uploadImage();
      final document = FirebaseFirestore.instance
          .collection('idealMuscleData')
          .doc(idealMuscle.documentID);
      await document.update({
        'weight': idealWeight,
        'bodyFatPercentage': idealFat,
        'imageURL': imageURL,
        'imagePath': idealImagePath,
      });
    } else if (idealImageFile == null && idealFat != null) {
      final document = FirebaseFirestore.instance
          .collection('idealMuscleData')
          .doc(idealMuscle.documentID);
      await document.update({
        'weight': idealWeight,
        'bodyFatPercentage': idealFat,
      });
    } else if (idealImageFile != null && idealFat == null) {
      final imageURL = await _uploadImage();
      final document = FirebaseFirestore.instance
          .collection('idealMuscleData')
          .doc(idealMuscle.documentID);
      await document.update({
        'weight': idealWeight,
        'imageURL': imageURL,
        'imagePath': idealImagePath,
      });
    } else if (idealImageFile == null && idealFat == null) {
      final document = FirebaseFirestore.instance
          .collection('idealMuscleData')
          .doc(idealMuscle.documentID);
      await document.update({
        'weight': idealWeight,
      });
    }
  }

  Future<String> _uploadImage() async {
    final storage = FirebaseStorage.instance;
    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child("idealMuscle/$idealWeight")
        .putFile(idealImageFile)
        .onComplete;
    final String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
