cmake_minimum_required(VERSION 3.7)
project(gka_calendar_qt)

set(CMAKE_CXX_STANDARD 14)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets WebEngine QuickControls2)

add_subdirectory(calendar-list)
add_subdirectory(qml)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
        Qt5::Gui
        Qt5::Quick
        Qt5::QuickControls2
        Qt5::Widgets
        Qt5::WebEngine
        ${CMAKE_DL_LIBS}
        )
