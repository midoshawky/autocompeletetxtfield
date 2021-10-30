import 'package:flutter/material.dart';
typedef StringCallBack = Function(String);
class AutoCompleteTextSearchField extends StatefulWidget {
  //Constructor
  ///TextEditingController
  final TextEditingController? textEditingController;
  ///List of Strings that you wanna to
  final List<String>? suggestions;
  ///InputDecoration you can decorate your text field as any other
  final InputDecoration? inputDecoration;
  ///The padding between menu and screen in two sides
  final double? menuSidePadding;
  ///Menu layout border radius
  final BorderRadius? menuBorderRadius;
  ///Menu Elevation (Shadow)
  final double? menuElevation;
  ///Menu item select callback
  final StringCallBack? onItemSelect;
  AutoCompleteTextSearchField(
      {Key? key,
        required this.suggestions,
        this.inputDecoration,
        this.menuBorderRadius,
        this.menuSidePadding,
        this.menuElevation = 1.0,
        this.textEditingController,
        required this.onItemSelect})
      : super(key: key);

  @override
  _AutoCompleteTextSearchFieldState createState() => _AutoCompleteTextSearchFieldState();
}

class _AutoCompleteTextSearchFieldState extends State<AutoCompleteTextSearchField> {
  OverlayEntry? floating;
  GlobalKey? floatingKey;

  @override
  void initState() {
    ///This global key to be assigned in the render box
    floatingKey = LabeledGlobalKey("Floating");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        key: floatingKey,
        children: [
          TextField(
            controller: widget.textEditingController,
            decoration: widget.inputDecoration,
            autofocus: false,
            onChanged: (val) => _startFiltering(val),
          ),
        ],
      ),
      ///On Back Button pressed
      onWillPop: _onBackPressed,
    );
  }

  ///This method for filtering the list and provide the suggestions depend on user input
  void _startFiltering(String val) {
    List<String> filter = widget.suggestions!.where((element) => _equalsIgnoreCase(element, val)).toList();
    print(filter);
    ///These are validations to insure that the menu will disappear when no suggestions and show up in other case
    if (filter.isNotEmpty) {
      if (floating != null) {
        floating!.remove();
        floating = null;
      }
      floating = _createFloating(filter);
      Overlay.of(floatingKey!.currentContext!)!.insert(floating!);
    } else {
      if (floating != null) {
        floating!.remove();
        floating = null;
      }
    }
    if (val.isEmpty) {
      if (floating != null) {
        floating!.remove();
        floating = null;
      }
    }
  }

  ///Method to show up menu as a overlay menu
  OverlayEntry _createFloating(List<String> filtered) {
    ///RenderBox to determine the location of the textfield on screen
    final renderBox = floatingKey!.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(builder: (context) {
      return Positioned(
          left: 10,
          right: 10,
          top: offset.dy + 35,
          child: Material(
            color: Colors.transparent,
            elevation: 20,
            child: Card(
              elevation: widget.menuElevation,
              shape: RoundedRectangleBorder(
                  borderRadius: widget.menuBorderRadius != null
                      ? widget.menuBorderRadius!
                      : BorderRadius.circular(10)),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(filtered[index]),
                    onTap: () {
                      String selected = filtered[index];
                      widget.onItemSelect!(selected);
                      widget.textEditingController!.text = selected;
                      widget.textEditingController!.selection = TextSelection(baseOffset: selected.length, extentOffset: selected.length);

                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      if (floating != null) {
                        floating!.remove();
                        floating = null;
                      }
                    },
                  ),
                ),
                shrinkWrap: true,
              ),
            ),
          ));
    });
  }

  ///this method to ignore the Lower/Upper case
  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase().startsWith(string2.toLowerCase());
  }

  ///On User back button press will remove the menu just regular behaviour
  Future<bool> _onBackPressed() {
    if (floating != null) {
      floating!.remove();
      floating = null;
      return Future.value(false);
    }
    return Future.value(true);
  }
  @override
  void dispose() {
    widget.textEditingController!.dispose();
    super.dispose();
  }
}
