import 'package:flutter/material.dart';
import 'package:shoplants/data/models/plant.dart';
import 'package:shoplants/ui/widgets/grid_item_widget.dart';

class GridItemsWidget extends StatelessWidget {
  final List<Plant> plants;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;

  const GridItemsWidget({
    Key? key,
    required this.plants,
    required this.padding,
    required this.crossAxisCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      shrinkWrap: true,
      itemBuilder: (context, index) => GridItemWidget(plant: plants[index]),
      itemCount: plants.length,
    );
  }
}
