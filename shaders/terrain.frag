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

uniform sampler2D terrainTexture;

out vec4 frag_color;

void main() {
    vec3 normal = normalize(v_normal);
    vec3 baseColor = texture(terrainTexture, v_texcoord).rgb;
    
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
    frag_color = vec4(clamp(result, 0.0, 1.0), 1.0);
} 