import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/report/followup_list_view.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import 'package:podd_app/ui/report/report_comment_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class IncidentReportView extends HookWidget {
  final String id;
  const IncidentReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 3);

    return ViewModelBuilder<IncidentReportViewModel>.reactive(
      viewModelBuilder: () => IncidentReportViewModel(id),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(child: Text('Detail')),
              Tab(child: Text('Comment')),
              Tab(child: Text('Follow Up')),
            ],
          ),
          title: const Text("Report detail"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: viewModel.isBusy
              ? const CircularProgressIndicator()
              : !viewModel.hasError
                  ? TabBarView(controller: _tabController, children: [
                      _IncidentDetail(),
                      ReportCommentView(viewModel.data!.threadId!),
                      FollowupListView(viewModel.data!.id)
                    ])
                  : const Text("Incident report not found"),
        ),
      ),
    );
  }
}

class _IncidentDetail extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final incident = viewModel.data!;
    var formatter = DateFormat("dd/MM/yyyy HH:mm");

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _title(context, incident),
        const SizedBox(height: 10),
        Text(
          formatter.format(incident.createdAt.toLocal()),
          textScaleFactor: .75,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            color: Colors.white,
            constraints:
                const BoxConstraints(minHeight: 100, minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(incident.description.isEmpty
                  ? "no description"
                  : incident.description),
            ),
          ),
        ),
        _Images(),
        const SizedBox(height: 8),
        _Map(),
      ],
    );
  }

  _title(BuildContext context, IncidentReport incident) {
    return Row(
      children: [
        Text(
          incident.reportTypeName,
          textScaleFactor: 1.5,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        if (incident.caseId != null)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
            child: const Text(
              "Case",
              style: TextStyle(
                color: Colors.white,
              ),
              textScaleFactor: 0.8,
            ),
          ),
      ],
    );
  }
}

class _Images extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final images = viewModel.data!.images;
    var _pageController = usePageController(viewportFraction: .5);

    return Container(
      color: Colors.white,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 150),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 150,
        child: (images != null && images.isNotEmpty)
            ? PageView.builder(
                itemCount: images.length,
                pageSnapping: true,
                controller: _pageController,
                itemBuilder: (context, pagePosition) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    child: CachedNetworkImage(
                      imageUrl: viewModel
                          .resolveImagePath(images[pagePosition].thumbnailPath),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            : const Text("No images uploaded"),
      ),
    );
  }
}

class _Map extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final latlng = viewModel.latlng;

    final Completer<GoogleMapController> _controller = Completer();
    var markers = <Marker>{};

    if (latlng != null) {
      markers.add(Marker(
        markerId: const MarkerId('center'),
        position: LatLng(latlng[0], latlng[1]),
      ));
    }

    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 250,
      ),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: (latlng != null)
            ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    zoom: 12, target: LatLng(latlng[0], latlng[1])),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: markers,
              )
            : const Text("No gps location provided"),
      ),
    );
  }
}
