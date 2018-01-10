# GKA Calendar in QtQuick

Designed to work using Qt v5.7.1 as available on Debian 9

# Install prerequisites

Add the Gemini Keyboard Apps repository then:
```
sudo apt-get install qml-module-qtquick-controls2  extra-cmake-modules
qml-module-qtquick-templates2 qtdeclarative5-dev qtquickcontrols2-5-dev 
qml-module-qtgraphicaleffects qml-module-qtqml-models2 
qml-module-qtquick-controls qml-module-qtquick-layouts 
qml-module-qtquick-window2 qml-module-qtquick2 qml-module-qtquick-dialogs 
qtpim-dev qtorganizer5-eds qml-module-qtorganizer
```

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


