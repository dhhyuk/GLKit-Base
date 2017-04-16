//position으로 3개의 데이터(x, y, z)를 받아옴
attribute vec3 position;

uniform mat4 view;
uniform mat4 projection;

void main() {
    gl_PointSize = 2.0;
    gl_Position = projection * view * vec4(position.x, position.y, position.z, 1.0);
}
