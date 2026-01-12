# Installation de l'Icône Proximity

## 📱 Icône Créée

L'icône est disponible dans le fichier `AppIcon.png` à la racine du projet.

**Design** :
- 📍 Marqueur de localisation central
- 🔵 Cercles concentriques (proximité)
- 🎨 Dégradé bleu-violet moderne
- ✨ Style minimaliste iOS

## 🚀 Installation Rapide

### Étape 1 : Générer Toutes les Tailles

1. Aller sur **https://appicon.co**
2. Upload le fichier `AppIcon.png`
3. Télécharger le pack iOS généré
4. Décompresser le fichier ZIP

### Étape 2 : Ajouter dans Xcode

**Sur macOS** :

1. Ouvrir le projet :
   ```bash
   cd Proximity
   open Proximity.xcodeproj
   ```

2. Dans le **Project Navigator** (panneau gauche) :
   - Ouvrir `Proximity` → `Assets.xcassets`
   - Cliquer sur `AppIcon`

3. **Glisser-déposer** les images du pack dans les emplacements correspondants

4. **Compiler** : `Cmd + B`

5. **Lancer** : `Cmd + R`

## ✅ Vérification

L'icône devrait apparaître :
- ✅ Sur l'écran d'accueil du simulateur
- ✅ Dans le dock
- ✅ Dans les réglages

## 📏 Tailles Requises

| Usage | Taille | Fichier |
|-------|--------|---------|
| iPhone App | 60pt | 120x120@2x, 180x180@3x |
| iPhone Spotlight | 40pt | 80x80@2x, 120x120@3x |
| iPhone Settings | 29pt | 58x58@2x, 87x87@3x |
| iPad App | 76pt | 76x76@1x, 152x152@2x |
| iPad Pro | 83.5pt | 167x167@2x |
| **App Store** | 1024pt | **1024x1024@1x** |

Le générateur appicon.co créera automatiquement toutes ces tailles.

## 🎨 Personnalisation

Si vous souhaitez modifier l'icône, je peux générer une nouvelle version avec :
- Couleurs différentes
- Style différent
- Éléments additionnels

Dites-moi simplement ce que vous voulez changer !
