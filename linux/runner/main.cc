#include "my_application.h"

#include <stdlib.h>

int main(int argc, char** argv) {
  // Prevenir crash de schema 'org.gnome.settings-daemon.plugins.xsettings'
  // (antialiasing) en sesiones modernas de GNOME Wayland
  setenv("GDK_BACKEND", "x11,wayland", 0);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
