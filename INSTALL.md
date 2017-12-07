# GKA Calendar in QtQuick

Designed to work using Qt v5.7.1 as available on Debian 9

# Install prerequisites
```

sudo apt-get install qml-module-qtquick-controls2 
qml-module-qtquick-templates2 qtdeclarative5-dev qtquickcontrols2-5-dev 
qml-module-qtgraphicaleffects qml-module-qtqml-models2 
qml-module-qtquick-controls qml-module-qtquick-layouts 
qml-module-qtquick-window2 qml-module-qtquick2 qml-module-qtquick-dialogs
```

Need to build qt-organizer5-eds, which also requires qtpim, see:

https://github.com/adamboardman/qt-organizer5-eds


# Compile project

```
git clone https://github.com/adamboardman/gka-calendar-qt.git
cd gka-calendar-qt
mkdir build
cd build
cmake ..
make
sudo make install
```

