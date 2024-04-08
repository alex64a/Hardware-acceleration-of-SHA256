#include "sha256.hpp"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: sha256 <string>\n");
    return 0;
  }
  char *msg = argv[1];
  size_t len = strlen(msg);

  pad(msg, len);
  parse();

  hash();
  printHash();

  return 0;
}
