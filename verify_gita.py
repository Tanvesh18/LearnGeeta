import json

data = json.load(open('assets/data/bhagavad_gita.json', encoding='utf-8'))
print(f'✓ Total chapters: {len(data["chapters"])}')
total_verses = sum(ch["verses_count"] for ch in data["chapters"])
print(f'✓ Total verses: {total_verses}')
print(f'✓ Chapter 1: {data["chapters"][0]["name"]} ({data["chapters"][0]["verses_count"]} verses)')
print(f'✓ Chapter 18: {data["chapters"][-1]["name"]} ({data["chapters"][-1]["verses_count"]} verses)')
print(f'✓ Sample verse 1.1 translations: {len(data["chapters"][0]["verses"][0].get("translations", []))} author(s)')

# Show sample verse data
verse = data["chapters"][0]["verses"][0]
print(f'\nSample Verse 1.1 Structure:')
print(f'  - Text: {verse["text"][:50]}...')
print(f'  - Transliteration: {verse["transliteration"][:50]}...')
print(f'  - Word meanings present: {bool(verse.get("word_meanings"))}')
print(f'  - Translations present: {bool(verse.get("translations"))}')
