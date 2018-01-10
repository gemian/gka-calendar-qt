configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

include_directories(
        ${CMAKE_CURRENT_BINARY_DIR}
)

add_executable(${PROJECT_NAME_LOWER} main.cpp)

target_link_libraries(${PROJECT_NAME_LOWER}
        Qt5::Gui
        Qt5::Quick
        Qt5::QuickControls2
        Qt5::Widgets
        Qt5::Organizer
        ${CMAKE_DL_LIBS}
        )

install(TARGETS ${PROJECT_NAME_LOWER} RUNTIME DESTINATION bin)