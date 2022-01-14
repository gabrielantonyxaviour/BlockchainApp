import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlockChainApp(),
    );
  }
}

class BlockChainApp extends StatefulWidget {
  //const MyApp({Key? key}) : super(key: key);
  @override
  _BlockChainAppState createState() => _BlockChainAppState();
}

class _BlockChainAppState extends State<BlockChainApp> {
  int balanceAmount = 0;

  int depositAmount = 0;

  int installment = 3;

  late Client httpClient;

  late Web3Client ethClient;

  String rpcUrl = 'http://10.0.2.2:7545';

  @override
  void initState() {
    balanceAmount = 3;
    initialSetup();
    super.initState();
  }

  Future<void> initialSetup() async {
    httpClient = Client();
    ethClient = Web3Client(rpcUrl, httpClient);

    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
  }

  String privateKey =
      '300306f484fb0097d8acbacfbaa9b697d19d9d0c80d251f545e049c66b35d0f1';
  late Credentials credentials;
  late EthereumAddress myAddress;

  Future<void> getCredentials() async {
    credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    myAddress = await credentials.extractAddress();
  }

  late String abi;
  late EthereumAddress contractAddress;

  Future<void> getDeployedContract() async {
    String abiString = await rootBundle.loadString('src/abis/Investment.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    contractAddress =
        EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
  }

  late DeployedContract contract;
  late ContractFunction getBalanceAmount,
      getDepositAmount,
      addDepositAmount,
      withdrawBalance;

  Future<void> getContractFunctions() async {
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "Investment"), contractAddress);

    getBalanceAmount = contract.function('getBalanceAmount');
    getDepositAmount = contract.function('getDepositAmount');
    addDepositAmount = contract.function('addDepositAmount');
    withdrawBalance = contract.function('withdrawBalance');
  }

  Future<List<dynamic>> readContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    var queryResult = await ethClient.call(
      contract: contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  Future<void> writeContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "BlockChain App",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Text(
                    "Balance Amount",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              Text(
                "Rs. $balanceAmount",
                style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              TextButton(
                  onPressed: () async {
                    var result = await readContract(getBalanceAmount, []);

                    balanceAmount = result.first?.toInt();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: 125,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 2)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.indigoAccent,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Refresh",
                          style: TextStyle(
                              color: Colors.indigoAccent,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Text(
                    "Deposit Amount",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              Text(
                "Rs. $depositAmount",
                style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              TextButton(
                  onPressed: () async {
                    var result = await readContract(getDepositAmount, []);

                    depositAmount = result.first?.toInt();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: 125,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 2)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.indigoAccent,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Refresh",
                          style: TextStyle(
                              color: Colors.indigoAccent,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )),
              Expanded(child: Container()),
              TextButton(
                  onPressed: () async {
                    await writeContract(
                        addDepositAmount, [BigInt.from(installment)]);
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Colors.green[100],
                          size: 20,
                        ),
                        Expanded(
                          child: Text(
                            "Deposit Rs. 3",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.green[100],
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 2)),
                  )),
              TextButton(
                  onPressed: () async {
                    await writeContract(withdrawBalance, []);
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_circle,
                          color: Colors.red[100],
                          size: 20,
                        ),
                        Expanded(
                          child: Text(
                            "Withdraw Balance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red[100],
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 2)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
