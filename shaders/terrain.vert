in vec3 position;
in vec3 normal;
in vec2 texcoord;

uniform Transforms {
    mat4 modelViewProjection;
    mat4 modelMatrix;    // This is actually modelView matrix now
    vec4 lightPosition;   // Light position in view space
    vec4 lightColor;      // Light color (vec3) padded to vec4
    vec4 lightParams;     // ambientStrength in x, specularStrength in y
};

out vec3 v_normal;
out vec3 v_position;
out vec2 v_texcoord;

void main() {
    // Transform to clip space for final position
    gl_Position = modelViewProjection * vec4(position, 1.0);
    
    // Transform position to view space using modelView matrix
    v_position = (modelMatrix * vec4(position, 1.0)).xyz;
    
    // Transform normal to view space
    v_normal = normalize(mat3(modelMatrix) * normal);
    
    v_texcoord = texcoord;
} 