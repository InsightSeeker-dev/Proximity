#!/usr/bin/env python3
"""
Script pour ajouter Info.plist au projet Xcode
"""

import uuid
import re

def generate_uuid():
    """Génère un UUID de 24 caractères hexadécimaux (format Xcode)"""
    return uuid.uuid4().hex[:24].upper()

def add_infoplist_to_project():
    pbxproj_path = 'Proximity/Proximity.xcodeproj/project.pbxproj'
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Générer les UUIDs
    file_ref_uuid = generate_uuid()
    
    print(f"Ajout de Info.plist...")
    print(f"  File Reference UUID: {file_ref_uuid}")
    
    # 1. Ajouter la référence du fichier (PBXFileReference)
    file_ref_section_pattern = r'(/\* Begin PBXFileReference section \*/)'
    file_ref_entry = f'\t\t{file_ref_uuid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};\n'
    
    content = re.sub(
        file_ref_section_pattern,
        r'\1\n' + file_ref_entry,
        content
    )
    
    # 2. Ajouter au groupe Proximity (groupe principal)
    # Chercher le groupe Proximity
    group_pattern = r'(/\* Proximity \*/ = {[^}]+children = \()'
    group_entry = f'\n\t\t\t\t{file_ref_uuid} /* Info.plist */,'
    
    content = re.sub(
        group_pattern,
        r'\1' + group_entry,
        content
    )
    
    # Écrire le fichier modifié
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print(f"✅ Info.plist ajouté au projet!")
    return True

if __name__ == '__main__':
    add_infoplist_to_project()
