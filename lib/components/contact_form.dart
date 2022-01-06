import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactForm extends StatefulWidget {
  final bool autoFocus;

  const ContactForm({
    Key? key,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  String _email = '';
  String _messageBody = '';
  String _messageTitle = '';
  String? _subject = "other".tr();
  String _subjectHintPrefix = '';

  bool _isLoading = false;
  bool _isMessageSent = false;

  bool _emailNeverEdited = true;
  bool _titleNeverEdited = true;
  bool _bodyNeverEdited = true;

  final Map<String, String> _errorMessages = {
    'emptyEmail': "email_empty_forbidden".tr(),
    'invalidEmail': "email_not_valid".tr(),
    'emptyTitle': "title_empty_forbidden_restrictions".tr(),
    'tooShortTitle': "title_restrictions".tr(),
    'emptyBody': "body_empty_forbidden_restrictions".tr(),
    'tooShortBody': "body_restrictions".tr(),
  };

  var _projectTypes = ["website".tr(), "mobile_app".tr(), "other".tr()];

  @override
  initState() {
    super.initState();

    setState(() {
      _subjectHintPrefix = "message_about".tr();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return progressForm();
    }

    if (_isMessageSent) {
      return successForm();
    }

    return formContainer();
  }

  Widget formContainer() {
    return Container(
      width: 460.0,
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            formBody(),
            Wrap(
              runSpacing: 20.0,
              spacing: 30.0,
              children: [
                formEmail(),
                validationButton(),
              ],
            ),
            ourEmail(),
            ourAdress(),
          ],
        ),
      ),
    );
  }

  Widget formBody() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 40.0,
      ),
      child: TextFormField(
        autofocus: widget.autoFocus,
        decoration: InputDecoration(
          labelText: "message_your".tr(),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(width: 2.0),
          ),
          errorText: getBodyErrorText(),
        ),
        maxLines: null,
        minLines: 7,
        validator: (value) {
          if (value!.isEmpty) {
            return _errorMessages['emptyBoy'];
          }

          if (value.length < 3) {
            return _errorMessages['tooShortBody'];
          }

          return null;
        },
        onChanged: (value) {
          _bodyNeverEdited = false;

          setState(() {
            _messageBody = value;
          });
        },
      ),
    );
  }

  Widget formDrowndownType() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 40.0,
        bottom: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            items: _projectTypes.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            value: _subject,
            onChanged: (value) {
              setState(() {
                _subject = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    _subjectHintPrefix,
                  ),
                ),
                Text(
                  _subject!.toLowerCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget formEmail() {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide(width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ),
          labelText: "email_address_yours".tr(),
          errorText: getEmailErrorText(),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return _errorMessages['emptyEmail'];
          }

          if (!UsersActions.checkEmailFormat(_email)) {
            return _errorMessages['invalidEmail'];
          }

          return null;
        },
        onChanged: (value) {
          _emailNeverEdited = false;

          setState(() {
            _email = value;
          });
        },
      ),
    );
  }

  Widget formHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 40.0,
      ),
      child: Opacity(
        opacity: 0.6,
        child: Text("direct_message".tr(),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget formTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30.0,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "title".tr(),
          icon: Icon(Icons.topic),
          errorText: getTitleErrorText(),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return _errorMessages['emptyTitle'];
          }

          if (value.length < 3) {
            return _errorMessages['tooShortTitle'];
          }

          return null;
        },
        onChanged: (value) {
          _titleNeverEdited = false;

          setState(() {
            _messageTitle = value;
          });
        },
      ),
    );
  }

  Widget ourEmail() {
    final email = "contact@artbooking.fr";

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Opacity(
          opacity: 0.8,
          child: InkWell(
            onTap: () => launch("mailto:$email"),
            child: Text.rich(
              TextSpan(
                text: "Or send us an email at ",
                children: [
                  TextSpan(
                    text: email,
                    style: Utilities.fonts.style(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ourAdress() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 200.0,
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "YVELINES, FRANCE",
              style: Utilities.fonts.style(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                "We can meet around Île-de-France, "
                "or we can have a video or audio chat",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressForm() {
    return SizedBox(
      height: 200.0,
      child: AnimatedAppIcon(
        textTitle: "sending_message".tr(),
      ),
    );
  }

  Widget successForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          Icon(
            UniconsLine.check,
            size: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "message_send_success".tr(),
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "email_response_soon".tr(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton(
              onPressed: () => setState(() => _isMessageSent = false),
              child: Text("message_send_other".tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: sendMessage,
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        primary: Colors.pink.shade300,
        textStyle: TextStyle(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 50.0,
          vertical: 20.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            // minWidth: 120.0,
            ),
        child: Text(
          "send".tr(),
          textAlign: TextAlign.center,
          style: Utilities.fonts.style(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool areFormValuesOK() {
    if (_messageBody.isEmpty || _messageBody.length <= 3) {
      Utilities.snack.e(
        context: context,
        message: getBodyErrorText(beforeSending: true),
      );

      return false;
    }

    if (_email.isEmpty || !UsersActions.checkEmailFormat(_email)) {
      Utilities.snack.e(
        context: context,
        message: getEmailErrorText(beforeSending: true),
      );

      return false;
    }

    return true;
  }

  String? getEmailErrorText({bool beforeSending = false}) {
    if (beforeSending) {
      _emailNeverEdited = false;
    }

    if (_emailNeverEdited) {
      return null;
    }

    if (_email.isEmpty) {
      return _errorMessages['emptyEmail'];
    }

    if (!UsersActions.checkEmailFormat(_email)) {
      return _errorMessages['invalidEmail'];
    }

    return null;
  }

  String? getTitleErrorText() {
    if (_titleNeverEdited) {
      return null;
    }

    if (_messageTitle.isEmpty) {
      return _errorMessages['emptyTitle'];
    }

    if (_messageTitle.length < 3) {
      return _errorMessages['tooShortTitle'];
    }

    return null;
  }

  String? getBodyErrorText({bool beforeSending = false}) {
    if (beforeSending) {
      _bodyNeverEdited = false;
    }

    if (_bodyNeverEdited) {
      return null;
    }

    if (_messageBody.isEmpty) {
      return _errorMessages['emptyBody'];
    }

    if (_messageBody.length < 3) {
      return _errorMessages['tooShortBody'];
    }

    return null;
  }

  void sendMessage() async {
    if (!areFormValuesOK()) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'createdAt': Timestamp.now(),
        'email': _email,
        'type': _subject,
        'body': _messageBody,
        'title': _messageTitle,
        'isRead': false,
        'isAnwswered': false,
      });

      setState(() {
        _isLoading = false;
        _isMessageSent = true;
      });
    } catch (error) {
      Utilities.logger.e(error);

      Utilities.snack.e(
        context: context,
        message: "message_send_error".tr(),
      );
    }
  }
}
