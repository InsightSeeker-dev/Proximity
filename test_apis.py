#!/usr/bin/env python3
"""
Script de test des APIs utilisées par Proximity
Teste l'accessibilité et la structure des réponses
"""

import json
import sys

try:
    import requests
except ImportError:
    print("❌ Module 'requests' non installé")
    print("Installez-le avec: pip install requests")
    sys.exit(1)

# Configuration
PARIS_LAT = 48.8566
PARIS_LON = 2.3522
RADIUS_KM = 2.0

def test_jcdecaux_api():
    """Test de l'API JCDecaux (Vélib)"""
    print("\n" + "="*60)
    print("🚲 TEST API JCDECAUX (Vélib)")
    print("="*60)
    
    api_key = "a8aa42f6c7525093bffb39f799de03d24d773eea"
    url = "https://api.jcdecaux.com/vls/v3/stations"
    
    params = {
        "contract": "Paris",
        "apiKey": api_key
    }
    
    try:
        print(f"📡 URL: {url}")
        print(f"📋 Params: contract=Paris, apiKey={api_key[:20]}...")
        
        response = requests.get(url, params=params, timeout=10)
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API accessible")
            print(f"📈 Nombre de stations: {len(data)}")
            
            if len(data) > 0:
                station = data[0]
                print(f"\n📍 Exemple de station:")
                print(f"   - Nom: {station.get('name', 'N/A')}")
                print(f"   - Numéro: {station.get('number', 'N/A')}")
                print(f"   - Position: {station.get('position', {})}")
                print(f"   - Vélos dispo: {station.get('mainStands', {}).get('availabilities', {}).get('bikes', 'N/A')}")
                print(f"   - Places dispo: {station.get('mainStands', {}).get('availabilities', {}).get('stands', 'N/A')}")
            
            return True
        elif response.status_code == 400:
            print(f"⚠️  Erreur 400 - Bad Request")
            print(f"   Possible raisons:")
            print(f"   - Clé API expirée ou invalide")
            print(f"   - Format de requête incorrect")
            print(f"   - Contrat 'Paris' non disponible")
            print(f"\n💡 Solution: Obtenir une nouvelle clé sur https://developer.jcdecaux.com/")
            return False
        elif response.status_code == 401:
            print(f"❌ Erreur 401 - Non autorisé (clé API invalide)")
            return False
        else:
            print(f"❌ Erreur {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ Timeout - L'API ne répond pas")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur réseau: {e}")
        return False
    except json.JSONDecodeError:
        print(f"❌ Erreur de décodage JSON")
        return False

def test_opendatasoft_api():
    """Test de l'API OpenDataSoft (Bornes de recharge)"""
    print("\n" + "="*60)
    print("⚡ TEST API OPENDATASOFT (Bornes de recharge)")
    print("="*60)
    
    url = "https://odre.opendatasoft.com/api/records/1.0/search/"
    
    params = {
        "dataset": "bornes-irve",
        "rows": 10,
        "geofilter.distance": f"{PARIS_LAT},{PARIS_LON},{int(RADIUS_KM * 1000)}"
    }
    
    try:
        print(f"📡 URL: {url}")
        print(f"📋 Params: dataset=bornes-irve, rows=10")
        print(f"📍 Géofiltre: {PARIS_LAT},{PARIS_LON} rayon={RADIUS_KM}km")
        
        response = requests.get(url, params=params, timeout=10)
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API accessible")
            print(f"📈 Nombre total de bornes: {data.get('nhits', 0)}")
            print(f"📋 Résultats retournés: {len(data.get('records', []))}")
            
            if len(data.get('records', [])) > 0:
                record = data['records'][0]
                fields = record.get('fields', {})
                print(f"\n📍 Exemple de borne:")
                print(f"   - Nom: {fields.get('n_station', 'N/A')}")
                print(f"   - Adresse: {fields.get('ad_station', 'N/A')}")
                print(f"   - Puissance: {fields.get('puiss_max', 'N/A')} kW")
                print(f"   - Type prise: {fields.get('type_prise', 'N/A')}")
                print(f"   - Opérateur: {fields.get('n_operateur', 'N/A')}")
                print(f"   - Distance: {fields.get('dist', 'N/A')} m")
            
            return True
        else:
            print(f"❌ Erreur {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ Timeout - L'API ne répond pas")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur réseau: {e}")
        return False
    except json.JSONDecodeError:
        print(f"❌ Erreur de décodage JSON")
        return False

