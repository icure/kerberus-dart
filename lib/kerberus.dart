library kerberus;

import 'package:kerberus/challenge.dart';
import 'package:kerberus/challenge_piece_resolver.dart';
import 'package:kerberus/proof_of_work.dart';
import 'package:kerberus/solution.dart';

Future<Solution> resolveChallenge(
  Challenge config,
  String serializedInput, {
  void Function(double)? onProgress,
}) async {
  List<ChallengePieceResolver> challenges = ChallengePieceResolver.forChallenge(
    config,
    serializedInput,
  );

  double lastSentProgress = 0.0;
  List<String> nonces = [];

  for (int index = 0; index < challenges.length; index++) {
    ChallengePieceResolver challenge = challenges[index];
    ProofOfWork proof = await challenge.resolve((double challengeProgress) {
      double progress = (index + challengeProgress) / challenges.length;
      if (progress - lastSentProgress > 0.01) {
        lastSentProgress = progress;
        if (onProgress != null) {
          onProgress(progress);
        }
      }
    });
    nonces.add(proof.nonce);
  }

  if (onProgress != null) {
    onProgress(1.0);
  }

  return Solution(
    id: config.id,
    nonces: nonces,
  );
}

Future<bool> validateSolution(
    Challenge config, Solution result, String serializedInput) async {
  List<ChallengePieceResolver> challenges = ChallengePieceResolver.forChallenge(
    config,
    serializedInput,
  );

  for (int index = 0; index < challenges.length; index++) {
    ChallengePieceResolver challenge = challenges[index];
    int nonce = int.parse(result.nonces[index]);
    bool isValid = await challenge.validate(nonce);
    if (!isValid) {
      return false;
    }
  }
  return true;
}
