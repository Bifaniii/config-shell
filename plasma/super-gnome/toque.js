// Um toque no Super (rodado dentro do KWin pelo ~/.local/bin/super-gnome):
// se a grade de aplicativos estiver aberta, fecha; senão, abre/fecha a visão geral.
var grade = workspace.stackingOrder.some(function (w) {
    return w.resourceClass == "org.kde.plasmashell" && w.fullScreen;
});
if (grade)
    callDBus("org.kde.kglobalaccel", "/component/plasmashell", "org.kde.kglobalaccel.Component", "invokeShortcut", "activate application launcher");
else
    callDBus("org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component", "invokeShortcut", "Overview");
