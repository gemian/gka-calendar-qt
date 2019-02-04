include_directories(
        ${QT5_INCLUDE_DIRS}
        ${Qt5Organizer_INCLUDE_DIRS}
        ${gtest_SOURCE_DIR}/include
        ${gtest_SOURCE_DIR}
)

add_executable(runBasicTests test_main.cpp year_grid_test.cpp day_grid_test.cpp week_grid_test.cpp)

target_link_libraries(runBasicTests
        calendar-list-plugin
        Qt5::Qml
        Qt5::Quick
        ${CMAKE_DL_LIBS})
