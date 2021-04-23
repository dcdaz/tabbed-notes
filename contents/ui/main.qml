import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 300
    height: 450

    PlasmaCore.DataSource {
        id: dataSource
        engine: 'executable'
        connectedSources:[]
        onNewData: loadData(data)
    }

    //--------------//
    // Tab Section //
    //-------------//
    TabBar {
      id: tabSection
      width: parent.width
    }

    Component {
      id: tabButton
      TabButton {}
    }

    //---------------//
    // Note Section //
    //--------------//
    StackLayout {
      id: noteSection
      anchors.fill: parent - tabSection.height
      width: root.width
      height: root.height - tabSection.height - buttonSection.height
      y: tabSection.height
      currentIndex: tabSection.currentIndex
    }

    Component {
      id: notePage
      ScrollView {
        width: root.width
        focus: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        TextArea {
          width: parent.width
          height: parent.height
          focus: true
          wrapMode: TextEdit.WordWrap
        }
      }
    }

    //-----------------//
    // Button Section //
    //----------------//
    RowLayout {
      id: buttonSection
      width: parent.width
      spacing: 2
      y: tabSection.height + noteSection.height
        Button {
          id: addTabButton
          icon.name: "add"
          flat: true
          onClicked: newTabNameDialog.open()
        }
        Button {
          id: removeTabButton
          icon.name: "remove"
          flat: true
          onClicked: removeTab()
        }
        Rectangle{
          anchors.fill: parent
          color: "transparent"
          // Some values for making separator the right size
          anchors.leftMargin: addTabButton.width + removeTabButton.width
          anchors.rightMargin: saveButton.width * 2
        }
        Button {
          id: saveButton
          icon.name: "dialog-ok"
          flat: true
          x: parent.width
          onClicked: saveData()
        }
    }

    //----------//
    // Dialogs //
    //---------//
    Dialog {
      id: errorPopup
      x: 0
      y: 150
      width: root.width
      height: 100
      modal: true
      focus: true
      closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    }

    Dialog {
      id: newTabNameDialog
      x: 0
      y: 150
      width: root.width
      height: 100
      title: "Insert Tab Name"
      modal: true
      focus: true
      closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
      standardButtons: Dialog.Ok

      TextInput {
        id: tabName
        width: parent.width/2
        wrapMode: TextInput.Wrap
        focus: true
        cursorVisible: true
      }

      onAccepted: checkTabNameAndAddIfNotExists()

      onRejected: {
        tabName.text = ""
      }
    }

    //---------------------------------//
    // Connection to Python "Backend" //
    //--------------------------------//
    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (plasmoid.expanded) {
              var url = Qt.resolvedUrl(".");
              var exec = url.substring(7, url.length);
              dataSource.connectedSources = ['python3 ' + exec + 'notes.py READ']
            }
            else {
                dataSource.connectedSources = [];
            }
        }
    }

    //------------//
    // Functions //
    //-----------//
    function checkTabNameAndAddIfNotExists() {
      var tabNameStr = tabName.text
      var currentTabNames = []
      for (var i = 0; i < tabSection.count; i++) {
        currentTabNames.push(tabSection.itemAt(i).text.toUpperCase())
      }
      tabName.text = ""
      if (currentTabNames.includes(tabNameStr.toUpperCase())) {
        errorPopup.title = 'Tab with name: \n\t' + tabNameStr + '\n\talready exists'
        errorPopup.open()
      } else {
        addTab(tabNameStr)
      }
    }

    function addTab(tabName, tabData) {
      var newTab = tabButton.createObject(tabSection, {text: tabName})
      var newView = notePage.createObject(noteSection, {})
      getTextAreaAttachedToTab(newView).text = tabData
      tabSection.addItem(newTab)
    }

    function removeTab() {
      var tabToBeRemoved = tabSection.itemAt(tabSection.currentIndex)
      tabSection.removeItem(tabToBeRemoved)
    }

    function saveData() {
      var url = Qt.resolvedUrl(".");
      var exec = url.substring(7, url.length);
      var notesDataStr = '"' + getTitleAndDataFromAllTabs() + '"'
      dataSource.connectedSources = ['python3 ' + exec + 'notes.py WRITE ' + notesDataStr]
    }

    function loadData(data) {
      var notesDataStr = data['stdout']
      if(notesDataStr.length) {
        try {
          var notesData = JSON.parse(notesDataStr)
          if (tabSection.count < 1) {
            Object.keys(notesData).forEach(keyName => {
              addTab(keyName, notesData[keyName])
            })
          }
        } catch (e) {
          print(e)
        }
      }
    }

    function getTextAreaAttachedToTab(tabObject) {
      // Nasty way of getting TextArea
      return tabObject.children[0].children[0].children[0]
    }

    function getTitleAndDataFromAllTabs() {
      const TITLE_TAG = '###'
      var notesDataStr = ''
      // Get titles and data and put it in a predefined format for notes file
      for (var i = 0; i < tabSection.count; i++) {
        var tab = noteSection.itemAt(i)
        notesDataStr += TITLE_TAG
        notesDataStr += ' '
        notesDataStr += tabSection.itemAt(i).text
        notesDataStr += '\n'
        var notePage = getTextAreaAttachedToTab(tab)
        notesDataStr += notePage.text
        if(!notesDataStr.endsWith('\n')) {
          notesDataStr += '\n'
        }
        notesDataStr += '\n'
      }
      return notesDataStr
    }
}
