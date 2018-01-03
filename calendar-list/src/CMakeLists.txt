set(CMAKE_CXX_STANDARD 14)

find_package(ECM REQUIRED NO_MODULE)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets Organizer)

include_directories(
        ${QT5_INCLUDE_DIRS}
        ${Qt5Organizer_INCLUDE_DIRS}
)

add_library(CalendarListModelPlugin SHARED CalendarItem.cpp CalendarListModel.cpp YearItem.cpp YearGridModel.cpp CalendarListModelPlugin.cpp DayItem.cpp DayItem.h DayGridModel.cpp DayGridModel.h)

target_include_directories (CalendarListModelPlugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(CalendarListModelPlugin
        Qt5::Gui
        Qt5::Qml
        Qt5::Quick
        Qt5::Widgets
        Qt5::Organizer
        ${CMAKE_DL_LIBS}
        )

#install(TARGETS CalendarListModelPlugin LIBRARY DESTINATION ${KDE_INSTALL_QMLDIR}/CalendarListModel)
#install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/CalendarListModel)
install(TARGETS CalendarListModelPlugin LIBRARY DESTINATION /usr/lib/x86_64-linux-gnu/qt5/qml/CalendarListModel)
install(FILES qmldir DESTINATION /usr/lib/x86_64-linux-gnu/qt5/qml/CalendarListModel)
