import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  prefixIconColor: Colors.red,
                  hintText: 'Search rentals',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onChanged: (value) {
                  // Implement your search logic here
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.fiber_new_sharp),
                        selectedIcon: Icon(Icons.fiber_new_rounded),
                        label: Text('New'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_fire_department_outlined),
                        selectedIcon: Icon(Icons.local_fire_department),
                        label: Text('Popular'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.thumb_up_outlined),
                        selectedIcon: Icon(Icons.thumb_up),
                        label: Text('Recommended'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star_border),
                        selectedIcon: Icon(Icons.star),
                        label: Text('Luxury'),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                  const Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          // Main Content
                          Text('data'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
