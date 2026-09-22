/*  Part of SWI-Prolog

    WASI (wasm32-wasi) specific runtime support.

    WASI has no timezone database; the wall clock is UTC.  wasi-libc
    hides tzset() and the POSIX timezone globals, but the engine (and
    library code) reference them, so define UTC-pinned versions here.

    All definitions are weak: newer wasi-libc versions implement some
    of these (e.g. chmod), and when libswipl.a is linked into a
    runtime with such a libc the real definition must win.
*/

#define WEAK __attribute__((weak))

#include <errno.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>

WEAK long timezone = 0;
WEAK int  daylight = 0;
WEAK char *tzname[2] = { "UTC", "UTC" };

WEAK void
tzset(void)
{
}

/* WASI has no processes.  The __unix__ code paths (shell/2, ...)
   compile against these and get a clean runtime error. */

WEAK pid_t
fork(void)
{ errno = ENOSYS;
  return (pid_t)-1;
}

WEAK int
execve(const char *path, char *const argv[], char *const envp[])
{ (void)path; (void)argv; (void)envp;
  errno = ENOSYS;
  return -1;
}

WEAK int
execl(const char *path, const char *arg, ...)
{ (void)path; (void)arg;
  errno = ENOSYS;
  return -1;
}

WEAK pid_t
wait(int *status)
{ (void)status;
  errno = ECHILD;
  return (pid_t)-1;
}

WEAK pid_t
waitpid(pid_t pid, int *status, int options)
{ (void)pid; (void)status; (void)options;
  errno = ECHILD;
  return (pid_t)-1;
}

/* WASI has no dup2(); wasi-libc declares it but (in current versions)
   does not define it.  Only used by set_system_IO/3. */

WEAK int
dup2(int oldfd, int newfd)
{ (void)oldfd; (void)newfd;
  errno = ENOSYS;
  return -1;
}

/* WASI has no file modes; pretend the requested mode is in effect. */

WEAK int
chmod(const char *path, mode_t mode)
{ (void)path; (void)mode;
  return 0;
}

WEAK mode_t
umask(mode_t mask)
{ (void)mask;
  return 0;
}
