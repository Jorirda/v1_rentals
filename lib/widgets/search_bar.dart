import 'package:flutter/material.dart';
import 'package:v1_rentals/generated/l10n.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const SearchBarWidget({
    required this.searchController,
    required this.onSearchChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          suffixIcon: const Icon(
            Icons.search,
            color: Colors.red,
          ),
          hintText: S.of(context).search_for_vehicles,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
