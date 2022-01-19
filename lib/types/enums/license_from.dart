/// Tell if the license has been created by a staff member,
/// or is local to an user.
enum EnumLicenseCreatedBy {
  /// License created by a staff member.
  /// All users have access to it.
  staff,

  /// License created by an iser.
  /// Only them can use it.
  user,
}
