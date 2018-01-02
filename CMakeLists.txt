cmake_minimum_required(VERSION 3.7)

project(gka-calendar-qt)

set (QT_MIN_VERSION "5.7.0")

find_package(ECM REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} "${CMAKE_SOURCE_DIR}/cmake")

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets QuickControls2 Organizer)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(ECMQueryQmake)
include(GenerateExportHeader)

add_subdirectory(calendar-list)
add_subdirectory(qml)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
        Qt5::Gui
        Qt5::Quick
        Qt5::QuickControls2
        Qt5::Widgets
        Qt5::Organizer
        ${CMAKE_DL_LIBS}
        )
