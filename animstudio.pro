######################################################################
# Automatically generated by qmake (3.0) Fri May 24 19:47:31 2013
######################################################################

TEMPLATE = app
TARGET = animstudio
INCLUDEPATH += .
QT += quick qml widgets gui-private
QMAKE_INFO_PLIST = Info.plist
osx: LIBS += -framework WebKit -framework Cocoa

HEADERS += fileio.h \
    webview.h
SOURCES += fileio.cpp main.cpp
OBJECTIVE_SOURCES += \
    webview.mm

OTHER_FILES += qml/*.qml \
    TODO.txt \
    qml/MultiTouchButton.qml \
    qml/ControlPanelSubMenu.qml \
    qml/ControlPanel.qml \
    qml/RecordButton.qml \
    qml/MenuButton.qml \
    qml/RadioButtonGroup.qml \
    qml/PlayMenu.qml \
    qml/PlayMenuRow.qml \
    qml/ProxyButton.qml

qml.files = $$PWD/qml
osx: qml.path = ./Contents/Resources
dummy.files = $$PWD/dummy.jpeg
osx: dummy.path = ./Contents/Resources
QMAKE_BUNDLE_DATA += qml dummy
