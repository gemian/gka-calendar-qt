# GKA Calendar in QtQuick

Designed to work using Qt v5.7.1 as available on Debian 9

# Install prerequisites
```
sudo apt-get install libicu-dev qt5-default qml-module-qtquick-controls2 qml-module-qtquick-templates2
sudo apt-get build-dep qt5-default
```
qtpim required qtcore private headerfiles, you can either take the ones from handyfiles
```
sudo cp handyfiles/qfactoryloader_p.h /usr/include/x86_64-linux-gnu/qt5/QtCore/private
sudo cp handyfiles/qlibrary_p.h /usr/include/x86_64-linux-gnu/qt5/QtCore/private
```
Or pull out sources for qt:
```
git clone git://code.qt.io/qt/qt5.git
cd qt5
./init-repository

git checkout v5.7.1

sudo mkdir /usr/include/x86_64-linux-gnu/qt5/QtCore/private
sudo cp qt5/qtbase/src/corelib/plugin/qfactoryloader_p.h /usr/include/x86_64-linux-gnu/qt5/QtCore/private
sudo cp qt5/qtbase/src/corelib/plugin/qlibrary_p.h /usr/include/x86_64-linux-gnu/qt5/QtCore/private
```
You can now delete your the above qt sources.

Pull out sources for qtpim:
```
git clone git://code.qt.io/qt/qtpim.git
```
Switch out all qmlWarnings for older qmlInfo's, unless your system builds fine without doing so.
```
src/imports/contacts/qdeclarativecontactrelationship.cpp
src/imports/organizer/qdeclarativeorganizermodel.cpp
src/imports/organizer/qdeclarativeorganizerrecurrencerule.cpp
src/imports/contacts/qdeclarativecontactrelationshipmodel.cpp
src/imports/contacts/qdeclarativecontactrelationship.cpp
```
Build qtpim:
```
qmake qtpim.pro
make
sudo make install
```

You need to install the eds backend (or another backend used by your system). If you 
use another backend then update manager:"eds" to reference your chosen backend.

```
git clone https://github.com/adamboardman/qt-organizer5-eds.git
cd qt-organizer5-eds
mkdir build
cd build
cmake ..
make
sudo make install
```

