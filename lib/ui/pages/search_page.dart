import 'package:flutter/material.dart';
import 'package:shoplants/data/models/plant.dart';
import 'package:shoplants/data/utils/const.dart';
import 'package:shoplants/ui/widgets/grid_items_widget.dart';
import 'package:shoplants/ui/widgets/search_field_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // late initialize plant list
  late List<Plant> _plantList;

  // initialize search query
  String _query = '';

  @override
  void initState() {
    _plantList = Const.plants;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SearchFieldWidget(
            text: _query,
            onChanged: searchPlant,
          ),
          GridItemsWidget(
            plants: _plantList,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            crossAxisCount: 2,
          ),
        ],
      ),
    );
  }

  void searchPlant(String query) {
    final plants = Const.plants.where((plant) {
      final nameLower = plant.name.toLowerCase();
      final queryLower = query.toLowerCase();

      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      _query = query;
      _plantList = plants;
    });
  }
}
