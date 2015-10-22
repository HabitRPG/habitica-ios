#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

function login(username) {
    target.delay(1);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].setValue(username);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[1].secureTextFields()[0].secureTextFields()[0].setValue("t");
    target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tapWithOptions({tapOffset:{x:0.30, y:0.55}});
    target.delay(5);
}

function logout() {
    target.frontMostApp().tabBar().buttons()[4].tap();
    target.frontMostApp().tabBar().buttons()[4].tap();
    target.frontMostApp().mainWindow().tableViews()[0].cells()[9].scrollToVisible();
    target.delay(2);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[9].tap();
    target.delay(3);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
}

function logoutlogin(username) {
        target.delay(3);
    login(username);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[3].tap();
    target.delay(6);
    target.frontMostApp().tabBar().buttons()[4].tap();
    target.delay(2);
    target.frontMostApp().mainWindow().tableViews()[0].cells()[0].scrollToVisible();
    target.delay(2);
}


target.delay(3);
login("carrie");
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
target.frontMostApp().tabBar().buttons()[1].tap();
target.delay(2);
captureLocalizedScreenshot("0-Dailies");

logoutlogin("aiden");
target.frontMostApp().tabBar().buttons()[2].tap();
target.delay(3);
captureLocalizedScreenshot("1-Levelup");
target.frontMostApp().tapWithOptions({tapOffset:{x:0.1, y:0.1}});
target.frontMostApp().tabBar().buttons()[4].tap();

logoutlogin("layla");
target.frontMostApp().mainWindow().tableViews()[0].cells()[6].scrollToVisible();
target.frontMostApp().mainWindow().tableViews()[0].cells()[6].tap();
target.delay(2);
captureLocalizedScreenshot("2-Pets");
target.frontMostApp().tabBar().buttons()[4].tap();

logoutlogin("maria");
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.delay(2);
captureLocalizedScreenshot("3-Party Members");

target.frontMostApp().tabBar().buttons()[4].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.delay(2);
captureLocalizedScreenshot("4-Quest Details");
target.frontMostApp().tabBar().buttons()[4].tap();

