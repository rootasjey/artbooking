import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/types/globals/state.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends ConsumerStatefulWidget {
  final ScrollController? pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final WrapAlignment alignment =
        width < 700.0 ? WrapAlignment.spaceBetween : WrapAlignment.spaceAround;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 90.0,
      ),
      child: Wrap(
        runSpacing: 80.0,
        alignment: alignment,
        children: <Widget>[
          Divider(
            height: 20.0,
            thickness: 1.0,
            color: Colors.black38,
          ),
          copyright(),
          editorial(),
          user(),
          aboutUs(),
        ],
      ),
    );
  }

  Widget copyright() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(),
        companyName(),
        tos(),
        privacyPolicy(),
      ],
    );
  }

  Widget aboutUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(title: "about".tr().toUpperCase()),
        textLink(
          label: "about_us".tr(),
          onPressed: () {
            context.beamToNamed('/about');
          },
        ),
        textLink(
          label: "contact_us".tr(),
          onPressed: () {
            context.beamToNamed('/contact');
          },
        ),
        textLink(
          label: "GitHub",
          onPressed: () {
            launch('https://github.com/rootasjey/rootasjey.dev');
          },
        ),
      ],
    );
  }

  Widget editorial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(title: "editorial".tr().toUpperCase()),
        textLink(
          label: "illustrations".tr(),
          onPressed: () {
            // context.router.push(IllustrationsPageRoute());
          },
        ),
        // textLink(
        //   label: "books".tr(),
        //   onPressed: () {
        //     context.router.push(BooksPageRoute());
        //   },
        // ),
        // textLink(
        //   label: "challenges".tr(),
        //   onPressed: () {
        //     context.router.push(ChallengesPageRoute());
        //   },
        // ),
      ],
    );
  }

  Widget companyName() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        bottom: 8.0,
      ),
      child: Text.rich(TextSpan(
        children: [
          TextSpan(
            text: "rootasjey ${DateTime.now().year}",
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  UniconsLine.copyright,
                  size: 18.0,
                ),
              ),
            ),
          ),
          TextSpan(
            text: "\nby Jeremie Codes, SASU",
          ),
        ],
      )),
    );
  }

  Widget languages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleSection(title: "language".tr().toUpperCase()),
        textLink(
          label: 'English',
          onPressed: () async {
            await context.setLocale(Locale('en'));
          },
        ),
        textLink(
          label: 'Français',
          onPressed: () async {
            await context.setLocale(Locale('fr'));
          },
        ),
      ],
    );
  }

  Widget privacyPolicy() {
    return textLink(
      label: "privacy".tr(),
      onPressed: () {
        // context.router.push(TosPageRoute());
        context.beamToNamed('/tos');
      },
    );
  }

  Widget titleSection({required title}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        bottom: 8.0,
      ),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          title,
          style: FontsUtils.mainStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget textLink({
    VoidCallback? onPressed,
    String? heroTag,
    required String label,
  }) {
    final Widget text = Text(
      label,
      style: FontsUtils.mainStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );

    final Widget textContainer = heroTag != null
        ? Hero(
            tag: label,
            child: text,
          )
        : text;

    return TextButton(
      onPressed: onPressed,
      child: Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: textContainer,
        ),
      ),
      style: TextButton.styleFrom(
        primary: Theme.of(context).textTheme.bodyText1?.color,
      ),
    );
  }

  Widget tos() {
    return textLink(
      label: "tos".tr(),
      heroTag: "tos_hero",
      onPressed: () {
        // context.router.push(TosPageRoute());
        context.beamToNamed('/tos');
      },
    );
  }

  Widget user() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(title: "user".tr().toUpperCase()),
        textLink(
            label: "signin".tr(),
            onPressed: () {
              // context.router.push(SigninPageRoute());
              context.beamToNamed('/signin');
            }),
        textLink(
          label: "signup".tr(),
          onPressed: () {
            // context.router.push(SignupPageRoute());
            context.beamToNamed('/signout');
          },
        ),
        textLink(
          label: "settings".tr(),
          onPressed: () {
            if (ref.read(AppState.userProvider.notifier).isAuthenticated) {
              Beamer.of(context).beamToNamed(
                DashboardLocationContent.settingsRoute,
              );
              return;
            }

            Beamer.of(context).beamToNamed(SettingsLocation.route);
          },
        ),
      ],
    );
  }
}
