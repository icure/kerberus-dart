import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:kerberus/challenge.dart';
import 'package:kerberus/proof_of_work.dart';

class ChallengePieceResolver {
  final String _salt;
  final String _serializedInput;
  final int _difficultyFactor;

  ChallengePieceResolver(this._salt, this._serializedInput, this._difficultyFactor);

  static final BigInt _maxUint128 = (BigInt.one << 128) - BigInt.one;

  static List<ChallengePieceResolver> forChallenge(
      Challenge config,
      String serializedInput,
      ) {
    return config.salts.map((salt) {
      return ChallengePieceResolver(
        salt,
        serializedInput,
        config.difficultyFactor,
      );
    }).toList();
  }

  Uint8List get prefix => Uint8List.fromList(_salt.codeUnits + _serializedInput.codeUnits);

  BigInt get difficulty {
    final maxValue = _maxUint128;
    return maxValue - (maxValue ~/ BigInt.from(_difficultyFactor));
  }

  BigInt _firstBytesAsBigInt(Uint8List bytes) {
    final first16Bytes = bytes.sublist(0, 16);
    return _bytesToBigInt(first16Bytes);
  }

  Future<Uint8List> _sha256(Uint8List input) async {
    final hash = crypto.sha256.convert(input);
    return Uint8List.fromList(hash.bytes);
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  Future<BigInt> _score(Uint8List prefixHash, int nonce) async {
    final nonceBytes = utf8.encode(nonce.toString());
    final hashInput = Uint8List.fromList(prefixHash + nonceBytes);
    final hash = await _sha256(hashInput);
    return _firstBytesAsBigInt(hash);
  }

  Future<BigInt> _calculate(int nonce) async {
    final prefixHash = await _sha256(prefix);
    return await _score(prefixHash, nonce);
  }

  Future<ProofOfWork> resolve(Function(double) onProgress) async {
    final prefixHash = await _sha256(prefix);

    double probabilityOfNotSuccessOnEachNonce = difficulty / _maxUint128;
    double progressAccumulator = 1.0;

    int nonce = 0;
    BigInt result = BigInt.zero;
    while (result < difficulty) {
      nonce += 1;
      result = await _score(prefixHash, nonce);

      progressAccumulator *= probabilityOfNotSuccessOnEachNonce;
      onProgress(1 - progressAccumulator);
    }
    return ProofOfWork(
      nonce: nonce.toString(),
    );
  }

  Future<bool> validate(int nonce) async {
    final calculatedResult = await _calculate(nonce);
    return calculatedResult >= difficulty;
  }
}