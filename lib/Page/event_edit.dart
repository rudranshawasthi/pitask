import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pitask/Model/event.dart';
import 'package:pitask/provider/eventProvider.dart';
import 'package:pitask/utils.dart';
import 'package:provider/provider.dart';

class EventEdit extends StatefulWidget {
  final Event? event;

  const EventEdit({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  _EventEditState createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  Color currentColor = Colors.lightGreen;
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(hours: 2));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buildEditAction() => [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, shadowColor: Colors.transparent),
              onPressed: saveForm,
              icon: Icon(Icons.done),
              label: Text('Save')),
        ];
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditAction(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildTitle(),
              SizedBox(
                height: 12,
              ),
              buildDateTimePickers(),
              buildColorPicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() => TextFormField(
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(),
        validator: (title) =>
            title != null && title.isEmpty ? 'Title can not be empy' : null,
        controller: titleController,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildForm(),
          buildTo(),
        ],
      );

  Widget buildColorPicker() {
    return ColorPicker(
      pickerColor: currentColor,
      onColorChanged: changeColor,
      colorPickerWidth: 300.0,
      pickerAreaHeightPercent: 0.7,
      enableAlpha: true,
      displayThumbColor: true,
      showLabel: true,
      paletteType: PaletteType.hsv,
      // pickerAreaBorderRadius: const BorderRadius.only(
      //   topLeft: const Radius.circular(2.0),
      //   topRight: const Radius.circular(2.0),
      // ),
    );
  }

  void changeColor(Color color) => setState(() => currentColor = color);

  Widget buildForm() => buildHeader(
        header: 'From',
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: buildDropdownField(
                text: Utils.toDate(fromDate),
                onClicked: () => pickFromDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(fromDate),
                onClicked: () => pickFromDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) return;
    if (date.isAfter(toDate)) {
      toDate =
          DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }
    setState(() => fromDate = date);
  }

  Widget buildTo() => buildHeader(
        header: 'To',
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: buildDropdownField(
                text: Utils.toDate(toDate),
                onClicked: () => pickToDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(toDate),
                onClicked: () => pickToDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate,
        pickDate: pickDate, firstDate: pickDate ? fromDate : null);
    if (date == null) return;

    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2000, 1),
          lastDate: DateTime(2101));

      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (timeOfDay == null) return null;

      final date = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      );

      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return date.add(time);
    }
  }

  Widget buildDropdownField(
          {required String text, required VoidCallback onClicked}) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          child
        ],
      );

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Event(
        title: titleController.text,
        description: 'description',
        from: fromDate,
        to: toDate,
        backgroundColor: currentColor,
        isAllDay: false,
      );
      print(isValid);
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);

      Navigator.of(context).pop();
    }
  }
}
