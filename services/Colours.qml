pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Caelestia
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool showPreview
    property string scheme
    property string flavour
    readonly property bool light: showPreview ? previewLight : currentLight
    property bool currentLight
    property bool previewLight
    readonly property M3Palette palette: showPreview ? preview : current
    readonly property M3TPalette tPalette: M3TPalette {}
    readonly property M3Palette current: M3Palette {}
    readonly property M3Palette preview: M3Palette {}
    readonly property Transparency transparency: Transparency {}
    property real wallLuminance

    function getLuminance(c: color): real {
        if (c.r == 0 && c.g == 0 && c.b == 0)
            return 0;
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2));
    }

    function alterColour(c: color, a: real, layer: int): color {
        const luminance = getLuminance(c);

        const offset = (!light || layer == 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - transparency.base) * (1 + wallLuminance * (light ? (layer == 1 ? 3 : 1) : 2.5));
        const scale = (luminance + offset) / luminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));

        return Qt.rgba(r, g, b, a);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : alterColour(c, transparency.layers, layer ?? 1);
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    function load(data: string, isPreview: bool): void {
        const colours = isPreview ? preview : current;
        const scheme = JSON.parse(data);

        if (!isPreview) {
            root.scheme = scheme.name;
            flavour = scheme.flavour;
            currentLight = scheme.mode === "light";
        } else {
            previewLight = scheme.mode === "light";
        }

        for (const [name, colour] of Object.entries(scheme.colours)) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (colours.hasOwnProperty(propName))
                colours[propName] = `#${colour}`;
        }
    }

    function setMode(mode: string): void {
        Quickshell.execDetached(["caelestia", "scheme", "set", "--notify", "-m", mode]);
    }

    FileView {
        path: `${Paths.state}/scheme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text(), false)
    }

    Connections {
        target: Wallpapers

        function onCurrentChanged(): void {
            const current = Wallpapers.current;
            CUtils.getAverageLuminance(current, l => {
                if (Wallpapers.current == current)
                    root.wallLuminance = l;
            });
        }
    }

    component Transparency: QtObject {
        readonly property bool enabled: Appearance.transparency.enabled
        readonly property real base: Appearance.transparency.base - (root.light ? 0.1 : 0)
        readonly property real layers: Appearance.transparency.layers
    }

    component M3TPalette: QtObject {
        readonly property color m3primary_paletteKeyColor: root.layer(root.palette.m3primary_paletteKeyColor)
        readonly property color m3secondary_paletteKeyColor: root.layer(root.palette.m3secondary_paletteKeyColor)
        readonly property color m3tertiary_paletteKeyColor: root.layer(root.palette.m3tertiary_paletteKeyColor)
        readonly property color m3neutral_paletteKeyColor: root.layer(root.palette.m3neutral_paletteKeyColor)
        readonly property color m3neutral_variant_paletteKeyColor: root.layer(root.palette.m3neutral_variant_paletteKeyColor)
        readonly property color m3background: root.layer(root.palette.m3background, 0)
        readonly property color m3onBackground: root.layer(root.palette.m3onBackground)
        readonly property color m3surface: root.layer(root.palette.m3surface, 0)
        readonly property color m3surfaceDim: root.layer(root.palette.m3surfaceDim, 0)
        readonly property color m3surfaceBright: root.layer(root.palette.m3surfaceBright, 0)
        readonly property color m3surfaceContainerLowest: root.layer(root.palette.m3surfaceContainerLowest)
        readonly property color m3surfaceContainerLow: root.layer(root.palette.m3surfaceContainerLow)
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer)
        readonly property color m3surfaceContainerHigh: root.layer(root.palette.m3surfaceContainerHigh)
        readonly property color m3surfaceContainerHighest: root.layer(root.palette.m3surfaceContainerHighest)
        readonly property color m3onSurface: root.layer(root.palette.m3onSurface)
        readonly property color m3surfaceVariant: root.layer(root.palette.m3surfaceVariant, 0)
        readonly property color m3onSurfaceVariant: root.layer(root.palette.m3onSurfaceVariant)
        readonly property color m3inverseSurface: root.layer(root.palette.m3inverseSurface, 0)
        readonly property color m3inverseOnSurface: root.layer(root.palette.m3inverseOnSurface)
        readonly property color m3outline: root.layer(root.palette.m3outline)
        readonly property color m3outlineVariant: root.layer(root.palette.m3outlineVariant)
        readonly property color m3shadow: root.layer(root.palette.m3shadow)
        readonly property color m3scrim: root.layer(root.palette.m3scrim)
        readonly property color m3surfaceTint: root.layer(root.palette.m3surfaceTint)
        readonly property color m3primary: root.layer(root.palette.m3primary)
        readonly property color m3onPrimary: root.layer(root.palette.m3onPrimary)
        readonly property color m3primaryContainer: root.layer(root.palette.m3primaryContainer)
        readonly property color m3onPrimaryContainer: root.layer(root.palette.m3onPrimaryContainer)
        readonly property color m3inversePrimary: root.layer(root.palette.m3inversePrimary)
        readonly property color m3secondary: root.layer(root.palette.m3secondary)
        readonly property color m3onSecondary: root.layer(root.palette.m3onSecondary)
        readonly property color m3secondaryContainer: root.layer(root.palette.m3secondaryContainer)
        readonly property color m3onSecondaryContainer: root.layer(root.palette.m3onSecondaryContainer)
        readonly property color m3tertiary: root.layer(root.palette.m3tertiary)
        readonly property color m3onTertiary: root.layer(root.palette.m3onTertiary)
        readonly property color m3tertiaryContainer: root.layer(root.palette.m3tertiaryContainer)
        readonly property color m3onTertiaryContainer: root.layer(root.palette.m3onTertiaryContainer)
        readonly property color m3error: root.layer(root.palette.m3error)
        readonly property color m3onError: root.layer(root.palette.m3onError)
        readonly property color m3errorContainer: root.layer(root.palette.m3errorContainer)
        readonly property color m3onErrorContainer: root.layer(root.palette.m3onErrorContainer)
        readonly property color m3primaryFixed: root.layer(root.palette.m3primaryFixed)
        readonly property color m3primaryFixedDim: root.layer(root.palette.m3primaryFixedDim)
        readonly property color m3onPrimaryFixed: root.layer(root.palette.m3onPrimaryFixed)
        readonly property color m3onPrimaryFixedVariant: root.layer(root.palette.m3onPrimaryFixedVariant)
        readonly property color m3secondaryFixed: root.layer(root.palette.m3secondaryFixed)
        readonly property color m3secondaryFixedDim: root.layer(root.palette.m3secondaryFixedDim)
        readonly property color m3onSecondaryFixed: root.layer(root.palette.m3onSecondaryFixed)
        readonly property color m3onSecondaryFixedVariant: root.layer(root.palette.m3onSecondaryFixedVariant)
        readonly property color m3tertiaryFixed: root.layer(root.palette.m3tertiaryFixed)
        readonly property color m3tertiaryFixedDim: root.layer(root.palette.m3tertiaryFixedDim)
        readonly property color m3onTertiaryFixed: root.layer(root.palette.m3onTertiaryFixed)
        readonly property color m3onTertiaryFixedVariant: root.layer(root.palette.m3onTertiaryFixedVariant)
    }

    component M3Palette: QtObject {
        // Gruvbox Dark Medium colors
        property color m3primary_paletteKeyColor: "#d79921"  // gruvbox yellow
        property color m3secondary_paletteKeyColor: "#689d6a"  // gruvbox aqua
        property color m3tertiary_paletteKeyColor: "#d65d0e"  // gruvbox orange
        property color m3neutral_paletteKeyColor: "#928374"  // gruvbox gray
        property color m3neutral_variant_paletteKeyColor: "#a89984"  // gruvbox light gray
        property color m3background: "#282828"  // gruvbox dark0
        property color m3onBackground: "#ebdbb2"  // gruvbox light1
        property color m3surface: "#282828"  // gruvbox dark0
        property color m3surfaceDim: "#1d2021"  // gruvbox dark0_hard
        property color m3surfaceBright: "#3c3836"  // gruvbox dark1
        property color m3surfaceContainerLowest: "#1d2021"  // gruvbox dark0_hard
        property color m3surfaceContainerLow: "#32302f"  // gruvbox dark0_soft
        property color m3surfaceContainer: "#3c3836"  // gruvbox dark1
        property color m3surfaceContainerHigh: "#504945"  // gruvbox dark2
        property color m3surfaceContainerHighest: "#665c54"  // gruvbox dark3
        property color m3onSurface: "#ebdbb2"  // gruvbox light1
        property color m3surfaceVariant: "#504945"  // gruvbox dark2
        property color m3onSurfaceVariant: "#bdae93"  // gruvbox light2
        property color m3inverseSurface: "#ebdbb2"  // gruvbox light1
        property color m3inverseOnSurface: "#3c3836"  // gruvbox dark1
        property color m3outline: "#928374"  // gruvbox gray
        property color m3outlineVariant: "#504945"  // gruvbox dark2
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#d79921"  // gruvbox yellow
        property color m3primary: "#d79921"  // gruvbox yellow
        property color m3onPrimary: "#1d2021"  // gruvbox dark0_hard
        property color m3primaryContainer: "#b57614"  // gruvbox yellow dim
        property color m3onPrimaryContainer: "#fabd2f"  // gruvbox bright_yellow
        property color m3inversePrimary: "#b57614"  // gruvbox yellow dim
        property color m3secondary: "#8ec07c"  // gruvbox bright_green
        property color m3onSecondary: "#282828"  // gruvbox dark0
        property color m3secondaryContainer: "#689d6a"  // gruvbox aqua
        property color m3onSecondaryContainer: "#b8bb26"  // gruvbox bright_green
        property color m3tertiary: "#fe8019"  // gruvbox bright_orange
        property color m3onTertiary: "#1d2021"  // gruvbox dark0_hard
        property color m3tertiaryContainer: "#d65d0e"  // gruvbox orange
        property color m3onTertiaryContainer: "#1d2021"  // gruvbox dark0_hard
        property color m3error: "#fb4934"  // gruvbox bright_red
        property color m3onError: "#1d2021"  // gruvbox dark0_hard
        property color m3errorContainer: "#cc241d"  // gruvbox red
        property color m3onErrorContainer: "#fb4934"  // gruvbox bright_red
        property color m3primaryFixed: "#fabd2f"  // gruvbox bright_yellow
        property color m3primaryFixedDim: "#d79921"  // gruvbox yellow
        property color m3onPrimaryFixed: "#1d2021"  // gruvbox dark0_hard
        property color m3onPrimaryFixedVariant: "#b57614"  // gruvbox yellow dim
        property color m3secondaryFixed: "#b8bb26"  // gruvbox bright_green
        property color m3secondaryFixedDim: "#98971a"  // gruvbox green
        property color m3onSecondaryFixed: "#1d2021"  // gruvbox dark0_hard
        property color m3onSecondaryFixedVariant: "#689d6a"  // gruvbox aqua
        property color m3tertiaryFixed: "#fe8019"  // gruvbox bright_orange
        property color m3tertiaryFixedDim: "#d65d0e"  // gruvbox orange
        property color m3onTertiaryFixed: "#1d2021"  // gruvbox dark0_hard
        property color m3onTertiaryFixedVariant: "#af3a03"  // gruvbox orange dim
        property color term0: "#282828"   // gruvbox dark0
        property color term1: "#cc241d"   // gruvbox red
        property color term2: "#98971a"   // gruvbox green
        property color term3: "#d79921"   // gruvbox yellow
        property color term4: "#458588"   // gruvbox blue
        property color term5: "#b16286"   // gruvbox purple
        property color term6: "#689d6a"   // gruvbox aqua
        property color term7: "#a89984"   // gruvbox light gray
        property color term8: "#928374"   // gruvbox gray
        property color term9: "#fb4934"   // gruvbox bright_red
        property color term10: "#b8bb26"  // gruvbox bright_green
        property color term11: "#fabd2f"  // gruvbox bright_yellow
        property color term12: "#83a598"  // gruvbox bright_blue
        property color term13: "#d3869b"  // gruvbox bright_purple
        property color term14: "#8ec07c"  // gruvbox bright_aqua
        property color term15: "#ebdbb2"  // gruvbox light1
    }
}
