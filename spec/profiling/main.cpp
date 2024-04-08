#include "sha256.hpp"
#include <valgrind/callgrind.h>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: sha256 <string>\n");
    return 0;
  }
  char *msg = argv[1];
  size_t len = strlen(msg);

  pad(msg, len);

  CALLGRIND_START_INSTRUMENTATION;
  CALLGRIND_TOGGLE_COLLECT;

  parse();

  hash();

  CALLGRIND_TOGGLE_COLLECT;
  CALLGRIND_STOP_INSTRUMENTATION;
  printHash();

  return 0;
}
