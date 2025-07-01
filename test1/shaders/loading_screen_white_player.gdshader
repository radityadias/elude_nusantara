shader_type canvas_item;

uniform bool is_white_aesthetic_active = false;
uniform float fade_alpha : hint_range(0.0, 1.0) = 1.0; // New uniform for fade!

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    vec4 final_color;

    if (is_white_aesthetic_active) {
        // Apply white color, preserving original alpha
        final_color = vec4(1.0, 1.0, 1.0, texture_color.a);
    } else {
        // Otherwise, use original texture color
        final_color = texture_color;
    }

    // Apply the fade_alpha to the final color's alpha channel
    final_color.a *= fade_alpha; // Multiply original alpha by fade_alpha

    COLOR = final_color;
}