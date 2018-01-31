set(CMAKE_CXX_STANDARD 14)

#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer -fsanitize=address -fconcepts")
#set(CMAKE_LINKER_FLAGS_DEBUG "${CMAKE_STATIC_LINKER_FLAGS_DEBUG} -fno-omit-frame-pointer -fsanitize=address -fconcepts")

find_package(ECM REQUIRED NO_MODULE)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets DBus)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB_PKG glib-2.0)

include_directories(
        ${GLIB_PKG_INCLUDE_DIRS}
        ${QT5_INCLUDE_DIRS}
)

add_library(gka-toolkit-plugin SHARED i18n.cpp plugin.cpp listener.cpp livetimer.cpp livetimer_p.cpp)

target_include_directories (gka-toolkit-plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(gka-toolkit-plugin
        Qt5::Gui
        Qt5::Qml
        Qt5::Quick
        Qt5::Widgets
        Qt5::DBus
        ${CMAKE_DL_LIBS}
        )

install(TARGETS gka-toolkit-plugin LIBRARY DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/GKAToolkit)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/GKAToolkit)
