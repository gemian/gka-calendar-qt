file(GLOB JS_FILES *.js)
file(GLOB QML_FILES *.qml)

foreach(JS_FILE ${JS_FILES})
	configure_file(${JS_FILE} ${JS_FILE} COPYONLY)
	install(FILES ${JS_FILE} DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/calendar-qt)
endforeach(JS_FILE)

foreach(QML_FILE ${QML_FILES})
	configure_file(${QML_FILE} ${QML_FILE} COPYONLY)
	install(FILES ${QML_FILE} DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/calendar-qt)
endforeach(QML_FILE)

