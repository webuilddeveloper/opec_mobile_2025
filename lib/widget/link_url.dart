import 'package:url_launcher/url_launcher.dart';

launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}


launchInWebViewWithJavaScript(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView:
          false, //ถ้า true ไม่รองรับ Google Form https://forms.gle/AGfKZ87gAMbWmpxo6
      enableJavaScript: true,
    );
  } else {
    // print('errror');
    // throw 'Could not launch $url';
  }
}
