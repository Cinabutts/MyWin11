import re

def convert_theme():
    source_code = editor.getText()
    
    # Pre-processing: Remove all whole-word, case-sensitive "L" characters.
    source_code = re.sub(r'\bL\b', '', source_code)

    theme_name_match = re.search(r'const Theme g_theme(\w+)\s*=', source_code)
    if not theme_name_match:
        editor.setText('{"error": "Could not find theme name. Check the source code."}')
        return
    theme_name = theme_name_match.group(1).replace('_', ' ')
    
    json_lines = []
    json_lines.append('  "theme": "{}"'.format(theme_name))

    blocks = re.findall(r'ThemeTargetStyles\s*\{(.*?)\}\}', source_code, re.DOTALL)
    if not blocks:
        editor.setText('{"error": "Could not find any ThemeTargetStyles blocks."}')
        return

    control_index = 0
    for block_content in blocks:
        try:
            target_part, styles_part = block_content.split(',', 1)
        except ValueError:
            continue

        target = target_part.strip().strip('"')
        json_lines.append('  "controlStyles[{}].target": "{}"'.format(control_index, target))
        
        styles = re.findall(r'"((?:[^"\\]|\\.)*)"', styles_part)
        
        style_index = 0
        for style in styles:
            literal_content = style.replace('\\"', '"')
            json_ready_content = literal_content.replace('"', '\\"')
            json_lines.append('  "controlStyles[{}].styles[{}]": "{}"'.format(control_index, style_index, json_ready_content))
            style_index += 1
            
        control_index += 1

    if len(json_lines) <= 1:
        editor.setText('{"error": "Could not parse any control styles."}')
        return

    json_body = ',\n'.join(json_lines)
    final_json = '{\n' + json_body + '\n}'
    
    editor.setText(final_json)

if __name__ == '__main__':
    convert_theme()