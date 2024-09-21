class PlaceModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  PlaceModel(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude});
  static List<PlaceModel> places = [
    PlaceModel(
        id: 1,
        name: 'The child museum',
        latitude: 30.102963679661965,
        longitude: 31.33728630920912),
    PlaceModel(
        id: 2,
        name: 'Tolip El Galaa Hotel',
        latitude: 30.098879608012346,
        longitude: 31.348916366950846),
    PlaceModel(
      id: 3,
      name: 'Aviation Club',
      latitude: 30.10765650509598,
      longitude: 31.347086750924433,
    ),
    PlaceModel(
      id: 4,
      name: 'El Korba Square',
      latitude: 30.091282551428378,
      longitude: 31.324577629389623,
    ),
  ];
}
