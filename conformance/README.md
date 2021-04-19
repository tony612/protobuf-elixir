# Protobuf Conformance Tests

## Prerequisites

You'll need to compile the protobuf conformance test runner binary. The instructions can be found here:
https://github.com/protocolbuffers/protobuf/blob/master/conformance/README.md

## Running the tests

Once you've successfully compiled the runner, you can run the tests with the following command:

```sh
MIX_ENV=conformance mix protobuf.conformance --runner=$PATH_TO_RUNNER
```

You should expect to see an output similar to this:

```sh
CONFORMANCE TEST BEGIN ====================================

CONFORMANCE SUITE PASSED: 1179 successes, 705 skipped, 123 expected failures, 0 unexpected failures.


CONFORMANCE TEST BEGIN ====================================

CONFORMANCE SUITE PASSED: 0 successes, 69 skipped, 0 expected failures, 0 unexpected failures.
```

### Debugging a conformance test

Add `--verbose` to the above command to get detailed messages which can help aid in fixing
conformance issues.

## Exemptions

`conformance/protobuf/exemptions.txt` contains a list of tests that are currently failing conformance tests.
When fixing issues identified by the conformance test, please remove corresponding test lines from this file
to ensure test regressions do not occur.