def test_overpass_api():
    """Test de l'API Overpass (Toilettes et Pharmacies)"""
    print("\n" + "="*60)
    print("🚽 TEST API OVERPASS (OpenStreetMap - Toilettes)")
    print("="*60)
    
    url = "https://overpass-api.de/api/interpreter"
    
    query = f"""
    [out:json][timeout:25];
    (
      node["amenity"="toilets"](around:{int(RADIUS_KM * 1000)},{PARIS_LAT},{PARIS_LON});
      way["amenity"="toilets"](around:{int(RADIUS_KM * 1000)},{PARIS_LAT},{PARIS_LON});
    );
    out center;
    """
    
    try:
        print(f"📡 URL: {url}")
        print(f"📍 Recherche: toilettes autour de Paris, rayon={RADIUS_KM}km")
        
        response = requests.post(url, data=query, timeout=30)
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            elements = data.get('elements', [])
            print(f"✅ API accessible")
            print(f"📈 Nombre de toilettes trouvées: {len(elements)}")
            
            if len(elements) > 0:
                element = elements[0]
                tags = element.get('tags', {})
                print(f"\n📍 Exemple de toilette:")
                print(f"   - ID: {element.get('id', 'N/A')}")
                print(f"   - Type: {element.get('type', 'N/A')}")
                print(f"   - Nom: {tags.get('name', 'Toilettes publiques')}")
                print(f"   - Payant: {tags.get('fee', 'N/A')}")
                print(f"   - Accessible PMR: {tags.get('wheelchair', 'N/A')}")
                print(f"   - Lat/Lon: {element.get('lat', 'N/A')}, {element.get('lon', 'N/A')}")
            
            return True
        else:
            print(f"❌ Erreur {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ Timeout - L'API Overpass peut être lente, réessayez")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur réseau: {e}")
        return False
    except json.JSONDecodeError:
        print(f"❌ Erreur de décodage JSON")
        return False

def test_overpass_pharmacy():
    """Test de l'API Overpass pour les pharmacies"""
    print("\n" + "="*60)
    print("💊 TEST API OVERPASS (OpenStreetMap - Pharmacies)")
    print("="*60)
    
    url = "https://overpass-api.de/api/interpreter"
    
    query = f"""
    [out:json][timeout:25];
    (
      node["amenity"="pharmacy"](around:{int(RADIUS_KM * 1000)},{PARIS_LAT},{PARIS_LON});
      way["amenity"="pharmacy"](around:{int(RADIUS_KM * 1000)},{PARIS_LAT},{PARIS_LON});
    );
    out center;
    """
    
    try:
        print(f"📡 URL: {url}")
        print(f"📍 Recherche: pharmacies autour de Paris, rayon={RADIUS_KM}km")
        
        response = requests.post(url, data=query, timeout=30)
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            elements = data.get('elements', [])
            print(f"✅ API accessible")
            print(f"📈 Nombre de pharmacies trouvées: {len(elements)}")
            
            if len(elements) > 0:
                element = elements[0]
                tags = element.get('tags', {})
                print(f"\n📍 Exemple de pharmacie:")
                print(f"   - ID: {element.get('id', 'N/A')}")
                print(f"   - Nom: {tags.get('name', 'Pharmacie')}")
                print(f"   - Téléphone: {tags.get('phone', 'N/A')}")
                print(f"   - Horaires: {tags.get('opening_hours', 'N/A')}")
                print(f"   - Accessible PMR: {tags.get('wheelchair', 'N/A')}")
            
            return True
        else:
            print(f"❌ Erreur {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ Timeout - L'API Overpass peut être lente, réessayez")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur réseau: {e}")
        return False

def main():
    print("\n" + "🔍 TEST DES APIs PROXIMITY".center(60, "="))
    print(f"📍 Position de test: Paris ({PARIS_LAT}, {PARIS_LON})")
    print(f"📏 Rayon de recherche: {RADIUS_KM} km")
    
    results = {}
    
    # Test de chaque API
    results['JCDecaux'] = test_jcdecaux_api()
    results['OpenDataSoft'] = test_opendatasoft_api()
    results['Overpass (Toilettes)'] = test_overpass_api()
    results['Overpass (Pharmacies)'] = test_overpass_pharmacy()
    
    # Résumé
    print("\n" + "="*60)
    print("📊 RÉSUMÉ DES TESTS")
    print("="*60)
    
    for api, success in results.items():
        status = "✅ OK" if success else "❌ ÉCHEC"
        print(f"{api:30} {status}")
    
    total = len(results)
    success_count = sum(1 for v in results.values() if v)
    
    print(f"\n📈 Résultat global: {success_count}/{total} APIs fonctionnelles")
    
    if success_count == total:
        print("🎉 Toutes les APIs sont accessibles !")
        return 0
    elif success_count > 0:
        print("⚠️  Certaines APIs ont des problèmes")
        return 1
    else:
        print("❌ Aucune API n'est accessible")
        return 2

if __name__ == "__main__":
    sys.exit(main())
