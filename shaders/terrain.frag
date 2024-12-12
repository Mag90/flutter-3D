in vec3 v_normal;
in vec3 v_position;  // This is in view space
in vec2 v_texcoord;  // This is world space UV (x=0to1 along X axis, y=0to1 along Z axis)

uniform Transforms {
    mat4 modelViewProjection;
    mat4 modelMatrix;    // This is actually modelView matrix now
    vec4 lightPosition;    // Light position in view space
    vec4 lightColor;
    vec4 lightParams;
};

out vec4 frag_color;

vec3 getTerrainColor(vec2 uv, float height, float scale) {
    // Convert UV from [0,1] range to world-space coordinates [-0.5, 0.5]
    vec2 worldPos = (uv - 0.5) * 10.0; // 10.0 is the terrain width/depth
    
    // Create checker pattern using world-space coordinates
    vec2 checker = floor(worldPos * scale);
    float pattern = mod(abs(checker.x) + abs(checker.y), 2.0);
    
    // Define colors for the checkerboard
    vec3 color1 = vec3(0.2, 0.7, 0.2); // Darker green
    vec3 color2 = vec3(0.8, 0.8, 0.2); // Light yellow-green
    
    // Height-based coloring using world-space height
    vec3 materialColor;
    float roughness;
    
    if (height > 0.8) {
        materialColor = mix(vec3(0.95, 0.95, 0.95), vec3(1.0, 1.0, 1.0), pattern); // Snow
        roughness = 0.7;
    } else if (height > 0.3) {
        materialColor = mix(vec3(0.5, 0.5, 0.5), vec3(0.6, 0.6, 0.6), pattern); // Rock
        roughness = 0.9;
    } else if (height < -0.3) {
        materialColor = mix(vec3(0.0, 0.3, 0.7), vec3(0.0, 0.4, 0.8), pattern); // Water
        roughness = 0.3;
    } else {
        materialColor = mix(color1, color2, pattern); // Default terrain
        roughness = 0.8;
    }
    
    return materialColor;
}

void main() {
    // Normalize the interpolated normal
    vec3 normal = normalize(v_normal);
    
    // Transform position back to world space for height
    vec4 worldPos = inverse(modelMatrix) * vec4(v_position, 1.0);
    float worldHeight = worldPos.y;
    
    // Get terrain color using world-space coordinates
    vec3 baseColor = getTerrainColor(v_texcoord, worldHeight, 2.0);  // Adjusted scale for world-space coordinates
    
    // View direction in view space (camera is at origin)
    vec3 viewDir = normalize(-v_position);
    
    // Calculate ambient light
    float ambientStrength = lightParams.x;
    vec3 ambient = ambientStrength * lightColor.xyz;
    
    // Calculate diffuse light with softer falloff
    vec3 lightDir = normalize(lightPosition.xyz - v_position);
    float NdotL = max(dot(normal, lightDir), 0.0);
    float diffuseFalloff = smoothstep(0.0, 1.0, NdotL);
    vec3 diffuse = diffuseFalloff * lightColor.xyz;
    
    // Calculate specular light with roughness-based shininess
    vec3 halfwayDir = normalize(lightDir + viewDir);
    float NdotH = max(dot(normal, halfwayDir), 0.0);
    float specularStrength = lightParams.y;
    float shininess = mix(64.0, 4.0, baseColor.g); // Vary shininess based on terrain type
    float spec = pow(NdotH, shininess);
    vec3 specular = specularStrength * spec * lightColor.xyz;
    
    // Apply distance-based attenuation
    float distance = length(lightPosition.xyz - v_position);
    float attenuation = 1.0 / (1.0 + 0.1 * distance + 0.01 * distance * distance);
    
    // Combine all lighting components with physically-based mixing
    vec3 result = (ambient + (diffuse + specular) * attenuation) * baseColor;
    
    // Apply gamma correction
    result = pow(result, vec3(1.0/2.2));
    
    frag_color = vec4(result, 1.0);
} 