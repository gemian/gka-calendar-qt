
set(CMAKE_CXX_STANDARD 14)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets Organizer)

include_directories(
        ${QT5_INCLUDE_DIRS}
        ${Qt5Organizer_INCLUDE_DIRS}
)

add_library(calendar_list CalendarItem.cpp CalendarListModel.cpp CalendarListModelPlugin.cpp)

target_include_directories (calendar_list PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(calendar_list
        Qt5::Gui
        Qt5::Quick
        Qt5::Widgets
        Qt5::Organizer
        ${CMAKE_DL_LIBS}
        )