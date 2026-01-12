#!/usr/bin/env python3
"""
Script pour ajouter des fichiers Swift au projet Xcode
Modifie directement le fichier project.pbxproj
"""

import uuid
import re
import sys

def generate_uuid():
    """Génère un UUID de 24 caractères hexadécimaux (format Xcode)"""
    return uuid.uuid4().hex[:24].upper()

def add_file_to_project(pbxproj_path, file_path, group_name):
    """
    Ajoute un fichier Swift au projet Xcode
    
    Args:
        pbxproj_path: Chemin vers project.pbxproj
        file_path: Chemin relatif du fichier depuis le dossier du projet
        group_name: Nom du groupe Xcode où ajouter le fichier
    """
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Extraire le nom du fichier
    filename = file_path.split('/')[-1]
    
    # Générer les UUIDs nécessaires
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    print(f"Ajout de {filename}...")
    print(f"  File Reference UUID: {file_ref_uuid}")
    print(f"  Build File UUID: {build_file_uuid}")
    
    # 1. Ajouter la référence du fichier (PBXFileReference)
    # Trouver la section /* Begin PBXFileReference section */
    file_ref_section_pattern = r'(/\* Begin PBXFileReference section \*/)'
    file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
    
    content = re.sub(
        file_ref_section_pattern,
        r'\1\n' + file_ref_entry,
        content
    )
    
    # 2. Ajouter le fichier à la phase de compilation (PBXBuildFile)
    build_file_section_pattern = r'(/\* Begin PBXBuildFile section \*/)'
    build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
    
    content = re.sub(
        build_file_section_pattern,
        r'\1\n' + build_file_entry,
        content
    )
    
    # 3. Ajouter le fichier au groupe approprié (PBXGroup)
    # Chercher le groupe par son nom (commentaire)
    group_pattern = rf'(/\* {re.escape(group_name)} \*/ = {{[^}}]+children = \()'
    group_entry = f'\n\t\t\t\t{file_ref_uuid} /* {filename} */,'
    
    content = re.sub(
        group_pattern,
        r'\1' + group_entry,
        content
    )
    
    # 4. Ajouter à la phase de compilation des sources (PBXSourcesBuildPhase)
    # Trouver la section Sources
    sources_pattern = r'(/\* Sources \*/ = {[^}]+files = \()'
    sources_entry = f'\n\t\t\t\t{build_file_uuid} /* {filename} in Sources */,'
    
    content = re.sub(
        sources_pattern,
        r'\1' + sources_entry,
        content
    )
    
    # Écrire le fichier modifié
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print(f"✅ {filename} ajouté avec succès!")
    return True

def main():
    pbxproj_path = 'Proximity/Proximity.xcodeproj/project.pbxproj'
    
    # Fichiers à ajouter avec leurs groupes respectifs
    files_to_add = [
        {
            'path': 'Proximity/Core/Data/DataSources/Remote/DataSourceError.swift',
            'group': 'Remote'
        },
        {
            'path': 'Proximity/Core/Utils/LocationManager.swift',
            'group': 'Utils'
        },
        {
            'path': 'Proximity/Features/ServiceMap/Models/ServicePointUI.swift',
            'group': 'Models'
        }
    ]
    
    print("=" * 60)
    print("Ajout de fichiers au projet Xcode")
    print("=" * 60)
    
    for file_info in files_to_add:
        try:
            add_file_to_project(
                pbxproj_path,
                file_info['path'],
                file_info['group']
            )
        except Exception as e:
            print(f"❌ Erreur lors de l'ajout de {file_info['path']}: {e}")
            return 1
    
    print("\n" + "=" * 60)
    print("✅ Tous les fichiers ont été ajoutés avec succès!")
    print("=" * 60)
    return 0

if __name__ == '__main__':
    sys.exit(main())
