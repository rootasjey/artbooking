class ACL {
  ACL({
    required this.id,
    this.download = false,
    this.delete = false,
    this.read = false,
    this.write = false,
    this.share = false,
  });

  final String id;
  final bool download;
  final bool delete;
  final bool read;
  final bool write;
  final bool share;

  factory ACL.empty() {
    return ACL(id: '');
  }

  factory ACL.fromJSON(Map<String, dynamic> data) {
    return ACL(
      id: data['id'] ?? '',
      download: data['download'] ?? false,
      delete: data['delete'] ?? false,
      read: data['read'] ?? false,
      write: data['write'] ?? false,
      share: data['share'] ?? false,
    );
  }
}
