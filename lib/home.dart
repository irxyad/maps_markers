import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps_markers/main.dart';
import 'package:maps_markers/widgets/button.dart';
import 'cons.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  String location = "Location";
  bool multipleMarker = false;
  int numberMarker = 1;
  double zoomLevel = 14;
  MapType _currentMapType = MapType.normal;

  final Completer<GoogleMapController> _controller = Completer();
  static const double _longtude = 119.451332;
  static const double _latitude = -5.202745;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(_latitude, _longtude), zoom: 14);
  final List<Marker> _markers = <Marker>[];

//get permission location
  Future<Position> getUserCurrentLocatioin() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {});
    return await Geolocator.getCurrentPosition();
  }

  //load GMaps style
  String? _lightMapStyle;
  String? _darkMapStyle;

  Future _loadMapStyle() async {
    await rootBundle
        .loadString('assets/map_style/light_theme.json')
        .then((string) {
      _lightMapStyle = string;
    });

    await rootBundle
        .loadString('assets/map_style/dark_theme.json')
        .then((string) {
      _darkMapStyle = string;
    });
  }

//Trick to refresh gmaps
  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const MapsScreen(),
      ),
    );
  }

//to get fixed zoom
  void _getZoom(CameraPosition position) {
    setState(() {
      zoomLevel = position.zoom;
    });
  }

