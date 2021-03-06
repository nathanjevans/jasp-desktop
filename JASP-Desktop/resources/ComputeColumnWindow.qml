import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "FilterConstructor"

FocusScope
{
	id: computedColumnContainer
	height: desiredMinimumHeight
	Layout.minimumHeight: desiredMinimumHeight

    visible: opened

	property bool	opened:						false
	property bool	changed:					computedColumnsInterface.computeColumnUsesRCode ? computeColumnEdit.changed : computedColumnConstructor.somethingChanged
	property bool	userLikesR:					computedColumnsInterface.computeColumnUsesRCode
	property bool	dataSetLoaded:				computedColumnsInterface.datasetLoaded
	property string jsonConstructedModel:		computedColumnsInterface.computeColumnJson
	property string computeColumnRCode:			computedColumnsInterface.computeColumnRCode
	property int	minimumHeightTextBoxes:		50
	property string selectedColumnNameMirror:	computedColumnsInterface.computeColumnNameSelected

	onDataSetLoadedChanged:				if(!dataSetLoaded) close();
	onSelectedColumnNameMirrorChanged:	if(selectedColumnNameMirror === "") close();
	onJsonConstructedModelChanged:		computedColumnConstructor.initializeFromJSON(userLikesR ? "{\"formulas\":[]}" : jsonConstructedModel);
	onComputeColumnRCodeChanged:		computeColumnEdit.text = computeColumnRCode;

	function close()
    {
		opened = false
		computedColumnsInterface.computeColumnNameSelected = ""
    }

	function open(columnName)
    {
		if(computedColumnsInterface.showAnalysisFormForColumn(columnName))
				close();
		else if(computedColumnsInterface.computeColumnNameSelected !== columnName)
		{
			opened = true


			height = desiredMinimumHeight * 2
			computedColumnsInterface.computeColumnNameSelected = columnName
			computeColumnEdit.text = computedColumnsInterface.computeColumnRCode

			if(!computedColumnContainer.userLikesR)
				computedColumnConstructor.initializeFromJSON(computedColumnContainer.jsonConstructedModel)

		}
    }

	function applyComputedColumn()
	{
		if(computedColumnsInterface.computeColumnUsesRCode)
			computedColumnsInterface.sendCode(computeColumnEdit.text)
		else
		{
			computedColumnConstructor.checkAndApplyFilter()
			computedColumnsInterface.sendCode(computedColumnConstructor.rCode, computedColumnConstructor.jsonConstructed)
		}
	}

	function askIfChangedOrClose()
	{
		if(computedColumnContainer.changed)	saveDialog.open()
		else								close()
	}

	property real desiredMinimumHeight: computeColumnButtons.height + computeColumnErrorScroll.height + (computedColumnsInterface.computeColumnUsesRCode ? computeColumnEditRectangle.desiredMinimumHeight : computedColumnConstructor.desiredMinimumHeight) + computeColumnTitle.height



	Text
	{
		id: computeColumnTitle
		text: computedColumnsInterface.computeColumnNameSelected !== "" ? computedColumnsInterface.computeColumnNameSelected : "Select a column"
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter

		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: 20
		font.bold: true

	}

	Item
	{
		id: computeColumnCodeArea


		anchors.top: computeColumnTitle.bottom
		anchors.bottom: computeColumnErrorScroll.top
		anchors.left: parent.left
		anchors.right: parent.right


		Rectangle {
			id: computeColumnEditRectangle
			color: "white"

			border.width: 1
			border.color: "lightGrey"

			property real desiredMinimumHeight: computedColumnContainer.minimumHeightTextBoxes

			visible: computedColumnContainer.userLikesR

			anchors.fill: parent

			TextArea
			{
				id: computeColumnEdit

				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				height: contentHeight + 30
				selectByMouse: true
				onActiveFocusChanged: if(!activeFocus) deselect()

				property bool changedSinceLastApply: text !== computedColumnContainer.lastAppliedcomputeColumn

				font.family: "Courier"
				wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere

				property bool changed: text != computedColumnsInterface.computeColumnRCode
			}
		}

		ComputedColumnsConstructor
		{
			id: computedColumnConstructor
			anchors.fill: parent
			visible: !computedColumnContainer.userLikesR


			functionModel: ListModel
			{

				ListElement	{ type: "function";	functionName: "abs";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "absolute value" }
				ListElement	{ type: "function";	functionName: "sd";		functionParameters: "values";	functionParamTypes: "number";			toolTip: "standard deviation" }
				ListElement	{ type: "function";	functionName: "var";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "variance" }
				ListElement	{ type: "function";	functionName: "sum";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "summation" }
				ListElement	{ type: "function";	functionName: "prod";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "product of values" }

				ListElement	{ type: "function";	functionName: "min";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "returns minimum of values" }
				ListElement	{ type: "function";	functionName: "max";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "returns maximum of values" }
				ListElement	{ type: "function";	functionName: "mean";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "mean" }
				ListElement	{ type: "function";	functionName: "round";	functionParameters: "y,n";		functionParamTypes: "number,number";	toolTip: "rounds y to n decimals" }
				ListElement	{ type: "function";	functionName: "length";	functionParameters: "y";		functionParamTypes: "any";				toolTip: "returns number of elements in y" }
				ListElement	{ type: "function";	functionName: "median";	functionParameters: "values";	functionParamTypes: "number";			toolTip: "median" }

				ListElement	{ type: "separator" }
				ListElement	{ type: "function";	functionName: "cut";	functionParameters: "values,numBreaks";	functionParamTypes: "number,number";			toolTip: "break your data up in numBreaks levels" }

				ListElement	{ type: "separator" }
				ListElement	{ type: "function";	functionName: "rnorm";	functionParameters: "n,mean,sd";functionParamTypes: "number,number,number";	toolTip: "generates a Gaussian distribution of n elements with specified mean and standard deviation sd" }
				ListElement	{ type: "function";	functionName: "rexp";	functionParameters: "n,rate";	functionParamTypes: "number,number,number";	toolTip: "generates an exponential distribution of n elements with specified rate" }

				ListElement	{ type: "separator" }

				ListElement	{ type: "function";	functionName: "log";	functionParameters: "y";		functionParamTypes: "number";			toolTip: "natural logarithm" }
				ListElement	{ type: "function";	functionName: "log2";	functionParameters: "y";		functionParamTypes: "number";			toolTip: "base 2 logarithm" }
				ListElement	{ type: "function";	functionName: "log10";	functionParameters: "y";		functionParamTypes: "number";			toolTip: "base 10 logarithm" }
				ListElement	{ type: "function";	functionName: "logb";	functionParameters: "y,base";	functionParamTypes: "number";			toolTip: "logarithm of y in 'base'" }
				ListElement	{ type: "function";	functionName: "exp";	functionParameters: "y";		functionParamTypes: "number";			toolTip: "exponential" }

				//cut?
				//match?

			}
		}

	}

	ScrollView
	{
		id: computeColumnErrorScroll
		height: visible ? computedColumnContainer.minimumHeightTextBoxes : 0

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: computeColumnButtons.top

		visible: computeColumnError.text.length > 0

		TextArea
		{
			id: computeColumnError
			color: "red"
			readOnly: true
			text: computedColumnsInterface.computeColumnError

			selectByMouse: true
			onActiveFocusChanged: if(!activeFocus) deselect()

			font.family: "Courier"
			height: text.length === 0 ? 0 : computeColumnError.contentHeight
		}
	}

	Item
	{
		id: computeColumnButtons
		height: closeColumnEditorButton.height
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom


		FilterButton
		{
			id: removeColumnButton
			iconSource: "../icons/square_trashcan.png"
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.top: closeColumnEditorButton.top

			onClicked: computedColumnsInterface.removeColumn()

			width: visible ? implicitWidth : 0
			//visible: computeColumnEdit.text !== defaultcomputeColumn

			toolTip: "Remove computed column"
		}

		FilterButton
		{
			id: applycomputeColumn

			text: computeColumnEdit.changedSinceLastApply ? "Compute column" : "Column computed"
			disabled: !computeColumnEdit.changedSinceLastApply
			anchors.left: removeColumnButton.right
			anchors.right: helpButton.left
			anchors.bottom: parent.bottom
			anchors.top: closeColumnEditorButton.top

			onClicked: computedColumnContainer.applyComputedColumn()

			toolTip: computeColumnEdit.changedSinceLastApply ? "Click to compute column" : "Column (in line to be) computed"
		}

		FilterButton
		{
			id: helpButton
			iconSource: "qrc:/icons/QuestionMark.png"
			anchors.right: closeColumnEditorButton.left
			anchors.bottom: parent.bottom
			anchors.top: closeColumnEditorButton.top

			onClicked: mainWindow.showHelpFromQML("other/ComputedColumns");

			toolTip: "Open Documentation"
		}


		FilterButton
		{
			id: closeColumnEditorButton
			iconSource: "../images/cross.png"
			anchors.right: parent.right
			anchors.bottom: parent.bottom

			onClicked: computedColumnContainer.askIfChangedOrClose()

			toolTip: "Close computed column window"
		}		
	}

	Dialog
	{
		id: saveDialog

		x: (parent.width - width) / 2
		y: (parent.height - height) / 2

		modal: true
		title: "Computed Column Changed"

		footer: DialogButtonBox
		{
			Button
			{
				text: qsTr("Save")
				onClicked:
				{
					computedColumnContainer.applyComputedColumn()
					computedColumnContainer.close()
					saveDialog.close()
				}
			}

			Button
			{
				text: qsTr("Cancel")

				onClicked:
				{
					saveDialog.close()
				}

			}

			Button
			{
				text: qsTr("Discard")

				onClicked:
				{
					computedColumnContainer.close()
					saveDialog.close();
				}

			}
		}

		contentItem: Text
		{
			text: "There are unapplied changes to your computed column; what would you like to do?"
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere
		}
	}
}
