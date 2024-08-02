#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/wait.h>
#include <dlfcn.h>

extern char prompt[];
extern char path[];

int main() {
    char input[256];
    char *argv[64];
    char *token;
    int i;

    // Setting PATH
    if (setenv("PATH", path, 1) == -1) {
        fprintf(stderr, "PATH Error: %s\n", strerror(errno));
        return 1;
    }

    // Command line loop
    while (1) {
        printf("%s", prompt);
        if (fgets(input, sizeof(input), stdin) == NULL) {
            fprintf(stderr, "I/O Error: %s\n", strerror(errno));
            break;
        }
        input[strcspn(input, "\n")] = '\0';

        // Commands
        if (strlen(input) == 0) {
            continue;
        }

        if (strcmp(input, "exit") == 0) {
            break;
        }

        i = 0;
        token = strtok(input, " ");
        while (token != NULL && i < 63) {
            argv[i++] = token;
            token = strtok(NULL, " ");
        }
        argv[i] = NULL;

        // Calling dynamic modules from lib/
        if (i > 0 && strcmp(argv[0], "call") == 0 && i > 1) {
            char libpath[256];
            snprintf(libpath, sizeof(libpath), "./lib/lib%s.so", argv[1]);
            void *handle = dlopen(libpath, RTLD_LAZY);
            if (!handle) {
                fprintf(stderr, "LIB Error: %s: %s\n", libpath, dlerror());
                continue;
            }

            // Finding function
            void (*func)(const char *) = (void (*)(const char *)) dlsym(handle, argv[1]);
            char *error = dlerror();
            if (error != NULL) {
                fprintf(stderr, "FNC Error: %s: %s\n", argv[1], error);
                dlclose(handle);
                continue;
            }

            // Calling function
            func((argv[2] != NULL) ? argv[2] : "");
            dlclose(handle);
        } else {
            // Exec binary from PATH
            pid_t pid = fork();
            switch (pid) {
                case -1:
                    fprintf(stderr, "FORK Error: %s\n", strerror(errno));
                    break;
                case 0:
                    if (execvp(argv[0], argv) == -1) {
                        fprintf(stderr, "EXEC Error: '%s': %s\n", argv[0], strerror(errno));
                        exit(1);
                    }
                    break;
                default:
                    {
                        int status;
                        waitpid(pid, &status, 0);
                    }
                    break;
            }
        }
    }
    return 0;
}
