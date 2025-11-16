#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <QtWidgets/QApplication>
#include <QtWidgets/QStyleFactory>

extern "C" int _ZN12QApplication4execEv() {
    if (qApp) {
        printf("--> theme_patch: Setting style to Fusion.\n");
        qApp->setStyle(QStyleFactory::create("Fusion"));
    }

    typedef int (*exec_func_t)();
    static exec_func_t real_exec = NULL;
    if (real_exec == NULL) {
        real_exec = (exec_func_t)dlsym(RTLD_NEXT, "_ZN12QApplication4execEv");
    }
    if (real_exec) { return real_exec(); }
    return -1;
}
