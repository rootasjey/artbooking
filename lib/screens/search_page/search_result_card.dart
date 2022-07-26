import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_search_item_type.dart';
import 'package:flutter/material.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
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
              imageWidget(),
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

  Widget imageWidget() {
    switch (searchItemType) {
      case EnumSearchItemType.book:
        return bookImageWidget();
      case EnumSearchItemType.illustration:
        return illustrationImageWidget();
      case EnumSearchItemType.user:
        return userImageWidget();
      default:
        return illustrationImageWidget();
    }
  }

  Widget bookImageWidget() {
    final double width = 130.0;
    final double height = 120.0;
    final double borderRadiusValue = 12.0;

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          Positioned(
            top: 0.0,
            left: 8.0,
            width: width - 4.0,
            child: Card(
              elevation: 2.0,
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: width,
                height: height - 8.0,
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            width: width - 4.0,
            child: Card(
              elevation: 1.0,
              color: Colors.orange.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: width,
                height: height - 8.0,
              ),
            ),
          ),
          SizedBox(
            width: width - 16.0,
            height: height,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                imageUrl,
                width: width - 4.0,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget illustrationImageWidget() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.network(
        imageUrl,
      ),
    );
  }

  Widget userImageWidget() {
    return BetterAvatar(
      image: NetworkImage(imageUrl),
      size: 140.0,
      onTap: onTap != null ? () => onTap?.call(searchItemType, id) : null,
    );
  }

  Color getCardColor(BuildContext context) {
    switch (searchItemType) {
      case EnumSearchItemType.book:
        return Constants.colors.tertiary.withOpacity(0.2);
      case EnumSearchItemType.illustration:
        return Theme.of(context).primaryColor.withOpacity(0.2);
      case EnumSearchItemType.user:
        return Theme.of(context).secondaryHeaderColor.withOpacity(0.2);
      default:
        return Theme.of(context).primaryColor.withOpacity(0.2);
    }
  }
}
