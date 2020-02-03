import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_bottom_app_bar.dart';
import 'package:wlocation/components/custom_drawer.dart';
import 'package:wlocation/components/custom_floating_action_button.dart';

class CustomScaffold extends StatelessWidget {
  final bool backEnabled;
  final Widget body;
  final CustomFloatingActionButton scanButton;

  CustomScaffold({
    @required this.backEnabled,
    @required this.body,
    this.scanButton,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => backEnabled,
      child: Scaffold(
        bottomNavigationBar: CustomBottomAppBar(
          backButtonEnabled: backEnabled,
          scanButtonEnabled: scanButton != null,
        ),
        floatingActionButton: scanButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        drawer: CustomDrawer(),
        body: body,
      ),
    );
  }
}
