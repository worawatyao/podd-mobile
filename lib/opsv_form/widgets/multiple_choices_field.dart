part of 'widgets.dart';

class FormMultipleChoicesField extends StatefulWidget {
  final opsv.MultipleChoicesField field;

  const FormMultipleChoicesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormMultipleChoicesField> createState() =>
      _FormMultipleChoicesFieldState();
}

class _FormMultipleChoicesFieldState extends State<FormMultipleChoicesField> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        widget.field.isValid;

        if (!widget.field.display) {
          return Container();
        }

        return ValidationWrapper(
          widget.field,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.field.label != null && widget.field.label != "")
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.field.label!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ...widget.field.options
                  .map((option) => _OptionWidget(widget.field, option))
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final opsv.MultipleChoicesField field;
  final opsv.ChoiceOption option;
  final TextEditingController _controller = TextEditingController();

  _OptionWidget(this.field, this.option, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        var _checkValue = field.valueFor(option.value);
        var _text = field.textValueFor(option.value)?.value ?? '';
        var _invalidTextMessage =
            field.invalidTextMessageFor(option.value)?.value;

        if (_text != _controller.text) {
          _controller.value = TextEditingValue(
              text: _text,
              selection: TextSelection.collapsed(offset: _text.length));
        }
        return Row(
          children: [
            Checkbox(
                value: _checkValue,
                onChanged: (value) {
                  field.setSelectedFor(option.value, value ?? false);
                }),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Text(option.label),
                    onTap: () {
                      field.setSelectedFor(option.value, !_checkValue);
                    },
                  ),
                  if (option.textInput && _checkValue)
                    TextField(
                      controller: _controller,
                      onChanged: (val) {
                        field.setTextValueFor(option.value, val);
                      },
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorText: _invalidTextMessage),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
