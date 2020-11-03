import 'package:flutter/material.dart';

class MultiSelectChips extends StatefulWidget {
  final List<String> reportList;
  final List<String> selectedList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChips(this.reportList, this.selectedList, {this.onSelectionChanged});

  @override
  _MultiSelectChipsState createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<MultiSelectChips> {
  _buildChoiceList() {
    List<Widget> choices = List();
    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          selectedColor: Colors.black54,
          label: Text(item),
          selected: widget.selectedList.contains(item),
          onSelected: (selected) {
            setState(() {
              widget.selectedList.contains(item)
                  ? widget.selectedList.remove(item)
                  : widget.selectedList.add(item);
              widget.onSelectionChanged(widget.selectedList);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
