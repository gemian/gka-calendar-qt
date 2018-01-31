set(CMAKE_CXX_STANDARD 14)

#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer -fsanitize=address -fconcepts")
#set(CMAKE_LINKER_FLAGS_DEBUG "${CMAKE_STATIC_LINKER_FLAGS_DEBUG} -fno-omit-frame-pointer -fsanitize=address -fconcepts")

find_package(ECM REQUIRED NO_MODULE)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets Organizer)

include_directories(
        ${QT5_INCLUDE_DIRS}
        ${Qt5Organizer_INCLUDE_DIRS}
)

add_library(calendar-list-plugin SHARED CalendarItem.cpp CalendarListModel.cpp YearItem.cpp YearGridModel.cpp CalendarListModelPlugin.cpp DayItem.cpp DayItem.h DayGridModel.cpp DayGridModel.h)

target_include_directories (calendar-list-plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(calendar-list-plugin
        Qt5::Gui
        Qt5::Qml
        Qt5::Quick
        Qt5::Widgets
        Qt5::Organizer
        ${CMAKE_DL_LIBS}
        )

install(TARGETS calendar-list-plugin LIBRARY DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/CalendarListModel)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/CalendarListModel)
