#define _GNU_SOURCE
#include <dlfcn.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h> // <-- Make sure to include this for printf

static int (*real_chdir)(const char *path) = NULL;

int chdir(const char *path) {
  // Print the path that was passed to the function
  if (path) {
    printf("--> chdir_wrapper: Intercepted path: \"%s\"\n", path);
  } else {
    printf("--> chdir_wrapper: Intercepted NULL path\n");
  }

  // Find the real chdir function if we haven't already
  if (real_chdir == NULL) {
    real_chdir = dlsym(RTLD_NEXT, "chdir");
  }

  // The logic to block the problematic call
  if (path && strstr(path, "/nix/store")) {
    printf("--> chdir_wrapper: Blocking this call.\n");
    return 0; // Success! (but we did nothing)
  }

  // For all other calls, pass them through to the real chdir
  printf("--> chdir_wrapper: Allowing this call.\n");
  return real_chdir(path);
}
