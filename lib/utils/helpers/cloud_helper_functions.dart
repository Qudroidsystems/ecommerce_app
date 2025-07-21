import 'package:flutter/material.dart';

class TCloudHelperFunctions {
  static Widget? checkMultiRecordState({required AsyncSnapshot snapshot, Widget? loader, Widget? error, Widget? nothingFound}) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return loader ?? const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return error ?? const Center(child: Text('Something went wrong. Please try again later.'));
    }

    if (!snapshot.hasData || (snapshot.data is List && snapshot.data!.isEmpty)) {
      return nothingFound ?? const Center(child: Text('No records found.'));
    }

    return null;
  }
}