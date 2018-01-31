include_directories(
        ${QT5_INCLUDE_DIRS}
        ${Qt5Organizer_INCLUDE_DIRS}
        ${gtest_SOURCE_DIR}/include
        ${gtest_SOURCE_DIR}
)

add_definitions(-DTEST_QML_DIR="${CMAKE_CURRENT_BINARY_DIR}/qml")

configure_file(src/RelativeTime.qml qml/RelativeTime.qml COPYONLY)

include(FindGettext)
set(DOMAIN relativeTime)
get_filename_component(LANG po/en_US.po NAME_WE)
gettext_process_po_files(${LANG} ALL PO_FILES po/en_US.po)
set(INSTALL_DIR ${CMAKE_INSTALL_LOCALEDIR}/${LANG}/LC_MESSAGES)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.gmo
        DESTINATION ${INSTALL_DIR}
        RENAME ${DOMAIN}.mo)

add_executable(relativetime src/tst_i18n_RelativeTime.cpp)

target_link_libraries(relativetime
        gka-toolkit-plugin
        Qt5::Qml
        Qt5::Quick
        Qt5::Test
        ${CMAKE_DL_LIBS})
