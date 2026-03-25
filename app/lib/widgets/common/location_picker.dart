// LocationPicker — Nominatim search + GPS + flutter_map tap.
// Ported from rabble's LocationPicker, adapted to silat theme.
// Returns lat/lng/label; H3 cell computed server-side on sync.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../theme/silat_theme.dart';

class LocationResult {
  const LocationResult({
    required this.lat,
    required this.lng,
    required this.label,
  });

  final double lat;
  final double lng;
  final String label;
}

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.initial,
    required this.onSelected,
  });

  final LocationResult? initial;
  final ValueChanged<LocationResult> onSelected;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _search = TextEditingController();
  final _map = MapController();
  List<_Place> _results = [];
  bool _searching = false;
  bool _gps = false;
  LatLng? _pin;
  String? _label;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _pin = LatLng(widget.initial!.lat, widget.initial!.lng);
      _label = widget.initial!.label;
      _search.text = widget.initial!.label;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _query(String q) async {
    if (q.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search',
      ).replace(queryParameters: {
        'q': q,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      });
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'silat-arrahim/1.0',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _results = data
              .map((j) => _Place(
                    label: j['display_name'] as String,
                    lat: double.parse(j['lat'] as String),
                    lng: double.parse(j['lon'] as String),
                  ))
              .toList();
        });
      }
    } catch (_) {
    } finally {
      setState(() => _searching = false);
    }
  }

  void _pick(_Place place) {
    setState(() {
      _pin = LatLng(place.lat, place.lng);
      _label = place.label.split(',').first.trim();
      _search.text = _label!;
      _results = [];
    });
    _map.move(_pin!, 13);
    _emit();
  }

  Future<void> _useGps() async {
    setState(() => _gps = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _pin = LatLng(pos.latitude, pos.longitude);
        _label = 'current location';
        _search.text = _label!;
        _results = [];
      });
      _map.move(_pin!, 14);
      _emit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _gps = false);
    }
  }

  void _onTap(TapPosition _, LatLng pt) {
    setState(() {
      _pin = pt;
      _label =
          '${pt.latitude.toStringAsFixed(4)}, ${pt.longitude.toStringAsFixed(4)}';
      _search.text = _label!;
      _results = [];
    });
    _emit();
  }

  void _emit() {
    if (_pin != null) {
      widget.onSelected(
          LocationResult(lat: _pin!.latitude, lng: _pin!.longitude, label: _label ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search bar ──────────────────────────────────────────────────
        TextField(
          controller: _search,
          style: SilatTypography.body(dark: isDark),
          decoration: InputDecoration(
            hintText: 'search for a place…',
            hintStyle: SilatTypography.body(dark: isDark)
                .copyWith(color: SilatColors.fg3),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            isDense: true,
          ),
          onChanged: _query,
        ),

        // ── Results dropdown ────────────────────────────────────────────
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: SilatColors.bg1,
              borderRadius: BorderRadius.circular(SilatRadius.sm),
              border: Border.all(color: SilatColors.bg3),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final r = _results[i];
                final title = r.label.split(',').first.trim();
                final sub = r.label;
                return ListTile(
                  dense: true,
                  leading:
                      Icon(Icons.place_outlined, size: 16, color: SilatColors.fg3),
                  title: Text(title,
                      style: SilatTypography.body(dark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(sub,
                      style: SilatTypography.label(dark: isDark)
                          .copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  onTap: () => _pick(r),
                );
              },
            ),
          ),

        const SizedBox(height: SilatSpacing.sm),

        // ── GPS button ──────────────────────────────────────────────────
        GestureDetector(
          onTap: _gps ? null : _useGps,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _gps
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.my_location_outlined,
                      size: 14, color: SilatColors.slate),
              const SizedBox(width: SilatSpacing.xs),
              Text('use my location',
                  style: SilatTypography.label(dark: isDark)
                      .copyWith(color: SilatColors.slate)),
            ],
          ),
        ),

        const SizedBox(height: SilatSpacing.sm),

        // ── Map preview ─────────────────────────────────────────────────
        SizedBox(
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SilatRadius.md),
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _pin ?? const LatLng(25.0, 10.0),
                initialZoom: _pin != null ? 13 : 2,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'world.silat.app',
                ),
                if (_pin != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _pin!,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.location_pin,
                        color: SilatColors.terracotta,
                        size: 36,
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ),

        // ── Coords summary ──────────────────────────────────────────────
        if (_pin != null) ...[
          const SizedBox(height: SilatSpacing.xs),
          Text(
            '${_pin!.latitude.toStringAsFixed(5)}, ${_pin!.longitude.toStringAsFixed(5)}',
            style: SilatTypography.label(dark: isDark)
                .copyWith(color: SilatColors.fg3, fontFamily: 'monospace'),
          ),
        ],
      ],
    );
  }
}

class _Place {
  const _Place({required this.label, required this.lat, required this.lng});
  final String label;
  final double lat;
  final double lng;
}
