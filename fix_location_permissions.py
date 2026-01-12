#!/usr/bin/env python3
"""
Script pour configurer les permissions de localisation via build settings
au lieu d'utiliser un fichier Info.plist
"""

import re

def configure_location_permissions_in_build_settings():
    pbxproj_path = 'Proximity/Proximity.xcodeproj/project.pbxproj'
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # 1. Réactiver GENERATE_INFOPLIST_FILE
    content = re.sub(
        r'GENERATE_INFOPLIST_FILE = NO;',
        'GENERATE_INFOPLIST_FILE = YES;',
        content
    )
    
    # 2. Supprimer INFOPLIST_FILE = Proximity/Info.plist;
    content = re.sub(
        r'\s*INFOPLIST_FILE = Proximity/Info\.plist;\n',
        '',
        content
    )
    
    # 3. Ajouter les clés de localisation directement dans les build settings
    # Chercher la section Debug (après ENABLE_PREVIEWS = YES;)
    debug_pattern = r'(ENABLE_PREVIEWS = YES;\n)'
    debug_addition = r'\1\t\t\t\tINFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "Proximity a besoin d\'accéder à votre position pour trouver les services à proximité de vous.";\n'
    
    content = re.sub(debug_pattern, debug_addition, content, count=1)
    
    # Faire la même chose pour Release (deuxième occurrence)
    lines = content.split('\n')
    enable_previews_count = 0
    for i, line in enumerate(lines):
        if 'ENABLE_PREVIEWS = YES;' in line:
            enable_previews_count += 1
            if enable_previews_count == 2:  # Deuxième occurrence (Release)
                lines.insert(i + 1, '\t\t\t\tINFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "Proximity a besoin d\'accéder à votre position pour trouver les services à proximité de vous.";')
                break
    
    content = '\n'.join(lines)
    
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Configuration des permissions de localisation")
    print("   - GENERATE_INFOPLIST_FILE = YES (réactivé)")
    print("   - INFOPLIST_FILE supprimé")
    print("   - NSLocationWhenInUseUsageDescription ajouté aux build settings")
    print("\nLe fichier Info.plist physique peut maintenant être supprimé.")
    return True

if __name__ == '__main__':
    configure_location_permissions_in_build_settings()
