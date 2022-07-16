import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_search_item_type.dart';
import 'package:flutter/material.dart';

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.index,
    required this.searchItemType,
    required this.titleValue,
    this.onTap,
  }) : super(key: key);

  final EnumSearchItemType searchItemType;
  final int index;
  final void Function(EnumSearchItemType searchItemType, String id)? onTap;
  final String id;
  final String imageUrl;
  final String titleValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap != null ? () => onTap?.call(searchItemType, id) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  imageUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    titleValue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Utilities.fonts.body4(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getCardColor(BuildContext context) {
    switch (searchItemType) {
      case EnumSearchItemType.book:
        return Theme.of(context).secondaryHeaderColor.withOpacity(0.2);
      case EnumSearchItemType.illustration:
        return Theme.of(context).primaryColor.withOpacity(0.2);
      case EnumSearchItemType.book:
        return Constants.colors.tertiary.withOpacity(0.2);
      default:
        return Theme.of(context).primaryColor.withOpacity(0.2);
    }
  }
}
