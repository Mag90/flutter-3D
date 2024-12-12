in vec3 v_normal;
in vec3 v_position;
in vec2 v_texcoord;

uniform Transforms {
    mat4 modelViewProjection;
    mat4 modelMatrix;
    vec4 lightPosition;
    vec4 lightColor;
    vec4 lightParams;
};

out vec4 frag_color;

vec3 checkerboard(vec2 uv, float scale) {
    vec2 checker = floor(uv * scale);
    float pattern = mod(checker.x + checker.y, 2.0);
    
    // Define colors for the checkerboard
    vec3 color1 = vec3(0.2, 0.7, 0.2); // Darker green
    vec3 color2 = vec3(0.8, 0.8, 0.2); // Light yellow-green
    
    // Get the height-based position (v_texcoord.y is our normalized height)
    float height = v_position.y;
    
    // Adjust colors based on height
    if (height > 0.5) {
        color1 = vec3(1.0, 1.0, 1.0); // Snow (white)
        color2 = vec3(0.9, 0.9, 0.9); // Light gray
    } else if (height > 0.2) {
        color1 = vec3(0.5, 0.5, 0.5); // Rock (gray)
        color2 = vec3(0.6, 0.6, 0.6); // Lighter gray
    } else if (height < -0.3) {
        color1 = vec3(0.0, 0.3, 0.7); // Water (blue)
        color2 = vec3(0.0, 0.4, 0.8); // Lighter blue
    }
    
    return mix(color1, color2, pattern);
}

void main() {
    vec3 normal = normalize(v_normal);
    vec3 baseColor = checkerboard(v_texcoord, 32.0); // Increased scale for smaller checkers
    
    // Calculate ambient light
    vec3 ambient = lightParams.x * lightColor.xyz;
    
    // Calculate diffuse light
    vec3 lightDir = normalize(lightPosition.xyz - v_position);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * lightColor.xyz;
    
    // Calculate specular light
    vec3 viewDir = normalize(vec3(0.0, 0.0, 4.0) - v_position);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = lightParams.y * spec * lightColor.xyz;
    
    // Combine all lighting components
    vec3 result = (ambient + diffuse + specular) * baseColor;
    frag_color = vec4(result, 1.0);
} 