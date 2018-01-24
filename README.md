# GKA Calendar in QtQuick

A simple calendar front end designed for landscape/desktop style devices, with full 
keyboard interaction. Borrows UI patterns from the old Agenda app on Psion devices.

See INSTALL.md for how to build.

## Keyboard navigation

### All views

* **Alt+F** open the file menu, use arrow keys to navigate or further Alt+Q etc to select other items
* **Ctrl+Q** quit the app
* **Ctrl+Shift+W** week view
* **Ctrl+Shift+D** day view
* **Ctrl+Shift+Y** year view
* **Ctrl+Shift+T** todo view

### Week view

* **Up** move back in time by one day, will change page at the top
* **Down** move forward in time by one day, will change page at the bottom
* **Left** move back in time by 3/4 days, will change the column or page as appropriate
* **Right** move forwards in time by 3/4 days, will change the column or page as appropriate
* **Space** jump to today
* **Enter** edit selected entry, or create new entry
* **Delete** delete selected entry

### Day view

* **Arrow keys** Move round the view
* **Space** jump to today
* **Enter** edit selected entry, or create new entry

### Year view

* **Arrow keys** Move round the view
* **Space** jump to today
* **Enter** edit selected entry, or create new entry

### To-do/Memos view

* **Arrow keys** Move round the view

### New/Edit Event dialog

* **Tab/Arrow** the UI can be fully navigated by combining the tab and arrow keys
