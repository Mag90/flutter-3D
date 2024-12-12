in vec3 position;
in vec3 color;

layout(std140) uniform Transforms {
    mat4 modelViewProjection;
};

out vec3 v_color;

void main() {
    gl_Position = modelViewProjection * vec4(position, 1.0);
    v_color = color;
} 