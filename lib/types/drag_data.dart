/// Uniform drag and drop data.
/// A complex type to better filter which data can be dragged where.
class DragData {
  DragData({
    required this.index,
    required this.groupName,
    required this.type,
  });

  /// This item's position in a list.
  /// (If the drag and drop is used to re-order items, there's a list)
  final int index;

  /// An arbitrary name given to this item's group (e.g. "home-illustrations").
  /// Thus to avoid dragging items between sections.
  final String groupName;

  /// Information about the type of this item being dragged
  /// (e.g. book, illustration). (We could directly use runtimeType ?)
  final Type type;

  DragData copyWith({
    int? index,
    String? groupName,
    Type? type,
  }) {
    return DragData(
      index: index ?? this.index,
      groupName: groupName ?? this.groupName,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'DragData(index: $index, groupName: $groupName, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DragData &&
        other.index == index &&
        other.groupName == groupName &&
        other.type == type;
  }

  @override
  int get hashCode => index.hashCode ^ groupName.hashCode ^ type.hashCode;
}
