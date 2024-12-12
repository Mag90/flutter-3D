in vec3 position;
in vec3 normal;
in vec2 texcoord;

uniform Transforms {
    mat4 modelViewProjection;
    mat4 modelMatrix;
    vec4 lightPosition;   // Light position (vec3) padded to vec4
    vec4 lightColor;      // Light color (vec3) padded to vec4
    vec4 lightParams;     // ambientStrength in x, specularStrength in y
};

out vec3 v_normal;
out vec3 v_position;
out vec2 v_texcoord;

void main() {
    gl_Position = modelViewProjection * vec4(position, 1.0);
    
    // Transform normal and position for lighting calculations
    v_normal = mat3(modelMatrix) * normal;
    v_position = (modelMatrix * vec4(position, 1.0)).xyz;
    v_texcoord = texcoord;
} 