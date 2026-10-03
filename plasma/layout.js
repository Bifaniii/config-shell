// Layout do Plasma: barra preta em cima que se esconde (Atividades, relógio, monitores, bandeja)
// + dock flutuante embaixo que se esconde sozinha.
// Aplicar: qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat layout.js)"

panels().forEach(function (p) { p.remove(); });

// ---------- barra superior ----------
var topo = new Panel();
topo.location = "top";
topo.height = 32;
topo.floating = false;
topo.hiding = "autohide"; // some e desce ao encostar o mouse no topo, como a dock

// botão "Atividades" (widget próprio guilherme.atividades): 1 clique abre a Visão geral, como no GNOME
topo.addWidget("guilherme.atividades");

topo.addWidget("org.kde.plasma.panelspacer");

var relogio = topo.addWidget("org.kde.plasma.digitalclock");
relogio.currentConfigGroup = ["Appearance"];
relogio.writeConfig("showDate", true);
relogio.writeConfig("dateFormat", "custom");
relogio.writeConfig("customDateFormat", "ddd dd MMM");
relogio.writeConfig("dateDisplayFormat", "BesideTime");
relogio.writeConfig("use24hFormat", 2);
relogio.writeConfig("boldText", true);

topo.addWidget("org.kde.plasma.panelspacer");

var cpu = topo.addWidget("org.kde.plasma.systemmonitor.cpu");
cpu.currentConfigGroup = ["Appearance"];
cpu.writeConfig("chartFace", "org.kde.ksysguard.textonly");
var mem = topo.addWidget("org.kde.plasma.systemmonitor.memory");
mem.currentConfigGroup = ["Appearance"];
mem.writeConfig("chartFace", "org.kde.ksysguard.textonly");

topo.addWidget("org.kde.plasma.systemtray");

// ---------- dock flutuante embaixo ----------
var dock = new Panel();
dock.location = "bottom";
dock.height = 52;
dock.floating = true;
dock.lengthMode = "fit";
dock.alignment = "center";
dock.hiding = "autohide"; // some e volta ao encostar o mouse embaixo

// Launchpad (KDE Store, QML ajustado localmente): 1º item da dock; também 2 toques no Super, Meta+A, Alt+F1
var launchpad = dock.addWidget("adhe.launchpadPlasma");
launchpad.currentConfigGroup = ["General"];
launchpad.writeConfig("icon", "view-app-grid");
launchpad.writeConfig("alphaSort", true);
launchpad.writeConfig("showRecentApps", false);
launchpad.writeConfig("showRecentDocs", false);

var tarefas = dock.addWidget("org.kde.plasma.icontasks");
tarefas.currentConfigGroup = ["General"];
tarefas.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.gnome.Calculator.desktop",
    "applications:google-chrome.desktop",
    "applications:com.discordapp.Discord.desktop",
    "applications:com.anthropic.Claude.desktop",
    "applications:com.jetbrains.IntelliJ-IDEA-Community.desktop",
    "applications:postman.desktop",
    "applications:kitty.desktop",
    "applications:com.microsoft.VSCode.desktop",
    "applications:spotify.desktop"
].join(","));
tarefas.writeConfig("iconSpacing", 2);
tarefas.writeConfig("maxStripes", 1);
tarefas.writeConfig("showOnlyCurrentDesktop", false);
