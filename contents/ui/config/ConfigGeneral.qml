import QtQuick 2.2
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

Item {
  property alias cfg_noteTextAreaColor: noteTextAreaColor.text
  property alias cfg_noteTextColor: noteTextColor.text
  property alias cfg_buttonsColor: buttonsColor.text
  // property alias cfg_noteTextFormat: noteTextFormat.currentValue
  property var selectedField: ''

  ColumnLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    RowLayout {
      x: parent.width
      Label {
        text: i18n('Background color of notes:')
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
      }
      TextField {
        id: noteTextAreaColor
        text: '#d5d5da'
        maximumLength: 7
        implicitWidth: 80
        horizontalAlignment: TextInput.AlignRight
      }
      Button {
        id: textAreaColorButton
        icon.name: "color-management"
        x: parent.width
        onClicked: chooseColor('area')
      }
    }

    RowLayout {
      Label {
        text: i18n('Foreground color of notes:')
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
      }
      TextField {
        id: noteTextColor
        text: '#2f343f'
        maximumLength: 7
        implicitWidth: 80
        horizontalAlignment: TextInput.AlignRight
      }
      Button {
        id: textColorButton
        icon.name: "color-management"
        x: parent.width
        onClicked: chooseColor('text')
      }
    }

    RowLayout {
      Label {
        text: i18n('Color of action buttons:')
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
      }
      TextField {
        id: buttonsColor
        text: '#2f343f'
        maximumLength: 7
        implicitWidth: 80
        horizontalAlignment: TextInput.AlignRight
      }
      Button {
        id: buttonsColorButton
        icon.name: "color-management"
        x: parent.width
        onClicked: chooseColor('buttons')
      }
    }

    /*RowLayout {
      Label {
        text: i18n('Text format:')
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
      }
      ComboBox {
        id: noteTextFormat
        editable: false
        x: parent.width
        textRole: 'key'
        valueRole: 'value'
        model: ListModel {
            ListElement {
              key: 'Plain Text'
              value: TextEdit.PlainText
            }
            ListElement {
              key: 'Rich Text'
              value: TextEdit.RichText
            }
            ListElement {
              key: 'Markdown'
              value: TextEdit.MarkdownText
            }
        }
        onActivated: {
          print("Selected: " + currentValue)
        }
      }
    }*/
  }

  ColorDialog {
    id: colorDialog
    title: i18n("Please choose a color")
    Component.onCompleted: visible = false
    onAccepted: putColorOnField()
    onRejected: Qt.quit()
  }

  //------------//
  // Functions //
  //-----------//
  function chooseColor(id) {
    selectedField = id
    colorDialog.open()
  }

  function putColorOnField() {
    // Could be a better way of sending ID or using some kind of elvis operator
    // but didn't found any, so this not so good function does the work properly
    if (selectedField == 'area') {
      noteTextAreaColor.text = colorDialog.color
      colorDialog.color = "#ffffff"
    } else if (selectedField == 'text') {
      noteTextColor.text = colorDialog.color
      colorDialog.color = "#ffffff"
    } else if (selectedField == 'buttons') {
      buttonsColor.text = colorDialog.color
      colorDialog.color = "#ffffff"
    }
  }
}
