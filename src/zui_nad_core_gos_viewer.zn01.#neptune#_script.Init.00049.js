if (sap.n) {
    sap.n.Shell.attachBeforeDisplay(function(data, init) {
        if (sap.n.GOS) {
            getOnlineGetData(sap.n.GOS.INSTID_B);
        }
    });
}
