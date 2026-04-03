shader_type canvas_item;

uniform bool dissolve_from_top = false;
// 0.0 = intero, 1.0 = sparito
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// Forza della dilatazione
uniform float expansion_amount : hint_range(0.0, 10.0) = 3.0;
// Il "punto fisso" dell'allargamento (0.5 è il centro, modificalo se scivola!)
uniform float center_x : hint_range(0.0, 1.0) = 0.5;
// Morbidezza del taglio
uniform float feather : hint_range(0.01, 0.5) = 0.1;

void fragment() {
    vec2 uv = UV;
    
    // Invertiamo il senso: l'effetto parte dal basso (1.0)
    float edge = 1.0 - progress;
    float diff = uv.y - edge;
	
	if (dissolve_from_top) {
		diff = edge - uv.y;
	}
    
    // Calcoliamo l'espansione solo per la parte che deve sparire
    // Usiamo il valore 'diff' per rendere l'espansione progressiva
    float expansion_factor = smoothstep(-feather, feather, diff);
    float current_expansion = 1.0 + (expansion_factor * expansion_amount);
    
    // --- IL TRUCCO DEL PERNO ---
    // Invece di usare 0.5 fisso, usiamo center_x.
    // Se lo sprite si sposta a sinistra, prova ad aumentare center_x nell'Inspector.
    uv.x = (uv.x - center_x) / current_expansion + center_x;
    
    // Campionamento texture
    vec4 tex_color = texture(TEXTURE, uv);
    
    // Maschera alpha: i pixel "sotto" la linea di taglio spariscono
    float alpha_mask = 1.0 - smoothstep(-feather, feather, diff);
    
    COLOR = tex_color;
    COLOR.a *= alpha_mask;
    
    // Evitiamo che la texture si ripeta o crei artefatti ai bordi dello sprite
    if (uv.x < 0.0 || uv.x > 1.0) {
        COLOR.a = 0.0;
    }
}