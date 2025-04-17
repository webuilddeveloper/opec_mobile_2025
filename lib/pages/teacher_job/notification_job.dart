import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationJobDrawer extends StatefulWidget {
  const NotificationJobDrawer({Key? key}) : super(key: key);

  @override
  State<NotificationJobDrawer> createState() => _NotificationJobDrawerState();
}

class _NotificationJobDrawerState extends State<NotificationJobDrawer> {
  final storage = FlutterSecureStorage();
  int _limit = 20;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void initState() {
    super.initState();
  }

  _callRead() async {
    var profileCode = await storage.read(key: 'profileCode25');
    return postDio('${server}m/teacherjob/applyWork/read', {
      'profileCode': profileCode,
      'skip': 0,
      'limit': _limit,
    });
  }

  _checkStatus(String status) {
    switch (status) {
      case 'N':
        return 'สมัครแล้ว';
      case 'P':
        return 'กําลังพิจารณา';
      case 'C':
        return 'ไม่ผ่านการพิจารณา';
      case 'A':
        return 'ผ่านการพิจารณา';
      default:
        return 'สมัครแล้ว';
    }
  }

  _onLoading() {
    setState(() {
      _limit += 10;
    });
    _callRead();

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            GestureDetector(
              onTap: () => _callRead(),
              child: Container(
                height: 50,
                width: 140,
                decoration: BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/images/bell_box_red.png'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'แจ้งเตือน',
                      style: TextStyle(
                        color: Color(0xFF9A1120),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Expanded(child: _futureListView()),
          ],
        ),
      ),
    );
  }

  _futureListView() {
    return FutureBuilder(
      future: _callRead(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as List;
          return SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView.separated(
              itemCount: data.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder:
                  (context, index) => Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        child: loadingImageNetwork(
                          data[index]['imageUrl'],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[index]['schoolName'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 23,
                              padding: EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                _checkStatus(data[index]['status']),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return Container(child: Text('ไม่พบงานที่สมัคร'));
        }
      },
    );
  }
}
