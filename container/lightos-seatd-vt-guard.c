#define _GNU_SOURCE
#include <errno.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/sysmacros.h>
#include <unistd.h>

/* LightOS owns VT allocation and switching. seatd may manage the mapped VT's
 * release/acquire handshake, but must never attach to another active VT. */
static int allocated_vt(int fd) {
  struct stat mapped, compatible, opened;
  if (stat("/dev/tty0", &mapped) != 0 ||
      stat("/dev/tty7", &compatible) != 0 || fstat(fd, &opened) != 0 ||
      !S_ISCHR(mapped.st_mode) || !S_ISCHR(compatible.st_mode) ||
      !S_ISCHR(opened.st_mode) || major(mapped.st_rdev) != 4 ||
      minor(mapped.st_rdev) < 7 || minor(mapped.st_rdev) > 63 ||
      mapped.st_rdev != compatible.st_rdev ||
      mapped.st_rdev != opened.st_rdev) {
    errno = EPERM;
    return -1;
  }
  return minor(mapped.st_rdev);
}

static int changes_terminal_mode(unsigned long request) {
  return request == VT_SETMODE || request == VT_RELDISP ||
         request == KDSETMODE || request == KDSKBMODE;
}

static void stop_without_vt_handoff(void) {
  static const char message[] =
    "LightOS seatd: terminal handoff failed; refusing hardware access\n";
  write(STDERR_FILENO, message, sizeof(message) - 1);
  _exit(1);
}

int ioctl(int fd, unsigned long request, ...) {
  va_list arguments;
  va_start(arguments, request);
  unsigned long argument = va_arg(arguments, unsigned long);
  va_end(arguments);

  int vt = -1;
  if ((request & 0xff00UL) == 0x5600UL ||
      request == KDSETMODE || request == KDSKBMODE) {
    /* No allocation, activation, or global switch locking from this daemon. */
    if ((request & 0xff00UL) == 0x5600UL &&
        request != VT_GETSTATE && request != VT_GETMODE &&
        request != VT_SETMODE && request != VT_RELDISP) {
      errno = EPERM;
      return -1;
    }
    vt = allocated_vt(fd);
    if (vt < 0) {
      if (changes_terminal_mode(request))
        stop_without_vt_handoff();
      return -1;
    }
  }

  int result = syscall(SYS_ioctl, fd, request, argument);
  /* Upstream seatd does not propagate terminal setup errors from vt_open.
   * Never acquire DRM/input after a failed release/acquire registration. */
  if (result < 0 && changes_terminal_mode(request))
    stop_without_vt_handoff();
  if (result >= 0 && request == VT_GETSTATE &&
      ((struct vt_stat *)argument)->v_active != vt) {
    /* VT_GETSTATE is global even through the bind-mounted /dev/tty0. A
     * compositor starting in the background must not claim that other VT. */
    errno = EBUSY;
    return -1;
  }
  return result;
}