// to create a new marker(single or multiple marker)
  Future createMarker(LatLng latLng) async {
    if (multipleMarker == false) {
      final GoogleMapController controller = await _controller.future;
      CameraPosition cameraPosition =
          CameraPosition(target: latLng, zoom: zoomLevel);
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      List<Placemark> placemark =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemark.first;
      var address = place.street;
      setState(() {
        location = address.toString();
      });
      _markers.add(
        Marker(
          markerId: const MarkerId("1"),
          position: latLng,
          infoWindow: InfoWindow(
              title: location,
              snippet: "Latitude: ${latLng.latitude}, "
                  " Longtude: ${latLng.longitude}"),
        ),
      );
    } else {
      List<Placemark> placemark =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemark.first;
      var address = place.street;
      setState(() {
        location = address.toString();
        numberMarker = numberMarker + 1;
      });
      _markers.add(
        Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(
              Random().nextDouble() * Random().nextInt(360)),
          markerId: MarkerId(numberMarker.toString()),
          position: latLng,
          infoWindow: InfoWindow(
              onTap: () => setState(() {
                    location = address.toString();
                  }),
              title: location,
              snippet: "Latitude: ${latLng.latitude}, "
                  " Longtude: ${latLng.longitude}"),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = MyApp.themeNotifier.value == ThemeMode.light;
    return AnnotatedRegion(
      value: lightTheme
          ? SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: primary)
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: black),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
//Screen Gmaps
                Expanded(
                  child: ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    child: GoogleMap(
                        onTap: (LatLng lati) async {
                          createMarker(lati);
                        },
                        mapType: _currentMapType,
                        indoorViewEnabled: true,
                        mapToolbarEnabled: true,
                        zoomControlsEnabled: false,
                        trafficEnabled: true,
                        initialCameraPosition: _kGooglePlex,
                        markers: Set<Marker>.of(_markers),
                        onCameraMove: _getZoom,
                        onMapCreated: (GoogleMapController controller) {
                          controller.setMapStyle(
                              lightTheme ? _lightMapStyle : _darkMapStyle);
                          _controller.complete(controller);
                        }),
                  ),
                ),
//Bottom menu
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 20),
                  clipBehavior: Clip.antiAlias,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ButtonIcon(
                          elevation: 0,
                          label: lightTheme ? "Dark mode" : "Light mode",
                          icon: lightTheme
                              ? const Icon(
                                  Icons.dark_mode_rounded,
                                )
                              : Icon(
                                  Icons.sunny,
                                  color: Colors.amber.shade400,
                                ),
                          function: () {
                            // showExitPopup(context, lightTheme, _reset);
                            showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    actionsOverflowAlignment:
                                        OverflowBarAlignment.center,
                                    actionsPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 11),
                                    actionsAlignment: MainAxisAlignment.end,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          MyApp.themeNotifier.value = lightTheme
                                              ? ThemeMode.dark
                                              : ThemeMode.light;

                                          _reset();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            elevation: 0),
                                        child: Text("Yes",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(color: white)),
                                      )
                                    ],
                                    contentPadding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: white.withOpacity(.5))),
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    content: Text(
                                      MyApp.themeNotifier.value ==
                                              ThemeMode.dark
                                          ? "Changing to Light Mode will erase existing markers.\nStill want to change it?"
                                          : "Changing to Dark Mode will erase existing markers.\nStill want to change it?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(color: white),
                                    ),
                                  );
                                });
                          }),
                      const SizedBox(
                        width: 11,
                      ),
                      ButtonIcon(
                        elevation: 0,
                        label: "My Location",
                        icon: const Icon(Icons.my_location_rounded),
                        function: () {
                          getUserCurrentLocatioin().then((value) async {
                            _markers.add(
                              Marker(
                                markerId: const MarkerId("1"),
                                position:
                                    LatLng(value.latitude, value.longitude),
                                infoWindow: InfoWindow(
                                    title: "My Location",
                                    snippet: "Latitude: ${value.latitude}, "
                                        " Longtude: ${value.longitude}"),
                              ),
                            );
                            CameraPosition cameraPosition = CameraPosition(
                                target: LatLng(value.latitude, value.longitude),
                                zoom: 14);

                            final GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(cameraPosition));
                            List<Placemark> placemark =
                                await placemarkFromCoordinates(
                                    value.latitude, value.longitude);
                            Placemark place = placemark.last;
                            var address = place.street;
                            setState(() {
                              location = address.toString();
                            });
                          });
                        },
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      ButtonIcon(
                        elevation: 0,
                        label: multipleMarker == false
                            ? "Single marker"
                            : "Multiple marker",
                        icon: MyApp.themeNotifier.value == ThemeMode.light
                            ? SvgPicture.asset(
                                multipleMarker == false
                                    ? "assets/icons/ic_single_marker.svg"
                                    : "assets/icons/ic_multiple_marker.svg",
                                height: 18,
                              )
                            : SvgPicture.asset(
                                multipleMarker == false
                                    ? "assets/icons/ic_single_marker_dark.svg"
                                    : "assets/icons/ic_multiple_marker_dark.svg",
                                height: 18,
                              ),
                        function: () {
                          setState(() {
                            multipleMarker = !multipleMarker;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: PopupMenuButton<int>(
                          offset: const Offset(0, 0),
                          enableFeedback: true,
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                                onTap: () => setState(() {
                                      _currentMapType = MapType.satellite;
                                    }),
                                value: 0,
                                child: const JustText(
                                    bgColor: Colors.transparent,
                                    label: "Satelite",
                                    icon: Icons.nature_people_rounded)),
                            PopupMenuItem<int>(
                                onTap: () => setState(() {
                                      _currentMapType = MapType.terrain;
                                    }),
                                value: 1,
                                child: const JustText(
                                    bgColor: Colors.transparent,
                                    label: "Terrain",
                                    icon: Icons.terrain_rounded)),
                            PopupMenuItem<int>(
                                onTap: () => setState(() {
                                      _currentMapType = MapType.hybrid;
                                    }),
                                value: 2,
                                child: const JustText(
                                    bgColor: Colors.transparent,
                                    label: "Hybrid",
                                    icon: Icons.maps_home_work_rounded)),
                            PopupMenuItem<int>(
                                onTap: () => setState(() {
                                      _currentMapType = MapType.normal;
                                    }),
                                value: 2,
                                child: const JustText(
                                    bgColor: Colors.transparent,
                                    label: "Normal",
                                    icon: Icons.map_rounded)),
                          ],
                          child: JustText(
                            bgColor: Theme.of(context).cardColor,
                            label: "Map type",
                            icon: Icons.map_rounded,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
//Container address
            SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 11.0),
                child: ButtonIcon(
                    elevation: 2,
                    label: location,
                    icon: Icon(
                      Icons.location_on_rounded,
                      color: lightTheme ? Colors.red.shade800 : Colors.red,
                      size: 17,
                    ),
                    function: () {}),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _markers.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 58.0),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: FloatingActionButton(
                      onPressed: () {
                        _markers.clear();
                        location = "Location";
                        setState(() {});
                      },
                      backgroundColor: Colors.red,
                      elevation: 0,
                      disabledElevation: 0,
                      shape: CircleBorder(
                          side: BorderSide(
                              color: Theme.of(context).primaryColor, width: 5)),
                      child: const Icon(
                        Icons.clear,
                        color: white,
                        size: 18,
                      )),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
