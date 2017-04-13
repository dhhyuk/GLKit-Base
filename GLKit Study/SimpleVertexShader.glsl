//position으로 2개의 데이터를 받아옴
attribute vec3 position;

uniform mat4 view;
uniform mat4 projection;

void main() {
    //임시 주석
    gl_Position = projection * view * vec4(position.x, position.y, position.z, 1.0);
}
