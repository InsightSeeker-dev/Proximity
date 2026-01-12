#!/usr/bin/env python3
"""
Script pour ajouter Info.plist au projet et configurer les permissions de localisation
"""

import re
import sys

def add_infoplist_to_project(pbxproj_path):
    """Ajoute Info.plist au projet et désactive la génération automatique"""
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # 1. Remplacer GENERATE_INFOPLIST_FILE = YES par NO
    content = re.sub(
        r'GENERATE_INFOPLIST_FILE = YES;',
        'GENERATE_INFOPLIST_FILE = NO;',
        content
    )
    
    # 2. Ajouter INFOPLIST_FILE = Proximity/Info.plist;
    # Trouver les sections de configuration et ajouter INFOPLIST_FILE
    pattern = r'(GENERATE_INFOPLIST_FILE = NO;)'
    replacement = r'\1\n\t\t\t\tINFOPLIST_FILE = Proximity/Info.plist;'
    
    content = re.sub(pattern, replacement, content)
    
    # Écrire le fichier modifié
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Configuration Info.plist mise à jour dans project.pbxproj")
    print("   - GENERATE_INFOPLIST_FILE = NO")
    print("   - INFOPLIST_FILE = Proximity/Info.plist")
    
    return True

def main():
    pbxproj_path = 'Proximity/Proximity.xcodeproj/project.pbxproj'
    
    print("=" * 60)
    print("Configuration des permissions de localisation")
    print("=" * 60)
    
    try:
        add_infoplist_to_project(pbxproj_path)
        print("\n✅ Configuration terminée avec succès!")
        print("\nProchaines étapes:")
        print("1. Compiler le projet sur macOS")
        print("2. L'app demandera les permissions de localisation")
        print("3. Autoriser l'accès à la localisation")
        return 0
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
