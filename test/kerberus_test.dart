import 'package:flutter_test/flutter_test.dart';
import 'package:kerberus/challenge.dart';

import 'package:kerberus/kerberus.dart';
import 'package:kerberus/solution.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('Simple PoW test', () async {
    const uuid = Uuid();

    Challenge challenge = Challenge(
      id: uuid.v4(),
      salts: [uuid.v4(), uuid.v4()],
      difficultyFactor: 50000,
    );

    String input = 'JRTFM';

    Solution solution = await resolveChallenge(
      challenge,
      input,
    );

    var success = await validateSolution(challenge, solution, input);

    expect(await validateSolution(challenge, solution, input), isTrue);

    print(challenge.salts);
    print(solution.nonces);
  });
}
