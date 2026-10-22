#include "my_application.h"
#include <gdk/gdk.h>

int main(int argc, char** argv) {
  // Configuración de backends de compatibilidad para evitar el fallo de schema
  // 'org.gnome.settings-daemon.plugins.xsettings' (antialiasing) en GNOME Wayland
  gdk_set_allowed_backends("x11,wayland,*");

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
