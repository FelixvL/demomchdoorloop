/*
 * Copyright (C) 2022  Felix
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * hellomch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4
import QtQuick.LocalStorage 2.7


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'hellomch.terence'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property string dbName: "ShoppingListDB"
    property string dbVersion: "1.0"
    property string dbDescription: "Database for shopping list app"
    property int dbEstimatedSize: 10000
    property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
    property string shoppingListTable: "ShoppingList"

    ListModel {
        id: shoppinglistModel
    }


    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('hellomch')

        }
        Component.onCompleted : {
            initializeShoppingList();
        }
        Label {
            id : labelone
            anchors {
                top: header.bottom
            }
           text: i18n.tr('Hello World')
          //  text: textfieldone.text

            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter

        }
        TextField{
            id : textfieldone
            anchors{
                top: labelone.bottom
                
            }
        }
        Button{
            id : buttonone
            text: 'ClickMe'
            anchors{
                top: labelone.bottom
                left: textfieldone.right
               // topMargin : units.gu(12)
            }
            onClicked: {
                console.log("dit is javascript");
                labelone.text = textfieldone.text
                shoppinglistModel.append({"name":textfieldone.text})
                addItem(textfieldone.text, false)
            }
        }

        ListView {
            id: shoppinglistView
            anchors {
                top: textfieldone.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                
            }
            model: shoppinglistModel

            delegate: ListItem {
                width: parent.width
                height: units.gu(3)
                Text {
                    text: name
                    color : UbuntuColors.orange
                   
                }
                color : UbuntuColors.red
            }

        }

    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('example', function() {
                console.log('module imported');
                python.call('example.speak', ['Hello World!'], function(returnValue) {
                    console.log('example.speak returned ' + returnValue);
                })
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
    function initializeShoppingList() {

        db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + shoppingListTable + ' (name TEXT, selected BOOLEAN)');
                var results = tx.executeSql('SELECT rowid, name, selected FROM ' + shoppingListTable);

                // Update ListModel
                for (var i = 0; i < results.rows.length; i++) {
                    shoppinglistModel.append({"rowid": results.rows.item(i).rowid,
                                                "name": results.rows.item(i).name,
                                                "price": 0,
                                                "selected": Boolean(results.rows.item(i).selected)
                                            });
                    getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
                }
            }
        )
    }
    function addItem(name, selected) {
        db.transaction(function(tx) {
                var result = tx.executeSql('INSERT INTO ' + shoppingListTable + ' (name, selected) VALUES( ?, ? )', [name, selected]);
                var rowid = Number(result.insertId);
                shoppinglistModel.append({"rowid": rowid, "name": name, "price": 0, "selected": selected});
                getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
            }
        )
    }
}
