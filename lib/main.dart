import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Metamask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientId: 'flutter_metamask',
    clientMeta: const PeerMeta(
      name: 'Flutter Metamask',
      description: 'Flutter Metamask',
      icons: ['https://example.com/icon.png'],
      url: 'https://walletconnect.org',
    ),
  );

  // ignore: prefer_typing_uninitialized_variables
  var _session, session;
  void connectWallet() async {
    if (!connector.connected) {
      try {
        session = await connector.createSession(
            chainId: 1,
            onDisplayUri: (uri) async {
              await launchUrlString(
                uri,
                mode: LaunchMode.externalApplication,
              );
            });
        setState(() {
          _session = session;
        });
      } catch (exp) {
        debugPrint("Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    connector.on(
        'connect',
        (session) => setState(
              () {
                debugPrint("Connected");
                _session = _session;
              },
            ));
    connector.on(
        'session_update',
        (payload) => setState(() {
              _session = payload;
            }));
    connector.on(
        'disconnect',
        (payload) => setState(() {
              debugPrint("disconnected");
              _session = null;
            }));
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: _session == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: connectWallet,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.purple[700]),
                        ),
                        child: const Text('Connect Wallet'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Wallet Address",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: session.accounts[0]),
                          );
                        },
                        child: Text(
                          session.accounts[0],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await connector.killSession();
                      //   },
                      //   child: const Text('Disconnect Wallet'),
                      // ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
