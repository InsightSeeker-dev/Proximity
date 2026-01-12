#!/usr/bin/env python3
"""
Script pour vérifier les imports dans tous les fichiers Swift
"""

import os
import re
from pathlib import Path

def analyze_swift_file(filepath):
    """Analyse un fichier Swift pour vérifier les imports"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extraire les imports
    imports = re.findall(r'^import\s+(\w+)', content, re.MULTILINE)
    
    # Vérifier les usages qui nécessitent des imports
    issues = []
    
    # Vérifier @Published et ObservableObject (nécessite Combine)
    if '@Published' in content or ': ObservableObject' in content or 'ObservableObject' in content:
        if 'Combine' not in imports and 'SwiftUI' not in imports:
            issues.append({
                'type': 'missing_combine',
                'message': '@Published ou ObservableObject utilisé sans import Combine ou SwiftUI'
            })
    
    # Vérifier CLLocation (nécessite CoreLocation)
    if re.search(r'\bCLLocation\b|\bCLLocationCoordinate2D\b|\bCLLocationManager\b', content):
        if 'CoreLocation' not in imports:
            issues.append({
                'type': 'missing_corelocation',
                'message': 'Types CoreLocation utilisés sans import CoreLocation'
            })
    
    # Vérifier SwiftUI components
    if re.search(r'\bView\b|\bColor\b|\b@State\b|\b@Binding\b', content):
        if 'SwiftUI' not in imports:
            issues.append({
                'type': 'missing_swiftui',
                'message': 'Composants SwiftUI utilisés sans import SwiftUI'
            })
    
    return {
        'filepath': filepath,
        'imports': imports,
        'issues': issues
    }

def main():
    base_path = Path('Proximity/Proximity')
    swift_files = list(base_path.rglob('*.swift'))
    
    print(f"Analyse de {len(swift_files)} fichiers Swift...\n")
    print("=" * 80)
    
    files_with_issues = []
    all_results = []
    
    for swift_file in sorted(swift_files):
        result = analyze_swift_file(swift_file)
        all_results.append(result)
        
        if result['issues']:
            files_with_issues.append(result)
    
    # Afficher les fichiers avec problèmes
    if files_with_issues:
        print(f"\n⚠️  {len(files_with_issues)} fichier(s) avec des imports potentiellement manquants:\n")
        
        for result in files_with_issues:
            rel_path = str(result['filepath']).replace('Proximity/Proximity/', '')
            print(f"📄 {rel_path}")
            print(f"   Imports actuels: {', '.join(result['imports']) if result['imports'] else 'Aucun'}")
            for issue in result['issues']:
                print(f"   ⚠️  {issue['message']}")
            print()
    else:
        print("\n✅ Aucun problème d'import détecté!")
    
    # Statistiques
    print("=" * 80)
    print(f"\nStatistiques:")
    print(f"  Total de fichiers: {len(swift_files)}")
    print(f"  Fichiers avec problèmes: {len(files_with_issues)}")
    print(f"  Fichiers OK: {len(swift_files) - len(files_with_issues)}")
    
    # Afficher les imports les plus communs
    from collections import Counter
    all_imports = []
    for result in all_results:
        all_imports.extend(result['imports'])
    
    if all_imports:
        print(f"\nImports les plus utilisés:")
        for module, count in Counter(all_imports).most_common(10):
            print(f"  {module}: {count} fois")
    
    return 0 if not files_with_issues else 1

if __name__ == '__main__':
    exit(main())
