class ACL {
  final String id;
  final bool download;
  final bool delete;
  final bool read;
  final bool write;
  final bool share;

  ACL({
    this.id,
    this.download,
    this.delete,
    this.read,
    this.write,
    this.share,
  });

  factory ACL.fromJSON(Map<String, dynamic> data) {
    return ACL(
      id: data['id'],
      download: data['download'],
      delete: data['delete'],
      read: data['read'],
      write: data['write'],
      share: data['share'],
    );
  }
}
