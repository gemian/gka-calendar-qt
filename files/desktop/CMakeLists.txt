configure_file(calendar.desktop.in calendar.desktop)

install(PROGRAMS ${CMAKE_BINARY_DIR}/files/desktop/calendar.desktop DESTINATION share/applications)

install(FILES gka-calendar-qt.svg DESTINATION share/icons/hicolor/scalable/apps)
