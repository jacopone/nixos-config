/*
 * apply-seccomp.c - Apply seccomp BPF filter and exec command
 *
 * Two invocation forms are supported:
 *   1. apply-seccomp <filter.bpf> <command> [args...]
 *      Legacy / test form: BPF path passed explicitly as argv[1].
 *   2. apply-seccomp <command> [args...]
 *      Claude Code runtime form: BPF path baked in at compile time via
 *      -DBPF_PATH. Required because Claude Code's Zod schema strips
 *      sandbox.seccomp.bpfPath and the runtime invocation builder calls
 *      <applyPath> <command> with no BPF path in argv. See
 *      docs/plans/2026-05-18-sandbox-schema-finding.md
 *
 * If BPF_PATH is not defined at compile time, only form (1) is supported
 * (backward compatibility for callers that don't bake the path in).
 *
 * This program reads a pre-compiled BPF filter from a file, applies it
 * using prctl(PR_SET_SECCOMP), and then execs the specified command.
 *
 * The BPF filter must be in the format expected by SECCOMP_MODE_FILTER:
 * - struct sock_fprog { unsigned short len; struct sock_filter *filter; }
 * - Each filter instruction is 8 bytes (BPF instruction format)
 *
 * Compile: gcc -O2 -DBPF_PATH='"/path/to/unix-block.bpf"' \
 *              -o apply-seccomp apply-seccomp.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/prctl.h>
#include <linux/seccomp.h>
#include <linux/filter.h>
#include <errno.h>

#ifndef PR_SET_NO_NEW_PRIVS
#define PR_SET_NO_NEW_PRIVS 38
#endif

#ifndef SECCOMP_MODE_FILTER
#define SECCOMP_MODE_FILTER 2
#endif

#define MAX_FILTER_SIZE 4096  // Maximum BPF filter size in bytes

int main(int argc, char *argv[], char *envp[]) {
    const char *filter_path;
    char **command_argv;

    if (argc >= 3) {
        // Legacy form: explicit BPF path as argv[1].
        filter_path = argv[1];
        command_argv = &argv[2];
    } else if (argc == 2) {
#ifdef BPF_PATH
        // Claude Code runtime form: compile-time BPF path.
        filter_path = BPF_PATH;
        command_argv = &argv[1];
#else
        fprintf(stderr, "Usage: %s <filter.bpf> <command> [args...]\n", argv[0]);
        return 1;
#endif
    } else {
        fprintf(stderr, "Usage: %s [<filter.bpf>] <command> [args...]\n", argv[0]);
        return 1;
    }

    // Open and read BPF filter file
    int fd = open(filter_path, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open BPF filter file");
        return 1;
    }

    // Read filter into memory
    unsigned char filter_bytes[MAX_FILTER_SIZE];
    ssize_t filter_size = read(fd, filter_bytes, MAX_FILTER_SIZE);
    close(fd);

    if (filter_size < 0) {
        perror("Failed to read BPF filter");
        return 1;
    }
    if (filter_size == 0) {
        fprintf(stderr, "BPF filter file is empty\n");
        return 1;
    }
    if (filter_size % 8 != 0) {
        fprintf(stderr, "Invalid BPF filter size: %zd (must be multiple of 8)\n", filter_size);
        return 1;
    }

    // Convert bytes to sock_filter instructions
    unsigned short filter_len = filter_size / 8;
    struct sock_filter *filter = (struct sock_filter *)filter_bytes;

    // Set up sock_fprog structure
    struct sock_fprog prog = {
        .len = filter_len,
        .filter = filter,
    };

    // Set NO_NEW_PRIVS to allow seccomp without CAP_SYS_ADMIN
    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0) != 0) {
        perror("prctl(PR_SET_NO_NEW_PRIVS) failed");
        return 1;
    }

    // Apply seccomp filter
    if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &prog) != 0) {
        perror("prctl(PR_SET_SECCOMP) failed");
        return 1;
    }

    // Exec the command with seccomp filter active
    execvp(command_argv[0], command_argv);

    // If we get here, exec failed
    perror("execvp failed");
    return 1;
}
