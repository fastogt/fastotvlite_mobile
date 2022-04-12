abstract class IStream {
  String id();

  void setId(String value);

  String primaryUrl();

  void setPrimaryUrl(String value);

  String displayName();

  void setDisplayName(String value);

  List<String> groups();

  void setGroups(List<String> value);

  String icon();

  void setIcon(String value);

  int iarc();

  void setIarc(int value);

  bool favorite();

  void setFavorite(bool value);

  int recentTime();

  void setRecentTime(int value);

  List<String> get urls;
}
