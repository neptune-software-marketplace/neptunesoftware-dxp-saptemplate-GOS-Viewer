var dataArray;
var nativeDir;

function showAttachment() {

    // Set Directory
    switch (sap.ui.Device.os.name) {

        case 'Android':
            nativeDir = cordova.file.externalCacheDirectory;
            break;

        case 'iOS':
            nativeDir = cordova.file.tempDirectory;
            break;

        case 'winphone':
            nativeDir = cordova.file.externalCacheDirectory;
            break;

        default:
            nativeDir = cordova.file.tempDirectory;
            break;
    }

    // Create Array
    dataArray = makeBinary(modelAttachment.oData.CONTENT);

    // Create and Display File
    window.resolveLocalFileSystemURL(nativeDir, function(dir) {
        dir.getFile(modelAttachment.oData.FILE_NAME, {
            create: true
        }, function(file) {
            writeFile(file);
        });
    });

    // Close Dialog
    setTimeout(function() {
        var parent = oShell.getParent();
        if (parent) {
            var dia = parent.getParent();

            if (dia) {
                dia.close();
            }
        }
    }, 3000);
}

function makeBinary(content) {
    var raw = window.atob(content);
    var rawLength = raw.length;
    var array = new Uint8Array(rawLength);
    for (i = 0; i < rawLength; i++) {
        array[i] = raw.charCodeAt(i);
    }
    return array;
}

function writeFile(file) {

    file.createWriter(function(fileWriter) {

        fileWriter.onwriteend = function(e) {
            cordova.plugins.fileOpener2.open(
                nativeDir + modelAttachment.oData.FILE_NAME, modelAttachment.oData.MIME_TYPE, {
                    error: function(e) {
                        console.log('Error open: ' + e.status + ' - Error message: ' + e.message);
                    }
                }
            );
        };

        fileWriter.onerror = function(e) {
            console.log('WRITE ERROR is');
            console.log(e);
        };

        var blob = new Blob([dataArray]);
        fileWriter.write(blob);

    }, writeFail);
}

function writeFail(e) {
    console.log('Error write: ' + e.status + ' - Error message: ' + e.message);
}
