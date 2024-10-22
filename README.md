Dart port of [Kerberus](https://github.com/icure/kerberus)

## Features

- Resolve challenge
- Validate solution

## Getting started

```zsh
dart pub add kerberus
```

## Usage

```dart
// Challenge example, usually provided by the server
Challenge challenge = Challenge(
  id: uuid.v4(),
  salts: [uuid.v4(), uuid.v4()],
  difficultyFactor: 50000,
);

// Could be an API key
String input = 'JRTFM';

// Resolve the challenge on client side
Solution solution = await resolveChallenge(
    challenge,
    input,
);

// Validate the solution on server side
var success = await validateSolution(challenge, solution, input);

print('Success: $success');
```
