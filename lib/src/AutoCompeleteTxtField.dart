import 'package:flutter/material.dart';

class AutoCompeleteTextField extends StatefulWidget {
  final List<String> suggestions;
  final decoration;
  final listElevation;
  final width;
  final onTextSubmited;
  final collapsed;
  AutoCompeleteTextField(
      {Key key,
      @required this.suggestions,
      this.decoration,
      this.listElevation,
      this.width,
      this.onTextSubmited(String value),
      this.collapsed});

  @override
  _MACTextFieldState createState() => _MACTextFieldState();
}

class _MACTextFieldState extends State<AutoCompeleteTextField> {
  List<String> _list = [];
  List<String> tempList;
  var _size;
  var view;
  double _listHight;

  TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    _size = 0;
    _listHight = 0.0;
    print(_list);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: widget.decoration,
            onChanged: (val) => _suggestionsFilter(val),
            onSubmitted: (val) => widget.onTextSubmited(val),
          ),
          (widget.collapsed == null || widget.collapsed == false)
              ? Card(
                  elevation: widget.listElevation,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                      transform:
                          Matrix4.translationValues(0, _listHight * _size, 0),
                      height: _size * 55.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: _suggestionList(_list)),
                )
              : Container(
                  child: _suggestionList(_list),
                  height: 40.0,
                )
        ],
      ),
      width: widget.width,
    );
  }

  Widget _suggestionList(List sList) {
    return ScrollConfiguration(
      child: ListView.builder(
          scrollDirection:
              (widget.collapsed == null || widget.collapsed == false)
                  ? Axis.vertical
                  : Axis.horizontal,
          itemCount: sList.length,
          padding: EdgeInsets.only(top: 0),
          primary: true,
          itemBuilder: (context, indx) =>
              (widget.collapsed == null || widget.collapsed == false)
                  ? _nonCollapsed(sList, indx)
                  : _collapsed(sList, indx)),
      behavior: NoGlow(),
    );
  }

  Widget _nonCollapsed(List sList, indx) {
    return ListTile(
      title: Text(sList[indx].toString()),
      onTap: () {
        _controller.text = sList[indx].toString();
        setState(() {
          _list.clear();
          _size = 0.0;
        });
      },
      onLongPress: () {
        _controller.text = sList[indx].toString();
        setState(() {
          _list.clear();
          _size = 0.0;
        });
      },
    );
  }

  Widget _collapsed(List sList, indx) {
    return GridTile(
        child: GestureDetector(
      child: Padding(
        child: Container(
          child: Center(
            child: Text(sList[indx].toString()),
          ),
        ),
        padding: EdgeInsets.only(right: 8, left: 8),
      ),
      onTap: () {
        _controller.text = sList[indx].toString();
        setState(() {
          _list.clear();
          _size = 0.0;
        });
      },
      onLongPress: () {
        _controller.text = sList[indx].toString();
        setState(() {
          _list.clear();
          _size = 0.0;
        });
      },
    ));
  }

  void _suggestionsFilter(txtValue) {
    _list.clear();
    for (var value in widget.suggestions) {
      if (txtValue != '' && _igonreCaseSenstivity(value, txtValue)) {
        _list.add(value);
        view = _suggestionList(_list);
      }
    }
    setState(() {
      _size = _list.length;
    });
  }

  bool _igonreCaseSenstivity(String value, String txtValue) {
    var exprsion =
        (value.toLowerCase().startsWith(txtValue.toString().toLowerCase()) ||
            value.toLowerCase().startsWith(txtValue.toString().toLowerCase()));
    return exprsion;
  }
}

class NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}
