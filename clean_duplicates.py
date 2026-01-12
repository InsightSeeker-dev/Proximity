#!/usr/bin/env python3
"""
Script pour nettoyer les références dupliquées de Info.plist
"""

import re

def clean_infoplist_references():
    pbxproj_path = 'Proximity/Proximity.xcodeproj/project.pbxproj'
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Supprimer la référence manuelle de Info.plist (ligne 10)
    pattern = r'\s*D9104022CA98432884A76B89 /\* Info\.plist \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    # Supprimer toutes les autres références dupliquées de fichiers
    # (DataSourceError, LocationManager, ServicePointUI apparaissent 2 fois)
    
    # Supprimer les doublons de DataSourceError
    pattern = r'\s*BFAB473B11AE4578AA6E1C63 /\* DataSourceError\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    pattern = r'\s*EFD26C3097CB4F23B6AB64E9 /\* DataSourceError\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    # Supprimer les doublons de LocationManager
    pattern = r'\s*673BF3BCE1F045AA9E59CE0E /\* LocationManager\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    pattern = r'\s*A41F6972A9AC40FDBF663755 /\* LocationManager\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    # Supprimer les doublons de ServicePointUI
    pattern = r'\s*C5A113FEB6504805A4E5AA28 /\* ServicePointUI\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    pattern = r'\s*E4877EBBC7A140B58CC9EB60 /\* ServicePointUI\.swift \*/ = \{isa = PBXFileReference;[^}]+\};\n'
    content = re.sub(pattern, '', content)
    
    # Supprimer les références dans PBXSourcesBuildPhase
    sources_to_remove = [
        r'\s*9F1F164B533B4D569B40F0CE /\* ServicePointUI\.swift in Sources \*/,\n',
        r'\s*D11C43FF11E14720B2C42771 /\* LocationManager\.swift in Sources \*/,\n',
        r'\s*DF943CDAFD4541E6BAE4D266 /\* DataSourceError\.swift in Sources \*/,\n',
        r'\s*1FB6BFE1EC514FD7844E0048 /\* ServicePointUI\.swift in Sources \*/,\n',
        r'\s*036F38FC1FEE44A787773DFA /\* LocationManager\.swift in Sources \*/,\n',
        r'\s*0F67F9EEA8AD4ED5A8E626D6 /\* DataSourceError\.swift in Sources \*/,\n',
    ]
    
    for pattern in sources_to_remove:
        content = re.sub(pattern, '', content)
    
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Références dupliquées nettoyées")
    print("   - Info.plist retiré (sera auto-synchronisé)")
    print("   - Doublons de fichiers Swift retirés")
    print("\nLe projet utilise PBXFileSystemSynchronizedRootGroup")
    print("qui synchronise automatiquement tous les fichiers.")
    return True

if __name__ == '__main__':
    clean_infoplist_references()
