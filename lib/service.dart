import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:http/http.dart' as http;

class SmallCaseService {
  final client = http.Client();
  String ipAddress = "";

  SmallCaseService() {
    ScgatewayFlutterPlugin.setConfigEnvironment(
        GatewayEnvironment.PRODUCTION, "gateway", true, []).then((value) {
      print(value);

      String authToken;
      getAuthToken().then((value) {
        authToken = value;
        ScgatewayFlutterPlugin.initGateway(authToken).then((value) {
          print("Init gateway complete: $value");
        });
      });
    });
  }

// Get AuthToken from Backend
  Future<String> getAuthToken() async {
    String authToken = "";
    Uri url = Uri.parse("http://$ipAddress:3500/jwt");
    http.Response response;
    try {
      response =
          await client.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        authToken = response.body;
      }
    } catch (err) {
      print("Error in get AuthToken: $err");
    }
    return authToken;
  }

  Future<String> getTransactionId() async {
    String transactionId = "";
    Uri url = Uri.parse("http://$ipAddress:3500/transaction");
    http.Response response;
    try {
      response =
          await client.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        transactionId = response.body;
      }
    } catch (err) {
      print("Error in get transactionId: $err");
    }
    return transactionId;
  }

// Will give fail for guest user
  void fetchHoldings() async {
    print("Inside Fetch Holdings");
    String authToken = await getAuthToken();
    print(authToken);
    String apiSecret = "";

    Uri url = Uri.parse(
        "https://gatewayapi.smallcase.com/v1/itribe/engine/user/holdings");
    http.Response response;
    try {
      response = await client.get(url, headers: {
        "Content-Type": "application/json",
        "x-gateway-secret": apiSecret,
        "x-gateway-authtoken": authToken,
      });

      if (response.statusCode == 200) {
        print("Holdings Success!!!!!!!!!!");
        print(response.body);
      }
    } catch (err) {
      print("Error in fetching Holdings: $err");
    }
  }

// Get transactionId from our server to smallcase server call
  void startTransaction(String transactionId) async {
    print("Inside startTransaction");
    transactionId = await getTransactionId(); // stock
    String? res =
        await ScgatewayFlutterPlugin.triggerGatewayTransaction(transactionId);
    print("Res for start Transaction");
    print(res);
  }

// Non-transactional flows

  void brokerAccountOpening(
      String name, String email, String contact, String pincode) {
    ScgatewayFlutterPlugin.leadGen(name, email, contact, pincode);
  }

  void logout() {
    ScgatewayFlutterPlugin.logoutUser();
  }
}
