in vec3 position;
in vec3 normal;
in vec3 color;

uniform Transforms {
    mat4 modelViewProjection;
    mat4 modelMatrix;
    vec4 lightPosition;
    vec4 lightColor;
    vec4 lightParams; // ambientStrength in x, specularStrength in y
};

out vec3 v_normal;
out vec3 v_position;
out vec3 v_color;

void main() {
    gl_Position = modelViewProjection * vec4(position, 1.0);
    
    // Transform normal and position for lighting calculations
    v_normal = mat3(modelMatrix) * normal;
    v_position = (modelMatrix * vec4(position, 1.0)).xyz;
    v_color = color;
}
