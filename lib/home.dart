import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> _marcadores = {};    
  Set<Polygon> _polygons = {};    

  _carregarPolygons() {
    Set<Polygon> listaPolygons = {};
    Polygon polygon = Polygon(
      polygonId: PolygonId('1'),
      fillColor: Colors.red,
      strokeColor: Colors.black,
      strokeWidth: 5,
      points: [
        LatLng(-23.551309, -51.465834),
        LatLng(-23.551274, -51.463227),
        LatLng(-23.553374, -51.462606),
        LatLng(-23.554581, -51.466619),
      ],
      consumeTapEvents: true,
      onTap: () { print('poligono clicado'); }
    );

    listaPolygons.add(polygon);
    
    setState(() {
      _polygons = listaPolygons;
    });
  }
  _carregarMarcadores() {
    Set<Marker> marcadoresLocal = {};
    Marker marcadorShopping = Marker(
      markerId: const MarkerId('shopping'),
      position: const LatLng(-23.55216, -51.46438),
      infoWindow: const InfoWindow(
        title: 'Shopping Centro Norte'
      ), 
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueMagenta
      ),
      onTap: () {
        print('Shopping clicado');  
      }
    );

    Marker marcadorParque = Marker(
      markerId: const MarkerId('parque'),
      position: const LatLng(-23.566827, -51.473652),
      infoWindow: const InfoWindow(
        title: 'Parque Lago jabuti'
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure
      ),
      onTap: () {
        print('Parque clicado');  
      }
    );

    marcadoresLocal.add(marcadorShopping);
    marcadoresLocal.add(marcadorParque);

    setState(() {
      _marcadores = marcadoresLocal;
    });
  }
  
  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation
    );

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17
      );
    });
    _movimentarCamera();
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    //_controller.future<GoogleMapController>
  }     

  _movimentarCamera() async {
    var googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        _kGooglePlex
      )
    );
  }

  _adicionarListenerLocalizacao() {
      final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
      var locationSettings = const LocationSettings(
       distanceFilter: 10,
       accuracy: LocationAccuracy.bestForNavigation
      );
    _geolocatorPlatform.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      print('usuario se moveu'); 
      setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17
      );
      _movimentarCamera();
    });
    });
  }

  CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(-23.55216, -51.46438),
    zoom: 16,
  );    

  @override
  void initState() {
    
    super.initState();
    _carregarMarcadores();
    _carregarPolygons();
    _recuperarLocalizacaoAtual();
    _adicionarListenerLocalizacao();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapas e geolocalização"),),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        onPressed: _movimentarCamera,
        child: const Icon(Icons.done),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: _onMapCreated,
        markers: _marcadores,
        polygons: _polygons,
        myLocationEnabled: true,
      ),
    );
  }
}