import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers_map/ui/widgets/widget_button.dart';
import 'package:makers_map/ui/widgets/widget_text_field.dart';

class AddComment extends StatelessWidget {
  AddComment({Key? key}) : super(key: key) {
    _commentEditingController = TextEditingController();
    _titleEditingController = TextEditingController();
    _comList = Get.arguments[0];
  }
  final _formKey = GlobalKey<FormState>();
  late RxList<Map<String, dynamic>> _comList;
  late TextEditingController _commentEditingController;
  late TextEditingController _titleEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Agrega un Comentario'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            color: const Color.fromRGBO(244, 244, 244, 1),
            child: ListView(
              children: [
                WidgetTextField(
                  label: "Titulo del comentario",
                  controller: _titleEditingController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Este campo no puede estar vacio";
                    }
                  },
                  obscure: false,
                  digitsOnly: false,
                  maxLine: 2,
                ),
                WidgetTextField(
                  label: "Comentario",
                  controller: _commentEditingController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "El comentario no puede estar vacio";
                    }
                  },
                  obscure: false,
                  digitsOnly: false,
                  maxLine: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      WidgetButton(
                        text: "Guardar Comentario",
                        onPressed: () {
                          final form = _formKey.currentState;
                          form!.save();
                          if (form.validate()) {
                            _comList.add({
                              "title": _titleEditingController.text,
                              "comment": _commentEditingController.text,
                            });
                            Get.back();
                          }
                        },
                        typeMain: true,
                        loading: false,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
