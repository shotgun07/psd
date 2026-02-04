import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String _rpcUrl = 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY';
  final String _privateKey = 'YOUR_PRIVATE_KEY';
  final String _contractAddress = '0x...'; // Deployed contract address
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  // Simple Payment Contract ABI
  final String _contractAbi = '''
  [
    {
      "inputs": [
        {"internalType": "address payable", "name": "_to", "type": "address"},
        {"internalType": "uint256", "name": "_amount", "type": "uint256"}
      ],
      "name": "sendPayment",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getBalance",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';

  BlockchainService() {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
    _contract = DeployedContract(
      ContractAbi.fromJson(_contractAbi, 'PaymentContract'),
      EthereumAddress.fromHex(_contractAddress),
    );
  }

  Future<String> sendPayment(String toAddress, double amount) async {
    // Direct ETH transfer
    final transaction = Transaction(
      to: EthereumAddress.fromHex(toAddress),
      value: EtherAmount.fromBigInt(EtherUnit.ether, BigInt.from(amount * 1e18)),
    );

    final result = await _client.sendTransaction(_credentials, transaction);
    return result;
  }

  Future<String> sendContractPayment(String toAddress, double amount) async {
    // Contract-based payment
    final function = _contract.function('sendPayment');
    final transaction = Transaction.callContract(
      contract: _contract,
      function: function,
      parameters: [
        EthereumAddress.fromHex(toAddress),
        BigInt.from(amount * 1e18), // Convert to wei
      ],
      value: EtherAmount.fromBigInt(EtherUnit.ether, BigInt.from(amount)),
    );

    final result = await _client.sendTransaction(_credentials, transaction);
    return result;
  }

  Future<BigInt> getContractBalance() async {
    final function = _contract.function('getBalance');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );
    return result[0] as BigInt;
  }

  Future<String> deployPaymentContract() async {
    // Simple contract bytecode (this is just an example)
    // const contractBytecode = '0x608060405234801561001057600080fd5b50d3801561001d57600080fd5b50d2801561002a57600080fd5b5061012f806100396000396000f3fe6080604052600436106100415763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416633ccfd60b8114610046575b600080fd5b34801561005257600080fd5b5061005b61005d565b005b60008054600181019091909155604051918252519081900360200190a15056fe';

    final transaction = Transaction(
      data: Uint8List.fromList([]), // Empty data for contract creation
    );

    final result = await _client.sendTransaction(_credentials, transaction);
    return result;
  }
}
